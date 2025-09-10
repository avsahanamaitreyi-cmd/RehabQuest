<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%
    // Handle logout
    if(request.getParameter("logout") != null){
        session.invalidate();

        // remove cookie
        Cookie remove = new Cookie("patientId", "");
        remove.setMaxAge(0); // expire immediately
        remove.setPath("/");
        response.addCookie(remove);

        response.sendRedirect("login.jsp");
        return;
    }

    String loggedInUser = (String) session.getAttribute("username");
    String error = request.getParameter("error");

    // If login form submitted
    if(request.getParameter("login") != null){
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        String url = "jdbc:mysql://localhost:3306/rehabquest"; // DB
        String dbUser = "root";  // DB user
        String dbPass = "admin"; // DB password

        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
            String sql = "SELECT id FROM patients WHERE name=? AND password=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username.trim());
            ps.setString(2, password.trim());
            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                int patientId = rs.getInt("id");

                // ✅ Store in session
                HttpSession s = request.getSession();
                s.setAttribute("username", username);
                s.setAttribute("patientId", patientId);

                // ✅ Store in cookie (available to JS)
                Cookie c = new Cookie("patientId", String.valueOf(patientId));
                c.setMaxAge(60 * 60 * 24); // 1 day
                c.setPath("/"); // available across app
                response.addCookie(c);

                // Redirect to avoid form resubmission
                response.sendRedirect("login.jsp");
                return;
            } else {
                // login failed
                response.sendRedirect("login.jsp?error=1");
                return;
            }

        } catch(Exception e){
            out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link rel="icon" href="logo.png" type="image/png" />
<title>Login Page</title>
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
.home-btn:hover { opacity: 0.9; }
.login-card {
  position: relative;
  max-width: 400px; margin: 120px auto; padding: 30px;
  border-radius: var(--card-radius); background: var(--card);
  box-shadow: var(--shadow);
}
.logout-container { position: absolute; top: 15px; right: 15px; }
.logout-btn {
  padding: 8px 16px; border-radius: 8px;
  background: linear-gradient(90deg, var(--accent), var(--accent-2));
  color: #0b1022; font-weight: 700;
  cursor: pointer; transition: opacity 0.2s;
}
.logout-btn:hover { opacity: 0.9; }
.login-card h2 { text-align: center; margin-bottom: 25px; color: var(--accent); }
.login-card label { display: block; margin-bottom: 6px; font-size: 14px; color: var(--text-2); }
.login-card input {
  width: 100%; padding: 12px; margin-bottom: 16px;
  border: 1px solid var(--border); border-radius: 8px;
  background: #0b1022; color: var(--text); font-size: 15px;
}
.error { color: var(--danger); text-align: center; margin-bottom: 12px; font-weight: 600; }
.btn-login {
  width: 100%; padding: 12px; border: none; border-radius: 8px;
  background: linear-gradient(90deg,var(--accent),var(--accent-2));
  color: #0b1022; font-weight: 700; cursor: pointer; transition: 0.2s;
}
.btn-login:hover { opacity: 0.9; }
.button-options { margin-top: 20px; text-align: center; }
.button-options a {
  display:inline-block; padding: 12px 25px; margin: 10px;
  font-size: 16px; border-radius: 8px; cursor: pointer;
  background: linear-gradient(90deg,var(--accent),var(--accent-2));
  color: #0b1022; font-weight: 700; text-decoration:none;
}
.button-options a:hover { opacity: 0.9; }
</style>
</head>
<body>
<div class="top-right-home">
    <a href="index.jsp" class="home-btn">Home</a>
</div>
<div class="login-card">
    <h2>Login</h2>

    <% if("1".equals(error)){ %>
        <div class="error">Invalid username or password</div>
    <% } %>

    <% if(loggedInUser == null){ %>
        <!-- Login form -->
        <form method="post" action="login.jsp">
            <input type="hidden" name="login" value="1">
            <label for="username">Username</label>
            <input type="text" name="username" placeholder="Enter Username" required>
            <label for="password">Password</label>
            <input type="password" name="password" placeholder="Enter Password" required>
            <button type="submit" class="btn-login">Login</button>
        </form>
    <% } else { %>
        <!-- Welcome + buttons -->
        <div class="logout-container">
            <a href="login.jsp?logout=1" class="logout-btn">Logout</a>
        </div>

        <h3 style="text-align:center; color:var(--accent);">Welcome, <%= loggedInUser %>!</h3>
        <div class="button-options">
            <a href="patient.jsp">View Progress</a>
            <a href="exercisefinal_enhanced.html">Start Today's Exercise</a>
        </div>
    <% } %>
</div>
</body> 
</html>
