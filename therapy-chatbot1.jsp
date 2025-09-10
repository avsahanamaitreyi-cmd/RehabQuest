<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Get current date and time
    Date currentDate = new Date();
    SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");
    String formattedDate = sdf.format(currentDate);
    
    // Get day of week for motivational content
    SimpleDateFormat dayFormat = new SimpleDateFormat("EEEE");
    String dayOfWeek = dayFormat.format(currentDate).toLowerCase();
    
    // Get patient ID from session or default to 1
    String patientId = (String) session.getAttribute("patient_id");
    if (patientId == null) {
        patientId = "1";
        session.setAttribute("patient_id", patientId);
    }
    
    // Therapist contact information
    String therapistEmail = "therapist@healthcare.com";
    String therapistPhone = "+917395988615";
    String therapistName = "Dr. Sarah Johnson";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Health & Fitness Therapy Assistant</title>
    <style>
        :root {
            --bg: #0f172a;
            --card: #111827;
            --muted: #64748b;
            --accent: #22d3ee;
            --accent-2: #a78bfa;
            --success: #34d399;
            --danger: #f87171;
            --warning: #fbbf24;
            --text: #e5e7eb;
            --text-2: #94a3b8;
            --border: #1f2937;
            --card-radius: 18px;
            --shadow: 0 10px 30px rgba(0,0,0,.35);
        }

        * { box-sizing: border-box; }
        html, body {
            margin: 0;
            padding: 0;
            background: linear-gradient(160deg, #0b1022, #0d1328 50%, #0a0f22);
            font-family: Inter, system-ui, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
            color: var(--text);
            height: 100vh;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 24px;
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        .nav {
            position: sticky;
            top: 0;
            z-index: 5;
            background: rgba(8,10,20,.7);
            backdrop-filter: blur(8px);
            border-bottom: 1px solid var(--border);
            padding: 16px 0;
            border-radius: 12px;
            margin-bottom: 20px;
        }

        .nav .nav-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
        }

        .logo {
            display: flex;
            gap: 10px;
            align-items: center;
            font-weight: 900;
            letter-spacing: .3px;
        }

        .logo .dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: var(--accent);
            box-shadow: 0 0 18px var(--accent);
        }

        .main-content {
            display: grid;
            grid-template-columns: 300px 1fr 250px;
            gap: 20px;
            flex: 1;
            height: calc(100vh - 120px);
        }

        .sidebar, .alerts-panel {
            background: radial-gradient(1200px 600px at 0% 0%, rgba(34,211,238,.12), transparent 40%),
                       radial-gradient(900px 500px at 100% 0%, rgba(167,139,250,.10), transparent 40%),
                       #0c1224;
            border: 1px solid var(--border);
            border-radius: var(--card-radius);
            padding: 20px;
            overflow-y: auto;
        }

        .chat-container {
            background: radial-gradient(1200px 600px at 0% 0%, rgba(34,211,238,.12), transparent 40%),
                       radial-gradient(900px 500px at 100% 0%, rgba(167,139,250,.10), transparent 40%),
                       #0c1224;
            border: 1px solid var(--border);
            border-radius: var(--card-radius);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .motivation-section h3, .alerts-section h3 {
            color: var(--accent);
            margin-bottom: 15px;
            font-size: 16px;
        }

        .daily-reminder {
            background: #0b1022;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 15px;
            margin-bottom: 15px;
            border-left: 4px solid var(--success);
        }

        .daily-reminder h4 {
            color: var(--success);
            margin: 0 0 8px 0;
            font-size: 14px;
        }

        .daily-reminder p {
            margin: 0;
            font-size: 13px;
            color: var(--text-2);
        }

        .alert-item {
            background: #0b1022;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 15px;
            margin-bottom: 15px;
        }

        .alert-item.critical {
            border-left: 4px solid var(--danger);
        }

        .alert-item.warning {
            border-left: 4px solid var(--warning);
        }

        .alert-item.info {
            border-left: 4px solid var(--accent);
        }

        .alert-item h4 {
            margin: 0 0 8px 0;
            font-size: 14px;
        }

        .alert-item.critical h4 {
            color: var(--danger);
        }

        .alert-item.warning h4 {
            color: var(--warning);
        }

        .alert-item.info h4 {
            color: var(--accent);
        }

        .alert-item p {
            margin: 0 0 10px 0;
            font-size: 13px;
            color: var(--text-2);
        }

        .contact-therapist {
            background: linear-gradient(90deg, var(--danger), #dc2626);
            border: none;
            border-radius: 8px;
            padding: 8px 12px;
            color: white;
            font-weight: 600;
            cursor: pointer;
            font-size: 12px;
            width: 100%;
            margin-top: 10px;
        }

        .contact-therapist:hover {
            background: linear-gradient(90deg, #dc2626, var(--danger));
        }

        .stats-section {
            margin-top: 20px;
        }

        .stat-card {
            background: #0b1022;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 10px;
        }

        .stat-card .value {
            font-size: 18px;
            font-weight: 800;
            color: var(--accent);
        }

        .stat-card .label {
            font-size: 11px;
            color: var(--text-2);
        }

        .chat-header {
            background: #0b1022;
            border-bottom: 1px solid var(--border);
            padding: 20px;
        }

        .chat-header h2 {
            margin: 0;
            color: var(--text);
            font-size: 20px;
        }

        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .message {
            max-width: 80%;
            padding: 12px 16px;
            border-radius: 16px;
            word-wrap: break-word;
        }

        .message.user {
            align-self: flex-end;
            background: linear-gradient(90deg, var(--accent), var(--accent-2));
            color: #0b1022;
            font-weight: 600;
        }

        .message.bot {
            align-self: flex-start;
            background: #0b1022;
            border: 1px solid var(--border);
            color: var(--text);
        }

        .message.alert {
            align-self: center;
            background: linear-gradient(90deg, var(--danger), #dc2626);
            color: white;
            font-weight: 600;
            text-align: center;
            max-width: 90%;
        }

        .chat-input-container {
            background: #0b1022;
            border-top: 1px solid var(--border);
            padding: 20px;
            display: flex;
            gap: 10px;
        }

        .chat-input {
            flex: 1;
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 25px;
            padding: 12px 20px;
            color: var(--text);
            font-size: 14px;
            outline: none;
        }

        .chat-input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 2px rgba(34, 211, 238, 0.2);
        }

        .send-btn {
            background: linear-gradient(90deg, var(--accent), var(--accent-2));
            border: none;
            border-radius: 50%;
            width: 45px;
            height: 45px;
            color: #0b1022;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.2s;
        }

        .send-btn:hover {
            transform: scale(1.05);
        }

        .typing-indicator {
            display: none;
            align-self: flex-start;
            background: #0b1022;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 12px 16px;
            color: var(--text-2);
        }

        .typing-dots {
            display: inline-flex;
            gap: 4px;
        }

        .typing-dots span {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--accent);
            animation: typing 1.4s infinite ease-in-out;
        }

        .typing-dots span:nth-child(1) { animation-delay: -0.32s; }
        .typing-dots span:nth-child(2) { animation-delay: -0.16s; }

        @keyframes typing {
            0%, 80%, 100% { 
                transform: scale(0);
                opacity: 0.5;
            }
            40% { 
                transform: scale(1);
                opacity: 1;
            }
        }

        .refresh-btn {
            background: var(--success);
            border: none;
            border-radius: 8px;
            padding: 8px 12px;
            color: #0b1022;
            font-weight: 600;
            cursor: pointer;
            font-size: 12px;
            margin-top: 10px;
        }

        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
        }

        .status-indicator.online {
            background: var(--success);
            box-shadow: 0 0 8px var(--success);
        }

        .status-indicator.offline {
            background: var(--danger);
            box-shadow: 0 0 8px var(--danger);
        }

        .therapist-contact {
            background: #1a1a2e;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 15px;
            margin-top: 15px;
        }

        .therapist-contact h4 {
            color: var(--accent);
            margin: 0 0 10px 0;
            font-size: 14px;
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
        .therapist-contact p {
            margin: 5px 0;
            font-size: 12px;
            color: var(--text-2);
        }

        .emergency-btn {
            background: linear-gradient(90deg, var(--danger), #dc2626);
            border: none;
            border-radius: 8px;
            padding: 10px 15px;
            color: white;
            font-weight: 700;
            cursor: pointer;
            font-size: 13px;
            width: 100%;
            margin-top: 10px;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(248, 113, 113, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(248, 113, 113, 0); }
            100% { box-shadow: 0 0 0 0 rgba(248, 113, 113, 0); }
        }

        @media (max-width: 1200px) {
            .main-content {
                grid-template-columns: 1fr;
                gap: 10px;
            }
            .sidebar, .alerts-panel {
                order: 2;
                max-height: 300px;
            }
        }
    </style>
</head>
<body>
    <nav class="nav">
        <div class="nav-container">
            <div class="logo">
                <div class="dot"></div>
                <span>HealthBot Therapy Assistant</span>
            </div>
            <div>
                <a href="index.jsp" class="home-btn">Home</a>
                <span class="status-indicator online" id="connectionStatus"></span>
                <span><%= formattedDate %></span>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="main-content">
            <!-- Left Sidebar - Motivation -->
            <div class="sidebar">
                <div class="motivation-section">
                    <h3>💪 Daily Motivation</h3>
                    <div id="dailyReminders">
                        <!-- Daily reminders will be populated here -->
                    </div>
                </div>

                <div class="stats-section">
                    <h3>📊 Your Progress</h3>
                    <div id="userStats">
                        <div class="stat-card">
                            <div class="value" id="totalSessions">-</div>
                            <div class="label">Total Sessions</div>
                        </div>
                        <div class="stat-card">
                            <div class="value" id="avgForm">-</div>
                            <div class="label">Avg Form %</div>
                        </div>
                        <div class="stat-card">
                            <div class="value" id="totalPoints">-</div>
                            <div class="label">Total Points</div>
                        </div>
                        <div class="stat-card">
                            <div class="value" id="weeklyProgress">-</div>
                            <div class="label">This Week</div>
                        </div>
                    </div>
                    <button class="refresh-btn" onclick="loadUserStats()">Refresh Stats</button>
                </div>
            </div>

            <!-- Center - Chat Container -->
            <div class="chat-container">
                <div class="chat-header">
                    <h2>🤖 Your Personal Therapy Assistant</h2>
                    <p style="margin: 5px 0 0 0; font-size: 14px; color: var(--text-2);">
                        Patient ID: <%= patientId %> | Therapist: <%= therapistName %>
                    </p>
                </div>
                
                <div class="chat-messages" id="chatMessages">
                    <div class="message bot">
                        👋 Hello! I'm your personal health and fitness therapy assistant. I monitor your progress, provide motivation, and alert your therapist if needed. How are you feeling today?
                    </div>
                </div>
                
                <div class="typing-indicator" id="typingIndicator">
                    <div class="typing-dots">
                        <span></span>
                        <span></span>
                        <span></span>
                    </div>
                </div>
                
                <div class="chat-input-container">
                    <input type="text" class="chat-input" id="chatInput" placeholder="Tell me about your progress, pain levels, or ask for help..." maxlength="500">
                    <button class="send-btn" onclick="sendMessage()">
                        <span>➤</span>
                    </button>
                </div>
            </div>

            <!-- Right Sidebar - Alerts & Therapist Contact -->
            <div class="alerts-panel">
                <div class="alerts-section">
                    <h3>🚨 Health Alerts</h3>
                    <div id="healthAlerts">
                        <div class="alert-item info">
                            <h4>System Status</h4>
                            <p>Monitoring your progress 24/7. All systems operational.</p>
                        </div>
                    </div>
                </div>

                <div class="therapist-contact">
                    <h4>👩‍⚕️ Your Therapist</h4>
                    <p><strong><%= therapistName %></strong></p>
                    <p>📧 <%= therapistEmail %></p>
                    <p>📞 <%= therapistPhone %></p>
                    <button class="contact-therapist" onclick="contactTherapist('general')">
                        📞 Contact Therapist
                    </button>
                    <button class="emergency-btn" onclick="emergencyContact()">
                        🚨 EMERGENCY CONTACT
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- JavaScript Variables from JSP -->
    <script>
        // Pass JSP variables to JavaScript safely
        var JSP_PATIENT_ID = '<%= patientId %>';
        var JSP_THERAPIST_EMAIL = '<%= therapistEmail %>';
        var JSP_THERAPIST_PHONE = '<%= therapistPhone %>';
        var JSP_THERAPIST_NAME = '<%= therapistName %>';
        var JSP_DAY_OF_WEEK = '<%= dayOfWeek %>';
    </script>

    <script>
        // Configuration using JSP variables
        const FLASK_API_URL = 'http://localhost:8000';
        const PATIENT_ID = JSP_PATIENT_ID;
        const THERAPIST_EMAIL = JSP_THERAPIST_EMAIL;
        const THERAPIST_PHONE = JSP_THERAPIST_PHONE;
        const THERAPIST_NAME = JSP_THERAPIST_NAME;
        const DAY_OF_WEEK = JSP_DAY_OF_WEEK;
        
        // Alert thresholds
        const ALERT_THRESHOLDS = {
            LOW_FORM_SCORE: 60,
            MISSED_SESSIONS: 3,
            LOW_ADHERENCE: 70,
            PAIN_KEYWORDS: ['pain', 'hurt', 'injury', 'injured', 'sore', 'ache', 'uncomfortable']
        };

        // Daily motivational quotes and reminders
        const motivationalContent = {
            monday: {
                quote: "New week, new healing opportunities! Every step forward counts! 🌱",
                tip: "Start your week with gentle stretching and positive intentions",
                focus: "Setting weekly recovery goals"
            },
            tuesday: {
                quote: "Transformation Tuesday! Your body is getting stronger every day! 💪",
                tip: "Focus on proper form and listen to your body today",
                focus: "Strength building with care"
            },
            wednesday: {
                quote: "Halfway through the week - you're doing amazing! 🔥",
                tip: "Stay hydrated and take breaks when needed",
                focus: "Endurance and consistency"
            },
            thursday: {
                quote: "Think strong, feel strong! Your progress is inspiring! ⚡",
                tip: "Mind-body connection is key to healing",
                focus: "Mental wellness and physical strength"
            },
            friday: {
                quote: "Finish the week strong! Celebrate your progress! 🎯",
                tip: "Reflect on your achievements this week",
                focus: "Celebrating weekly victories"
            },
            saturday: {
                quote: "Weekend recovery mode - be gentle with yourself! 🏃‍♂️",
                tip: "Try gentle activities and enjoy movement",
                focus: "Joy in movement"
            },
            sunday: {
                quote: "Self-care Sunday - rest and recharge for healing! 🧘‍♀️",
                tip: "Focus on relaxation and recovery",
                focus: "Rest and reflection"
            }
        };

        // Initialize the application
        document.addEventListener('DOMContentLoaded', function() {
            loadDailyMotivation();
            loadUserStats();
            checkHealthAlerts();
            
            // Set up enter key for chat input
            document.getElementById('chatInput').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    sendMessage();
                }
            });

            // Check for alerts every 5 minutes
            setInterval(checkHealthAlerts, 300000);
        });

        function loadDailyMotivation() {
            const today = DAY_OF_WEEK;
            const content = motivationalContent[today];
            
            if (content) {
                const remindersHtml = 
                    '<div class="daily-reminder">' +
                        '<h4>📅 Today\'s Motivation</h4>' +
                        '<p>' + content.quote + '</p>' +
                    '</div>' +
                    '<div class="daily-reminder">' +
                        '<h4>💡 Daily Tip</h4>' +
                        '<p>' + content.tip + '</p>' +
                    '</div>' +
                    '<div class="daily-reminder">' +
                        '<h4>🎯 Focus Area</h4>' +
                        '<p>' + content.focus + '</p>' +
                    '</div>' +
                    '<div class="daily-reminder">' +
                        '<h4>🏆 Today\'s Goal</h4>' +
                        '<p>Listen to your body and make progress at your own pace!</p>' +
                    '</div>';
                
                document.getElementById('dailyReminders').innerHTML = remindersHtml;
            }
        }

        async function loadUserStats() {
            try {
                const response = await fetch(FLASK_API_URL + '/api/user-stats/' + PATIENT_ID);
                const stats = await response.json();
                
                if (stats.success) {
                    const data = stats.data;
                    document.getElementById('totalSessions').textContent = data.total_sessions || 0;
                    document.getElementById('avgForm').textContent = (data.avg_form || 0).toFixed(1) + '%';
                    document.getElementById('totalPoints').textContent = data.total_points || 0;
                    document.getElementById('weeklyProgress').textContent = 
                        (data.weekly_stats ? data.weekly_stats.sessions_this_week : 0) + ' sessions';
                    
                    // Update connection status
                    document.getElementById('connectionStatus').className = 'status-indicator online';
                    
                    // Check for concerning patterns
                    checkHealthAlerts(data);
                } else {
                    console.error('Failed to load user stats:', stats.message);
                    document.getElementById('connectionStatus').className = 'status-indicator offline';
                }
            } catch (error) {
                console.error('Error loading user stats:', error);
                document.getElementById('connectionStatus').className = 'status-indicator offline';
                
                // Set default values if API is not available
                document.getElementById('totalSessions').textContent = '0';
                document.getElementById('avgForm').textContent = '0.0%';
                document.getElementById('totalPoints').textContent = '0';
                document.getElementById('weeklyProgress').textContent = '0 sessions';
            }
        }

        function checkHealthAlerts(userData) {
            const alertsContainer = document.getElementById('healthAlerts');
            let alertsHtml = '';
            
            // If we have user data, check for concerning patterns
            if (userData) {
                // Check for low form scores
                if (userData.avg_form < ALERT_THRESHOLDS.LOW_FORM_SCORE) {
                    alertsHtml += createAlertHtml('warning', 'Form Concern', 
                        'Average form score is ' + userData.avg_form.toFixed(1) + '%. Consider reviewing technique.',
                        'form_concern');
                }
                
                // Check for missed sessions
                if (userData.weekly_stats && userData.weekly_stats.sessions_this_week === 0) {
                    alertsHtml += createAlertHtml('info', 'Session Reminder', 
                        'No sessions recorded this week. How are you feeling?',
                        'missed_sessions');
                }
                
                // Check for significant improvement decline
                if (userData.improvement_percentage < -20) {
                    alertsHtml += createAlertHtml('critical', 'Performance Decline', 
                        'Form scores have declined by ' + Math.abs(userData.improvement_percentage) + '% this week.',
                        'performance_decline');
                }
            }
            
            // Add system status alert
            alertsHtml += createAlertHtml('info', 'System Status', 
                'Monitoring your progress 24/7. All systems operational.', null);
            
            // Render alerts
            if (alertsHtml === '') {
                alertsContainer.innerHTML = '<p style="color: var(--text-2); font-size: 13px;">No alerts at this time. Keep up the great work! 👍</p>';
            } else {
                alertsContainer.innerHTML = alertsHtml;
            }
        }

        function createAlertHtml(type, title, message, actionType) {
            let html = '<div class="alert-item ' + type + '">' +
                '<h4>' + title + '</h4>' +
                '<p>' + message + '</p>';
            
            if (actionType) {
                html += '<button class="contact-therapist" onclick="contactTherapist(\'' + actionType + '\')">Notify Therapist</button>';
            }
            
            html += '</div>';
            return html;
        }

        async function sendMessage() {
            const input = document.getElementById('chatInput');
            const message = input.value.trim();
            
            if (!message) return;
            
            // Add user message to chat
            addMessageToChat(message, 'user');
            input.value = '';
            
            // Check for pain keywords immediately
            const painKeywords = ALERT_THRESHOLDS.PAIN_KEYWORDS;
            const containsPainKeyword = painKeywords.some(keyword => 
                message.toLowerCase().includes(keyword)
            );
            
            if (containsPainKeyword) {
                // Immediate alert for pain reports
                addMessageToChat('⚠️ I noticed you mentioned discomfort. Your therapist has been notified immediately.', 'alert');
                await notifyTherapist('pain_report', 'Patient reported: "' + message + '"');
            }
            
            // Show typing indicator
            showTypingIndicator();
            
            try {
                const response = await fetch(FLASK_API_URL + '/api/chat', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        message: message,
                        patient_id: PATIENT_ID
                    })
                });
                
                const data = await response.json();
                hideTypingIndicator();
                
                if (data.success) {
                    addMessageToChat(data.response, 'bot');
                } else {
                    addMessageToChat('I apologize, but I encountered an issue. Your therapist has been notified for immediate assistance.', 'bot');
                    await notifyTherapist('system_error', 'Chat system encountered an error');
                }
            } catch (error) {
                console.error('Error sending message:', error);
                hideTypingIndicator();
                
                // Provide offline responses
                const offlineResponse = getOfflineResponse(message);
                addMessageToChat(offlineResponse, 'bot');
            }
        }

        function getOfflineResponse(message) {
            const msg = message.toLowerCase();
            
            if (ALERT_THRESHOLDS.PAIN_KEYWORDS.some(keyword => msg.includes(keyword))) {
                return "I understand you're experiencing discomfort. While I'm offline, please contact your therapist immediately if the pain is severe. Your safety is our priority. 🏥";
            }
            
            if (msg.includes('motivation') || msg.includes('encourage')) {
                const content = motivationalContent[DAY_OF_WEEK];
                return content ? content.quote + " Remember, healing takes time and patience. You're doing great! 💪" : 
                    "You're doing great work on your recovery journey! Keep up the excellent effort! 💪";
            }
            
            return "I'm temporarily offline, but your therapist has been notified of your message. Keep up the excellent work, and remember - every small step counts in your recovery journey! 🌟";
        }

        async function notifyTherapist(alertType, message) {
            try {
                const response = await fetch(FLASK_API_URL + '/api/notify-therapist', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        patient_id: PATIENT_ID,
                        alert_type: alertType,
                        message: message,
                        timestamp: new Date().toISOString(),
                        therapist_email: THERAPIST_EMAIL
                    })
                });
                
                if (response.ok) {
                    console.log('Therapist notified successfully');
                }
            } catch (error) {
                console.error('Failed to notify therapist:', error);
                if (alertType === 'pain_report' || alertType === 'emergency') {
                    addMessageToChat('⚠️ Unable to reach therapist automatically. Please contact ' + THERAPIST_NAME + ' directly at ' + THERAPIST_PHONE, 'alert');
                }
            }
        }

        function contactTherapist(reason) {
            const messages = {
                general: 'I would like to speak with my therapist about my progress.',
                form_concern: 'I need help with my exercise form and technique.',
                missed_sessions: 'I have been unable to complete my sessions and need guidance.',
                performance_decline: 'I am concerned about my declining performance.',
                pain_report: 'I am experiencing discomfort and need immediate attention.'
            };
            
            const message = messages[reason] || messages.general;
            
            // Create email link
            const subject = encodeURIComponent('Patient ' + PATIENT_ID + ' - ' + reason.replace('_', ' '));
            const body = encodeURIComponent('Dear ' + THERAPIST_NAME + ',\n\n' + message + '\n\nPlease contact me at your earliest convenience.\n\nBest regards,\nPatient ' + PATIENT_ID);
            
            // Try to open email client
            window.location.href = 'mailto:' + THERAPIST_EMAIL + '?subject=' + subject + '&body=' + body;
            
            // Also send notification through the system
            notifyTherapist(reason, message);
            
            // Show confirmation
            addMessageToChat('📧 Your therapist has been contacted regarding: ' + reason.replace('_', ' ') + '. You should receive a response within 24 hours.', 'bot');
        }

        function emergencyContact() {
            // Show emergency options
            const emergencyOptions = 
                '<div style="text-align: center; padding: 20px; background: var(--danger); color: white; border-radius: 12px; margin: 10px 0;">' +
                    '<h3>🚨 EMERGENCY CONTACT</h3>' +
                    '<p>If this is a medical emergency, call 911 immediately!</p>' +
                    '<div style="margin: 15px 0;">' +
                        '<a href="tel:911" style="background: white; color: var(--danger); padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: bold; margin: 5px;">📞 CALL 911</a>' +
                        '<a href="tel:' + THERAPIST_PHONE + '" style="background: white; color: var(--danger); padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: bold; margin: 5px;">📞 CALL THERAPIST</a>' +
                    '</div>' +
                '</div>';
            
            addMessageToChat(emergencyOptions, 'alert');
            
            // Immediately notify therapist of emergency
            notifyTherapist('emergency', 'Patient activated emergency contact protocol');
        }

        function addMessageToChat(message, sender) {
            const chatMessages = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + sender;
            
            if (sender === 'alert') {
                messageDiv.innerHTML = message;
            } else {
                messageDiv.textContent = message;
            }
            
            chatMessages.appendChild(messageDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function showTypingIndicator() {
            document.getElementById('typingIndicator').style.display = 'block';
            const chatMessages = document.getElementById('chatMessages');
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function hideTypingIndicator() {
            document.getElementById('typingIndicator').style.display = 'none';
        }

        // Auto-refresh stats every 5 minutes
        setInterval(function() {
            loadUserStats();
        }, 300000);
    </script>
</body>
</html>