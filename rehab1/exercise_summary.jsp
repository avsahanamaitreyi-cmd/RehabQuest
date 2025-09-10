<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%
    // Get patientId from request parameter
    String patientIdStr = request.getParameter("patientId");
    int patientId = 0;
    if (patientIdStr != null) {
        try {
            patientId = Integer.parseInt(patientIdStr);
        } catch (NumberFormatException e) {
            patientId = 0;
        }
    }

    if (patientId == 0) {
        out.println("Invalid or missing patient ID.");
        return;
    }

    // Database connection parameters (adjust if needed)
    String url = "jdbc:mysql://localhost:3306/rehabquest";
    String dbUser = "root";
    String dbPass = "admin";

    // Variables to hold latest session data
    int totalReps = 0;
    double correctForm = 0.0;
    int pointsEarned = 0;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "SELECT total_reps, correct_form, points_earned " +
                     "FROM exercise_sessions WHERE patient_id = ? " +
                     "ORDER BY created_at DESC LIMIT 1";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, patientId);
        rs = ps.executeQuery();

        if (rs.next()) {
            totalReps = rs.getInt("total_reps");
            correctForm = rs.getDouble("correct_form");
            pointsEarned = rs.getInt("points_earned");
        } else {
            out.println("<h2>No exercise session data found for patient.</h2>");
            return;
        }
    } catch (Exception e) {
        out.println("Database error: " + e.getMessage());
        return;
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <link rel="icon" href="logo.png" type="image/png" />
  <title>Session Summary</title>
  <link rel="stylesheet" href="styles.css"/>
</head>
<body>
  <div class="nav">
    <div class="container">
      <div class="logo"><span class="dot"></span>RehabQuest</div>
    </div>
  </div>
  <main class="container">
    <section class="card">
      <h3 class="section-title">Great job! Session summary</h3>
      <div class="row">
        <div class="kpi"><div class="value"><%= totalReps %></div> total reps</div>
        <div class="kpi"><div class="value"><%= String.format("%.1f", correctForm) %> %</div> correct form</div>
        <div class="kpi"><div class="value">+<%= pointsEarned %></div> points earned</div>
      </div>
      <div class="progress" style="margin-top:12px"><span style="width:<%= (int)correctForm %>%"></span></div>
      <div class="row" style="margin-top:18px">
        <a class="btn" href="leaderboard.jsp">View Leaderboard</a>
        <a class="btn secondary" href="patient.jsp">Back to Dashboard</a>
      </div>
    </section>
  </main>
</body>
</html>
