<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String message = "";
    if(request.getMethod().equalsIgnoreCase("POST")) {
        String name      = request.getParameter("name");
        String ageStr    = request.getParameter("age");
        String diagnosis = request.getParameter("diagnosis");
        String startDate = request.getParameter("start_date");
        String password  = request.getParameter("password");
        int age = 0;
        try { age = Integer.parseInt(ageStr); }
        catch(NumberFormatException e) { message = "Invalid age value."; }
        if(message.isEmpty()) {
            Connection conn = null; PreparedStatement ps = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/rehabquest", "root", "admin");
                String sql = "INSERT INTO patients (name, age, diagnosis, start_date, password) VALUES (?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, name); ps.setInt(2, age); ps.setString(3, diagnosis);
                ps.setString(4, startDate); ps.setString(5, password);
                int result = ps.executeUpdate();
                if(result > 0) { response.sendRedirect("login.jsp"); return; }
                else { message = "Error registering patient."; }
            } catch(Exception e) { message = "Database error: " + e.getMessage(); }
            finally { if(ps != null) try { ps.close(); } catch(Exception e) {} if(conn != null) try { conn.close(); } catch(Exception e) {} }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link rel="icon" href="login.jsp" type="image/png" />
<title>Patient Sign Up</title>
<link rel="stylesheet" href="styles.css" />
<style>
    :root {
        --bg:#0f172a; --card:#111827; --muted:#64748b; --accent:#22d3ee; --accent-2:#a78bfa;
        --success:#34d399; --danger:#f87171; --text:#e5e7eb; --text-2:#94a3b8; --border:#1f2937;
        --card-radius:18px; --shadow:0 10px 30px rgba(0,0,0,.35);
    }
    *{box-sizing:border-box}
    html,body{margin:0;padding:0;background:linear-gradient(160deg,#0b1022,#0d1328 50%,#0a0f22);font-family:Inter,system-ui,Segoe UI,Roboto,Helvetica,Arial,sans-serif;color:var(--text)}
    a{color:inherit;text-decoration:none}
    .top-right-home {
        position: absolute;
        top: 20px;
        right: 20px;
        z-index: 1000;
    }
    .home-btn {
        padding: 8px 16px;
        border-radius: 8px;
        background: linear-gradient(90deg, var(--accent), var(--accent-2));
        color: #0b1022;
        font-weight: 700;
        text-decoration: none;
        cursor: pointer;
        transition: opacity 0.2s;
        box-shadow: var(--shadow);
        border: none;
    }
    .home-btn:hover {
        opacity: 0.9;
    }
    .signup-card {
        max-width: 400px; 
        margin: 120px auto; 
        padding: 30px;
        border-radius: var(--card-radius); 
        background: var(--card);
        box-shadow: var(--shadow);
        position: relative;
    }
    .signup-card h2 {
        text-align: center; 
        margin-bottom: 25px; 
        color: var(--accent);
    }
    .signup-card label {
        display: block; 
        margin-bottom: 6px; 
        font-size: 14px; 
        color: var(--text-2);
        font-weight: 600;
    }
    .signup-card input {
        width: 100%; 
        padding: 12px; 
        margin-bottom: 16px; 
        border: 1px solid var(--border); 
        border-radius: 8px; 
        background: #0b1022; 
        color: var(--text); 
        font-size: 15px; 
    }
    .btn-signup {
        width: 100%; 
        padding: 12px; 
        border: none; 
        border-radius: 8px; 
        background: linear-gradient(90deg,var(--accent),var(--accent-2)); 
        color: #0b1022; 
        font-weight: 700; 
        cursor: pointer; 
        transition: 0.2s;
    }
    .btn-signup:hover {
        opacity: 0.9;
    }
    .message {
        color: var(--danger); 
        text-align: center; 
        margin-bottom: 12px; 
        font-weight: 600;
        background: rgba(248,113,113,0.2);
        padding: 10px;
        border-radius: 8px;
        border: 1px solid var(--danger);
    }
</style>
</head>
<body>
<div class="top-right-home">
    <a href="index.jsp" class="home-btn">Home</a>
</div>
<div class="signup-card">
    <h2>Patient Sign Up</h2>
    <% if (!message.isEmpty()) { %>
        <div class="message"><%= message %></div>
    <% } %>
    <form method="post" autocomplete="off">
        <label for="name">Name</label>
        <input type="text" id="name" name="name" placeholder="Enter Name" required value="<%= request.getParameter("name") != null ? request.getParameter("name") : "" %>" />

        <label for="age">Age</label>
        <input type="number" id="age" name="age" placeholder="Enter Age" required value="<%= request.getParameter("age") != null ? request.getParameter("age") : "" %>" />

        <label for="diagnosis">Diagnosis</label>
        <input type="text" id="diagnosis" name="diagnosis" placeholder="Enter Diagnosis" required value="<%= request.getParameter("diagnosis") != null ? request.getParameter("diagnosis") : "" %>" />

        <label for="start_date">Start Date</label>
        <input type="date" id="start_date" name="start_date" required value="<%= request.getParameter("start_date") != null ? request.getParameter("start_date") : "" %>" />

        <label for="password">Password</label>
        <input type="password" id="password" name="password" placeholder="Create Password" required />

        <button type="submit" class="btn-signup">Sign Up</button>
    </form>
</div>
</body>
</html>
