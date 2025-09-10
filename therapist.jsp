<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <link rel="icon" href="logo.png" type="image/png" />
  <title>Therapist Dashboard</title>
  <link rel="stylesheet" href="styles.css"/>
</head>
<body>
  <!-- Navbar -->
  <div class="nav">
    <div class="container">
      <div class="logo"><span class="dot"></span>RehabQuest</div>
      <div class="header-actions">
        <a class='btn' href='index.jsp'>Home</a>
      </div>
    </div>
  </div>

  <main class="container">
    <%
      Connection conn = null;
      Statement stmt = null;
      ResultSet rs = null;
      double avgAdherence = 0;
      int activePatients = 0;
      int atRisk = 0;

      java.util.List<java.util.Map<String,Object>> patients = new java.util.ArrayList<>();
      java.util.List<java.util.Map<String,Object>> leaderboard = new java.util.ArrayList<>();
      java.util.List<java.util.Map<String,Object>> alerts = new java.util.ArrayList<>();

      try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/rehabquest", "root", "admin");
          stmt = conn.createStatement();

          // Cohort KPIs
          String kpiQuery = "SELECT " +
                  "COALESCE(ROUND(AVG(es.adherence), 2), 0) AS avg_adherence, " +
                  "COUNT(DISTINCT p.id) AS active_patients, " +
                  "COUNT(DISTINCT CASE WHEN es.adherence < 60 THEN p.id END) AS at_risk " +
                  "FROM patients p " +
                  "LEFT JOIN exercise_sessions es ON p.id = es.patient_id";
          rs = stmt.executeQuery(kpiQuery);
          if(rs.next()) {
            avgAdherence = rs.getDouble("avg_adherence");
            activePatients = rs.getInt("active_patients");
            atRisk = rs.getInt("at_risk");
          }
          if(rs!=null) rs.close();

          // Patients List with adherence and last session date
          String patientQuery = "SELECT p.id, p.name, p.diagnosis, " +
                                "COALESCE(ROUND(AVG(es.adherence),2),0) AS adherence, " +
                                "MAX(es.created_at) AS last_session " +
                                "FROM patients p " +
                                "LEFT JOIN exercise_sessions es ON p.id = es.patient_id " +
                                "GROUP BY p.id, p.name, p.diagnosis";
          rs = stmt.executeQuery(patientQuery);
          while(rs.next()) {
            java.util.Map<String,Object> p = new java.util.HashMap<>();
            p.put("id", rs.getInt("id"));
            p.put("name", rs.getString("name"));
            p.put("diagnosis", rs.getString("diagnosis"));
            p.put("adherence", rs.getObject("adherence"));
            p.put("last_session", rs.getTimestamp("last_session"));
            patients.add(p);
          }
          if(rs!=null) rs.close();

          // Leaderboard: top 5 patients by points earned
          String leaderboardQuery = "SELECT p.name, SUM(es.points_earned) AS total_points " +
                                    "FROM patients p " +
                                    "JOIN exercise_sessions es ON p.id = es.patient_id " +
                                    "GROUP BY p.id, p.name " +
                                    "ORDER BY total_points DESC " +
                                    "LIMIT 5";
          rs = stmt.executeQuery(leaderboardQuery);
          while(rs.next()) {
            java.util.Map<String,Object> row = new java.util.HashMap<>();
            row.put("name", rs.getString("name"));
            row.put("points", rs.getInt("total_points"));
            leaderboard.add(row);
          }
          if(rs!=null) rs.close();

          // Alerts: Patients with less than 60% adherence
          String alertQuery = "SELECT p.name, p.diagnosis, " +
                              "ROUND(AVG(es.adherence),2) AS adherence " +
                              "FROM patients p " +
                              "JOIN exercise_sessions es ON p.id = es.patient_id " +
                              "GROUP BY p.id, p.name, p.diagnosis " +
                              "HAVING adherence < 60";
          rs = stmt.executeQuery(alertQuery);
          while(rs.next()) {
            java.util.Map<String,Object> a = new java.util.HashMap<>();
            a.put("name", rs.getString("name"));
            a.put("alert_type", "⚠ At-risk");
            a.put("alert_message", "Adherence: " + rs.getDouble("adherence") + "%");
            a.put("color", "var(blue)");
            alerts.add(a);
          }
      } catch(Exception e) {
          out.println("<p style='color:red'>Database error: " + e.getMessage() + "</p>");
      } finally {
          if(rs!=null) try{rs.close();}catch(Exception e){}
          if(stmt!=null) try{stmt.close();}catch(Exception e){}
          if(conn!=null) try{conn.close();}catch(Exception e){}
      }
    %>

    <!-- KPI / Alerts / Leaderboard -->
    <div class="grid cols-3">
      <!-- Cohort KPIs -->
      <section class="card">
        <h3 class="section-title">Cohort KPIs</h3>
        <div class="kpi"><div class="value" style="color: var(--accent);"><%= avgAdherence %></div> Avg adherence</div>
        <div class="kpi"><div class="value" style="color: var(--accent-2);"><%= activePatients %></div> Active patients</div>
        <div class="kpi"><div class="value" style="color: var(--danger);"><%= atRisk %></div> At-risk</div>
      </section>

      <!-- Alerts -->
      <section class="card">
        <h3 class="section-title">Alerts</h3>
        <ul>
          <%
            if(alerts.isEmpty()){
          %>
            <li>No alerts 🎉</li>
          <%
            } else {
                for(java.util.Map<String,Object> a : alerts){
          %>
            <li>
              <span class="badge" style='background-color:<%= a.get("color") %>'><%= a.get("alert_type") %></span>
              <%= a.get("name") %> – <%= a.get("alert_message") %>
            </li>
          <%
                }
            }
          %>
        </ul>
      </section>

      <!-- Leaderboard -->
      <section class="card">
        <h3 class="section-title">Leaderboard (Clinic)</h3>
        <table class="table">
          <thead>
            <tr><th>#</th><th>Patient</th><th>Points</th></tr>
          </thead>
          <tbody>
            <%
              if(leaderboard.isEmpty()){
            %>
              <tr><td colspan='3'>No leaderboard data</td></tr>
            <%
              } else {
                int rank = 1;
                for(java.util.Map<String,Object> row : leaderboard){
                  String color = (rank == 1) ? "var(--accent)" : (rank == 2) ? "var(--accent-2)" : "var(--text)";
            %>
              <tr>
                <td class='rank' style='color:<%= color %>'><%= rank++ %></td>
                <td><%= row.get("name") %></td>
                <td><%= row.get("points") %></td>
              </tr>
            <%
                }
              }
            %>
          </tbody>
        </table>
      </section>
    </div>

    <!-- Patients Table -->
    <section class="card" style="margin-top:18px">
      <h3 class="section-title">Patients</h3>
      <table class="table">
        <thead>
          <tr><th>Name</th><th>Diagnosis</th><th>Adherence</th><th>Last Session</th><th>Action</th></tr>
        </thead>
        <tbody>
          <%
            if(patients.isEmpty()){
          %>
            <tr><td colspan='5'>No patient data</td></tr>
          <%
            } else {
                for(java.util.Map<String,Object> p : patients){
                  java.util.Date lastSession = (java.util.Date)p.get("last_session");
                  double adherenceVal = p.get("adherence") != null ? ((Number)p.get("adherence")).doubleValue() : -1;
                  String adherenceColor = (adherenceVal >= 80) ? "var(--success)" : (adherenceVal >= 60) ? "var(--accent)" : "var(--danger)";
          %>
            <tr>
              <td><%= p.get("name") %></td>
              <td><%= p.get("diagnosis") %></td>
              <td style='color:<%= adherenceColor %>'>
                <%= (adherenceVal >= 0) ? adherenceVal + "%" : "N/A" %>
              </td>
              <td><%= (lastSession != null) ? new java.text.SimpleDateFormat("MMM dd, yyyy").format(lastSession) : "No sessions" %></td>
              <td>
                <a class='btn' href='new_prescription.jsp?patientId=<%= p.get("id") %>'>New Prescription</a>
              </td>
            </tr>
          <%
                }
            }
          %>
        </tbody>
      </table>
    </section>
  </main>
</body>
</html>