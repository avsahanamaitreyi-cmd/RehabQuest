<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Leaderboard</title>
    <link rel="icon" href="logo.png" type="image/png" />
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
<%
    // Database connection parameters
    String dbURL = "jdbc:mysql://localhost:3306/rehabquest?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String dbUser = "root";
    String dbPass = "admin";
    Connection conn = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
    } catch(Exception e) {
        out.println("<p style='color:red;'>Database connection failed: " + e.getMessage() + "</p>");
    }
%>
<div class="container">
    <h1 class="section-title">🏆 Leaderboard</h1>
    
    <!-- Display Leaderboard based on total points per patient -->
    <table class="table">
        <tr>
            <th>Rank</th>
            <th>Patient Name</th>
            <th>Total Points</th>
            <th>Sessions</th>
            <th>Last Activity</th>
        </tr>
        <%
            if(conn != null) {
                try {
                    Statement stmt = conn.createStatement();
                    // Query to get total points per patient with ranking including patient name
                    ResultSet rs = stmt.executeQuery(
                        "SELECT " +
                        "ROW_NUMBER() OVER (ORDER BY SUM(es.points_earned) DESC) as rank_num, " +
                        "es.patient_id, p.name AS patient_name, " +
                        "SUM(es.points_earned) as total_points, " +
                        "COUNT(*) as session_count, " +
                        "MAX(es.created_at) as last_activity " +
                        "FROM exercise_sessions es " +
                        "JOIN patients p ON es.patient_id = p.id " +
                        "GROUP BY es.patient_id, p.name " +
                        "ORDER BY total_points DESC " +
                        "LIMIT 20"
                    );

                    while(rs.next()) {
        %>
        <tr>
            <td class="rank"><%= rs.getInt("rank_num") %></td>
            <td><%= rs.getString("patient_name") %></td>
            <td><%= rs.getInt("total_points") %></td>
            <td><%= rs.getInt("session_count") %></td>
            <td><%= rs.getTimestamp("last_activity") %></td>
        </tr>
        <%
                    }
                    rs.close();
                    stmt.close();
                } catch(SQLException e) {
                    // Fallback query for older MySQL versions with patient name join
                    try {
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(
                            "SELECT " +
                            "es.patient_id, p.name AS patient_name, " +
                            "SUM(es.points_earned) as total_points, " +
                            "COUNT(*) as session_count, " +
                            "MAX(es.created_at) as last_activity " +
                            "FROM exercise_sessions es " +
                            "JOIN patients p ON es.patient_id = p.id " +
                            "GROUP BY es.patient_id, p.name " +
                            "ORDER BY total_points DESC " +
                            "LIMIT 20"
                        );

                        int rank = 1;
                        while(rs.next()) {
        %>
        <tr>
            <td class="rank"><%= rank++ %></td>
            <td><%= rs.getString("patient_name") %></td>
            <td><%= rs.getInt("total_points") %></td>
            <td><%= rs.getInt("session_count") %></td>
            <td><%= rs.getTimestamp("last_activity") %></td>
        </tr>
        <%
                        }
                        rs.close();
                        stmt.close();
                    } catch(Exception fallbackE) {
                        out.println("<tr><td colspan='5'>Error loading leaderboard: " + fallbackE.getMessage() + "</td></tr>");
                    }
                }
            }
        %>
    </table>
    
    <!-- Session Statistics -->
    <div class="card" style="margin-top: 20px;">
        <h3>Session Statistics</h3>
        <%
            // Reconnect for statistics
            try {
                if(conn == null || conn.isClosed()) {
                    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                }
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(
                    "SELECT " +
                    "COUNT(DISTINCT patient_id) as total_patients, " +
                    "COUNT(*) as total_sessions, " +
                    "SUM(points_earned) as total_points, " +
                    "AVG(correct_form) as avg_form, " +
                    "AVG(adherence) as avg_adherence " +
                    "FROM exercise_sessions"
                );
                
                if(rs.next()) {
        %>
        <p><strong>Total Patients:</strong> <%= rs.getInt("total_patients") %></p>
        <p><strong>Total Sessions:</strong> <%= rs.getInt("total_sessions") %></p>
        <p><strong>Total Points Earned:</strong> <%= rs.getInt("total_points") %></p>
        <p><strong>Average Form Score:</strong> <%= String.format("%.2f", rs.getDouble("avg_form")) %>%</p>
        <p><strong>Average Adherence:</strong> <%= String.format("%.2f", rs.getDouble("avg_adherence")) %>%</p>
        <%
                }
                rs.close();
                stmt.close();
            } catch(Exception e) {
                out.println("<p style='color:red;'>Error loading statistics: " + e.getMessage() + "</p>");
            }
        %>
    </div>
    
    <!-- Top Performers Section -->
    <div class="card" style="margin-top: 20px;">
        <h3>Top Performer Details</h3>
        <%
            try {
                if(conn == null || conn.isClosed()) {
                    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                }
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(
                    "SELECT " +
                    "es.patient_id, p.name AS patient_name, " +
                    "SUM(es.points_earned) as total_points, " +
                    "AVG(es.correct_form) as avg_form, " +
                    "AVG(es.adherence) as avg_adherence, " +
                    "COUNT(*) as session_count " +
                    "FROM exercise_sessions es " +
                    "JOIN patients p ON es.patient_id = p.id " +
                    "GROUP BY es.patient_id, p.name " +
                    "ORDER BY total_points DESC " +
                    "LIMIT 3"
                );
                
                int topRank = 1;
                while(rs.next()) {
        %>
        <div style="border: 1px solid #ddd; padding: 10px; margin: 5px 0; border-radius: 5px;">
            <strong>#<%= topRank++ %> - <%= rs.getString("patient_name") %></strong><br>
            Total Points: <%= rs.getInt("total_points") %> | 
            Sessions: <%= rs.getInt("session_count") %> | 
            Avg Form: <%= String.format("%.1f", rs.getDouble("avg_form")) %>% | 
            Avg Adherence: <%= String.format("%.1f", rs.getDouble("avg_adherence")) %>%
        </div>
        <%
                }
                rs.close();
                stmt.close();
            } catch(Exception e) {
                out.println("<p style='color:red;'>Error loading top performers: " + e.getMessage() + "</p>");
            }
        %>
    </div>
    
    <%
        // Close connection
        try {
            if(conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch(SQLException e) {
            // Ignore close errors
        }
    %>
</div>
</body>
</html>
