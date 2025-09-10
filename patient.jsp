<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Logout logic
    if("1".equals(request.getParameter("logout"))){
        session.invalidate();
        response.sendRedirect("login.jsp");
        return;
    }

    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    if(username == null){
        response.sendRedirect("login.jsp");
        return;
    }

    // DB connection info
    String url = "jdbc:mysql://localhost:3306/rehabquest";
    String dbUser = "root";
    String dbPass = "admin";

    double overallAdherence = 0.0;
    int totalPoints = 0;
    List<Map<String,Object>> todayExercises = new ArrayList<>();
    int patientId = 0;
    String therapistFeedback = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, dbUser, dbPass);

        // Get patient ID
        PreparedStatement ps1 = conn.prepareStatement("SELECT id FROM patients WHERE name=?");
        ps1.setString(1, username);
        ResultSet rs1 = ps1.executeQuery();
        if(rs1.next()){
            patientId = rs1.getInt("id");
        }
        rs1.close();
        ps1.close();

        // New code to get prescribed exercises and feedback
        List<Map<String,Object>> prescribedExercises = new ArrayList<>();

        try {
            PreparedStatement ps2 = conn.prepareStatement(
                "SELECT id, feedback FROM prescriptions WHERE patient_id = ? ORDER BY created_at DESC LIMIT 1"
            );
            ps2.setInt(1, patientId);
            ResultSet rs2 = ps2.executeQuery();

            int prescriptionId = 0;
            if(rs2.next()) {
                prescriptionId = rs2.getInt("id");
                therapistFeedback = rs2.getString("feedback");
            }
            rs2.close();
            ps2.close();

            if(prescriptionId > 0) {
                PreparedStatement ps3 = conn.prepareStatement(
                    "SELECT exercise_name FROM prescription_exercises WHERE prescription_id = ?"
                );
                ps3.setInt(1, prescriptionId);
                ResultSet rs3 = ps3.executeQuery();

                while(rs3.next()) {
                    Map<String,Object> ex = new HashMap<>();
                    ex.put("exercise_name", rs3.getString("exercise_name"));
                    prescribedExercises.add(ex);
                }
                rs3.close();
                ps3.close();
            }
        } catch(Exception e) {
            out.println("Error loading prescription exercises: " + e.getMessage());
        }

        // Replace old list with prescribed exercises list
        todayExercises = prescribedExercises;

        // Compute overall adherence: average adherence across all sessions (already in percent)
        PreparedStatement ps4 = conn.prepareStatement(
            "SELECT COALESCE(AVG(adherence),0) AS avg_adherence FROM exercise_sessions WHERE patient_id=?"
        );
        ps4.setInt(1, patientId);
        ResultSet rs4 = ps4.executeQuery();
        if(rs4.next()){
            overallAdherence = rs4.getDouble("avg_adherence");
        }
        rs4.close();
        ps4.close();

        conn.close();
    } catch(Exception e){
        out.println("Error: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link rel="icon" href="logo.png" type="image/png" />
<title>Patient Dashboard</title>
<link rel="stylesheet" href="styles.css" />
<style>
.card {
    background: radial-gradient(1200px 600px at 0% 0%, rgba(34,211,238,.12), transparent 40%),
                radial-gradient(900px 500px at 100% 0%, rgba(167,139,250,.10), transparent 40%),
                #0c1224;
    border: 1px solid #1f2937;
    border-radius: 18px;
    padding: 18px;
    box-shadow: 0 10px 30px rgba(0,0,0,.35);
}
.kpi {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px;
    border-radius: 12px;
    background: #0b1022;
    border: 1px solid #1f2937;
}
.kpi .value {
    font-size: 24px;
    font-weight: 800;
}
.badge {
    padding: 6px 10px;
    border-radius: 999px;
    background: #0b1022;
    border: 1px solid #1f2937;
    color: #94a3b8;
    font-size: 12px;
}
.section-title {
    font-weight: 800;
    letter-spacing: .4px;
    margin: 12px 0 6px;
}
.table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0 10px;
}
.table th {
    text-align: left;
    color: #94a3b8;
    font-weight: 600;
    font-size: 13px;
}
.table td {
    background: #0b1022;
    border: 1px solid #1f2937;
    padding: 12px;
    border-left: none;
    border-right: none;
}
.btn {
    display:inline-block;
    padding:12px 18px;
    border-radius:999px;
    background:linear-gradient(90deg,#22d3ee,#a78bfa);
    color:#0b1022;
    font-weight:700;
    border:none;
    box-shadow:0 10px 30px rgba(0,0,0,.35);
}
.btn:hover {
    opacity: 0.9;
}
.header-actions {
    display: flex;
    gap: 10px;
    align-items: center;
}
.nav {
    position: sticky;
    top: 0;
    z-index: 5;
    background: rgba(8,10,20,.7);
    backdrop-filter: blur(8px);
    border-bottom: 1px solid #1f2937;
}
.nav .container {
    display:flex;
    align-items:center;
    justify-content: space-between;
}
.progress {
    height: 10px;
    background: #0b1022;
    border-radius: 999px;
    border: 1px solid #1f2937;
    overflow: hidden;
}
.progress > span {
    display: block;
    height: 100%;
    background: linear-gradient(90deg, #34d399, #22d3ee);
}
.grid.cols-2 {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 20px;
}
</style>
</head>
<body>
<div class='nav'>
    <div class='container'>
        <div class='logo'><span class='dot'></span>RehabQuest</div>
        <div class='header-actions'>
            <a class="badge" href="chatbot1.html">Chat with AI</a>
            <span class='badge'>Points: <%= totalPoints %></span>
            <a class='btn' href='index.html'>Video Consult</a>
            <a class='btn' href='login.jsp?logout=1'>Logout</a>
        </div>
    </div>
</div>

<main class='container'>
    <!-- Today's Plan + Overall Adherence in a 2-column grid -->
    <div class='grid cols-2' style='margin-top: 18px;'>
        <!-- Today's Plan (left column) -->
        <section class='card'>
            <h3 class='section-title'>Today's Plan</h3>
            <div class='kpi'>
                <div class='value'><%= todayExercises.size() %></div> exercises &#8226; ~<%= todayExercises.size()*6 %> mins
            </div>
            <table class='table'>
                <thead>
                    <tr>
                        <th>Exercise</th>
                        <th>Completed Reps</th>
                        <th>Avg Adherence %</th>
                        <th>Last Session</th>
                        <th>Points Earned</th>
                    </tr>
                </thead>
                <tbody>
                    <% for(Map<String,Object> ex : todayExercises){
                         java.util.Date lastSession = (java.util.Date) ex.get("last_session");
                    %>
                    <tr>
                        <td><%= ex.get("exercise_name") %></td>
                        <td><%= ex.get("total_reps") %></td>
                        <td><%= String.format("%.2f", ex.get("avg_adherence")) %></td>
                        <td><%= (lastSession != null) ? new java.text.SimpleDateFormat("MMM dd, yyyy").format(lastSession) : "N/A" %></td>
                        <td><%= ex.get("points_earned") %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table> 
            <a class='btn' href='exercise.html?patientId=<%= patientId %>'>Start First Session</a>
            <a class='btn' href='leaderboard.jsp'>View Leaderboard</a>
        </section>
        <section class='card'>
            <h3 class='section-title'>Therapist Feedback</h3>
            <p><%= therapistFeedback == null || therapistFeedback.isEmpty() ? "No feedback yet." : therapistFeedback %></p>
        </section>

        <!-- Overall Adherence (right column) -->
        <section class='card' style='width: 100%; max-width: 400px; margin-left: auto; margin-top: 0;'>
            <h3 class='section-title'>Overall Adherence</h3>
            <div class='progress' style='margin-top: 8px;'>
                <span style='width: <%= overallAdherence %>%'></span>
            </div>
            <p style='margin-top: 6px; font-weight: 600; color: var(--text-2);'>
                <%= String.format("%.2f", overallAdherence) %>% is the total average adherance of the patient.  
            </p>
        </section>
    </div>
</main>
</body>
</html>
