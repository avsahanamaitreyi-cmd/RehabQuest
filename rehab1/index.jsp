<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="icon" href="logo.png" type="image/png" />
  <title>RehabQuest</title>
  <link rel="stylesheet" href="styles.css" />
  <style>
    /* Splash screen styling */
    #logo-splash {
      position: fixed;
      top: 0; left: 0;
      width: 100vw; height: 100vh;
      background: #001A3B;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      z-index: 10000;
      opacity: 1;
      transition: opacity 1.5s ease;
      color: var(--accent);
      font-family: Inter, system-ui, Arial, sans-serif;
      font-weight: 900;
      letter-spacing: 0.3px;
    }
    #logo-splash img {
      max-height: 140px;
      width: auto;
      animation: logo-pop 1s infinite alternate;
    }
    #logo-splash div {
      margin-top: 16px;
      font-size: 2rem;
    }
    @keyframes logo-pop {
      0% { transform: scale(1); filter: brightness(1); }
      100% { transform: scale(1.08); filter: brightness(1.12); }
    }
    /* Initially hide main content visually but keep it in the document flow */
    #main-content {
      opacity: 0;
      transition: opacity 1.5s ease;
    }
    /* Modified .dot styling to use logo.png instead of blue dot */
    .logo .dot {
      width: 24px;
      height: 24px;
      border-radius: 4px;
      background: url('logo.png') no-repeat center center;
      background-size: contain;
      box-shadow: none;
    }
    /* Remove border and shadow around right image container */
    .card.skel {
      border: none !important;
      box-shadow: none !important;
      background: none !important;
    }
  </style>
</head>
<body>
  <!-- Splash screen -->
  <div id="logo-splash">
    <img src="logo.png" alt="RehabQuest Logo" />
    <div>RehabQuest</div>
  </div>
  <!-- Main page content wrapped here -->
  <div id="main-content" style="display: block;">
    <!-- Your existing page HTML goes here exactly as provided -->
    <div class="nav">
      <div class="container">
        <div class="logo"><span class="dot"></span>RehabQuest</div>
        <div class="header-actions">
          <a class="badge" href="sign_up.jsp">Sign Up Now</a>
          <a class="badge" href="login.jsp">Patient Login</a>
          <a class="badge" href="therapist.jsp">Therapist Dashboard</a>
          <a class="badge" href="therapy-chatbot1.jsp">Agentic AI</a>
          <a class="btn" href="#get-started">Get Started</a>
        </div>
      </div>
    </div>
    <header class="hero container" role="banner">
      <div class="grid cols-2">
        <div>
          <h1>Recover faster with<br />camera guided, gamified rehab</h1>
          <p>
            Pose estimation detects form, counts reps, and gives instant feedback. Therapists
            monitor progress remotely with actionable dashboards.
          </p>
          <div class="row"></div>
          <div class="row" style="margin-top: 14px;">
            <span class="badge">Real time feedback</span>
            <span class="badge">Rep counting</span>
            <span class="badge">ROM tracking</span>
            <span class="badge">Teleconsult</span>
          </div>
        </div>
        <div class="card skel" aria-hidden="true" style="display:flex; justify-content:center; align-items:center;">
          <img src="front1.png" alt="Front Image" style="width: 500px; height: auto; border-radius: var(--card-radius);" />
        </div>
      </div>
    </header>
    <section class="container" role="region" aria-labelledby="why-it-works-title">
      <h3 id="why-it-works-title" class="section-title">Why it works</h3>
      <div class="grid cols-3">
        <div class="card">
          <h4>Gamified Adherence</h4>
          <p class="text-muted">
            Streaks, badges, and leaderboards turn rehab into a quest.
          </p>
        </div>
        <div class="card">
          <h4>Clinical Accuracy</h4>
          <p>
            Built on standard protocols with therapist prescriptions and remote monitoring.
          </p>
        </div>
        <div class="card">
          <h4>Accessible</h4>
          <p>
            Works with a phone camera or wearables. No clinic visit required.
          </p>
        </div>
      </div>
    </section>
    <section
      class="container"
      id="get-started"
      role="region"
      aria-labelledby="get-started-title"
    >
      <div class="grid cols-2">
        <div class="card">
          <h3 id="get-started-title" class="section-title">Patients</h3>
          <p>
            Follow daily plans, get instant feedback, and see your progress.
          </p>
          <a class="btn" href="login.jsp">Open Patient Portal</a>
        </div>
        <div class="card">
          <h3 class="section-title">Therapists</h3>
          <p>
            Assign protocols, review adherence, and manage cohorts remotely.
          </p>
          <a class="btn" href="therapist.jsp">Open Therapist Dashboard</a>
        </div>
      </div>
    </section>
    <section class="container benefits" role="region" aria-labelledby="benefits-title">
      <h3 id="benefits-title" class="section-title">Benefits for Everyone</h3>
      <p>
        <strong>Patients:</strong> Gain confidence in your rehabilitation by receiving actionable feedback and tracking your progress with ease.
        <br /><br />
        <strong>Therapists:</strong> Enhance patient engagement and optimize therapy outcomes with data-backed insights and easy communication.
        <br /><br />
        <strong>Clinics:</strong> Improve overall patient satisfaction and streamline rehabilitation processes with a centralized, user-friendly platform.
      </p>
    </section>
    <footer class="container footer" role="contentinfo">
      &copy; 2025 RehabQuest. All rights reserved.
    </footer>
  </div>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const splash = document.getElementById("logo-splash");
      const main = document.getElementById("main-content");
      splash.style.opacity = '1';
      main.style.opacity = '0';
      main.style.display = 'block';
      setTimeout(() => {
        splash.style.opacity = '0';
        setTimeout(() => {
          splash.style.display = 'none';
          main.style.transition = 'opacity 1.5s ease';
          main.style.opacity = '1';
        }, 1500);
      }, 2000);
    });
  </script>
</body>
</html>
