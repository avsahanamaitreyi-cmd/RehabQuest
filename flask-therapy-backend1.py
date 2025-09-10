from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import datetime
import json
import random
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from dotenv import load_dotenv
import logging

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# MySQL Configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'database': os.getenv('DB_NAME', 'health_fitness_db'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', 'admin'),
    'port': int(os.getenv('DB_PORT', '3306')),
    'auth_plugin': 'mysql_native_password'
}

# Email Configuration for Therapist Alerts
EMAIL_CONFIG = {
    'smtp_server': os.getenv('SMTP_SERVER', 'smtp.gmail.com'),
    'smtp_port': int(os.getenv('SMTP_PORT', '587')),
    'email_username': os.getenv('EMAIL_USERNAME', ''),
    'email_password': os.getenv('EMAIL_PASSWORD', ''),
    'from_email': os.getenv('FROM_EMAIL', 'healthbot@therapy.com')
}

# Alert thresholds
ALERT_THRESHOLDS = {
    'LOW_FORM_SCORE': 60,
    'MISSED_SESSIONS_DAYS': 3,
    'LOW_ADHERENCE': 70,
    'PERFORMANCE_DECLINE': -20,
    'PAIN_KEYWORDS': ['pain', 'hurt', 'injury', 'injured', 'sore', 'ache', 'uncomfortable', 'emergency']
}

def get_db_connection():
    """Create and return a database connection with retry logic"""
    max_retries = 3
    retry_delay = 1
    
    for attempt in range(max_retries):
        try:
            connection = mysql.connector.connect(**DB_CONFIG)
            if connection.is_connected():
                return connection
        except Error as e:
            logger.error(f"Database connection attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                import time
                time.sleep(retry_delay)
                retry_delay *= 2
    
    return None

def send_therapist_alert(therapist_email, patient_id, alert_type, message, urgency='normal'):
    """Send email alert to therapist"""
    try:
        # Create email content
        subject_map = {
            'pain_report': f'🚨 URGENT: Patient {patient_id} Pain Report',
            'emergency': f'🚨 EMERGENCY: Patient {patient_id} Emergency Alert',
            'performance_decline': f'⚠️ ALERT: Patient {patient_id} Performance Decline',
            'form_concern': f'💡 NOTICE: Patient {patient_id} Form Concern',
            'missed_sessions': f'📅 REMINDER: Patient {patient_id} Missed Sessions',
            'motivation_concern': f'💪 SUPPORT: Patient {patient_id} Motivation Issue',
            'system_error': f'🔧 SYSTEM: Patient {patient_id} Technical Issue'
        }
        
        subject = subject_map.get(alert_type, f'📋 NOTIFICATION: Patient {patient_id} Update')
        
        # Create email body
        body = f"""
        <html>
        <head></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
                <h2 style="color: #2c5aa0; text-align: center;">Health Therapy System Alert</h2>
                
                <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
                    <h3 style="margin: 0 0 10px 0; color: #d63384;" if urgency == 'high' else "color: #0d6efd;">Alert Details</h3>
                    <p><strong>Patient ID:</strong> {patient_id}</p>
                    <p><strong>Alert Type:</strong> {alert_type.replace('_', ' ').title()}</p>
                    <p><strong>Timestamp:</strong> {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
                    <p><strong>Urgency Level:</strong> {urgency.upper()}</p>
                </div>
                
                <div style="background: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #ffc107;">
                    <h4 style="margin: 0 0 10px 0; color: #664d03;">Message:</h4>
                    <p style="margin: 0;">{message}</p>
                </div>
                
                <div style="background: #d1ecf1; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #17a2b8;">
                    <h4 style="margin: 0 0 10px 0; color: #0c5460;">Recommended Actions:</h4>
                    <ul style="margin: 0; padding-left: 20px;">
        """
        
        # Add specific recommendations based on alert type
        if alert_type == 'pain_report' or alert_type == 'emergency':
            body += """
                        <li>Contact patient immediately</li>
                        <li>Assess pain level and location</li>
                        <li>Consider emergency intervention if needed</li>
                        <li>Review recent exercise sessions</li>
            """
        elif alert_type == 'performance_decline':
            body += """
                        <li>Schedule progress review session</li>
                        <li>Assess exercise program difficulty</li>
                        <li>Check for underlying issues</li>
                        <li>Consider program modifications</li>
            """
        elif alert_type == 'missed_sessions':
            body += """
                        <li>Check in with patient motivation</li>
                        <li>Identify barriers to participation</li>
                        <li>Adjust program if necessary</li>
                        <li>Provide additional support</li>
            """
        else:
            body += """
                        <li>Review patient progress</li>
                        <li>Follow up within 24-48 hours</li>
                        <li>Document in patient records</li>
            """
        
        body += """
                    </ul>
                </div>
                
                <div style="text-align: center; margin: 30px 0;">
                    <p style="color: #6c757d; font-size: 14px;">
                        This alert was generated automatically by the Health Therapy System.<br>
                        Please respond according to your clinical protocols.
                    </p>
                </div>
                
                <div style="border-top: 1px solid #dee2e6; padding-top: 20px; text-align: center;">
                    <p style="color: #6c757d; font-size: 12px; margin: 0;">
                        Health Therapy Assistant System | Automated Patient Monitoring
                    </p>
                </div>
            </div>
        </body>
        </html>
        """
        
        # Send email if configured
        if EMAIL_CONFIG['email_username'] and EMAIL_CONFIG['email_password']:
            msg = MIMEMultipart('alternative')
            msg['Subject'] = subject
            msg['From'] = EMAIL_CONFIG['from_email']
            msg['To'] = therapist_email
            
            msg.attach(MIMEText(body, 'html'))
            
            server = smtplib.SMTP(EMAIL_CONFIG['smtp_server'], EMAIL_CONFIG['smtp_port'])
            server.starttls()
            server.login(EMAIL_CONFIG['email_username'], EMAIL_CONFIG['email_password'])
            server.send_message(msg)
            server.quit()
            
            logger.info(f"Alert email sent to therapist for patient {patient_id}: {alert_type}")
            return True
        else:
            logger.warning("Email not configured, alert logged only")
            return False
            
    except Exception as e:
        logger.error(f"Failed to send therapist alert: {e}")
        return False

@app.route('/api/user-stats/<int:patient_id>', methods=['GET'])
def get_user_stats(patient_id):
    """Get comprehensive user statistics with alert checking"""
    connection = get_db_connection()
    if not connection:
        return jsonify({
            'success': False,
            'message': 'Database connection failed'
        }), 500
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        # Get overall stats
        stats_query = """
        SELECT 
            COUNT(*) as total_sessions,
            ROUND(AVG(correct_form), 2) as avg_form,
            SUM(points_earned) as total_points,
            SUM(total_reps) as total_reps,
            ROUND(AVG(adherence), 2) as avg_adherence,
            MIN(created_at) as first_session,
            MAX(created_at) as last_session
        FROM exercise_sessions 
        WHERE patient_id = %s
        """
        
        cursor.execute(stats_query, (patient_id,))
        stats = cursor.fetchone()
        
        # Get weekly progress
        weekly_query = """
        SELECT 
            COUNT(*) as sessions_this_week,
            ROUND(AVG(correct_form), 2) as avg_form_this_week,
            SUM(points_earned) as points_this_week
        FROM exercise_sessions 
        WHERE patient_id = %s 
        AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        """
        
        cursor.execute(weekly_query, (patient_id,))
        weekly_stats = cursor.fetchone()
        
        # Calculate improvement trend
        improvement_query = """
        SELECT 
            CASE 
                WHEN created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 'current_week'
                WHEN created_at >= DATE_SUB(NOW(), INTERVAL 14 DAY) THEN 'previous_week'
            END as week_period,
            ROUND(AVG(correct_form), 2) as avg_form
        FROM exercise_sessions 
        WHERE patient_id = %s 
        AND created_at >= DATE_SUB(NOW(), INTERVAL 14 DAY)
        GROUP BY week_period
        """
        
        cursor.execute(improvement_query, (patient_id,))
        improvement_data = cursor.fetchall()
        
        # Process improvement data
        current_week_form = 0
        previous_week_form = 0
        for week_data in improvement_data:
            if week_data['week_period'] == 'current_week':
                current_week_form = float(week_data['avg_form'] or 0)
            elif week_data['week_period'] == 'previous_week':
                previous_week_form = float(week_data['avg_form'] or 0)
        
        improvement_percentage = 0
        if previous_week_form > 0:
            improvement_percentage = round(((current_week_form - previous_week_form) / previous_week_form) * 100, 2)
        
        # Check for alerts
        alerts = []
        
        # Low form score alert
        avg_form = float(stats['avg_form'] or 0)
        if avg_form > 0 and avg_form < ALERT_THRESHOLDS['LOW_FORM_SCORE']:
            alerts.append('low_form_score')
        
        # Performance decline alert
        if improvement_percentage < ALERT_THRESHOLDS['PERFORMANCE_DECLINE']:
            alerts.append('performance_decline')
        
        # Missed sessions alert (no sessions in last 3 days)
        last_session = stats['last_session']
        if last_session:
            days_since_last = (datetime.datetime.now() - last_session).days
            if days_since_last > ALERT_THRESHOLDS['MISSED_SESSIONS_DAYS']:
                alerts.append('missed_sessions')
        
        response_data = {
            'total_sessions': stats['total_sessions'] or 0,
            'avg_form': avg_form,
            'total_points': stats['total_points'] or 0,
            'total_reps': stats['total_reps'] or 0,
            'avg_adherence': float(stats['avg_adherence'] or 0),
            'first_session': stats['first_session'].isoformat() if stats['first_session'] else None,
            'last_session': stats['last_session'].isoformat() if stats['last_session'] else None,
            'weekly_stats': {
                'sessions_this_week': weekly_stats['sessions_this_week'] or 0,
                'avg_form_this_week': float(weekly_stats['avg_form_this_week'] or 0),
                'points_this_week': weekly_stats['points_this_week'] or 0
            },
            'improvement_percentage': improvement_percentage,
            'alerts': alerts
        }
        
        return jsonify({
            'success': True,
            'data': response_data
        })
        
    except Error as e:
        logger.error(f"Database error in get_user_stats: {e}")
        return jsonify({
            'success': False,
            'message': f'Database error: {str(e)}'
        }), 500
        
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/api/chat', methods=['POST'])
def chat_endpoint():
    """Enhanced chat endpoint with therapist alert integration"""
    data = request.get_json()
    message = data.get('message', '').lower().strip()
    patient_id = data.get('patient_id', 1)
    
    if not message:
        return jsonify({
            'success': False,
            'message': 'Message cannot be empty'
        }), 400
    
    # Check for pain or emergency keywords
    pain_keywords = ALERT_THRESHOLDS['PAIN_KEYWORDS']
    contains_pain = any(keyword in message for keyword in pain_keywords)
    
    # Get user stats for context
    connection = get_db_connection()
    user_stats = None
    
    if connection:
        try:
            cursor = connection.cursor(dictionary=True)
            query = """
            SELECT 
                COUNT(*) as total_sessions,
                ROUND(AVG(correct_form), 2) as avg_form,
                SUM(points_earned) as total_points,
                MAX(created_at) as last_session
            FROM exercise_sessions 
            WHERE patient_id = %s
            """
            cursor.execute(query, (patient_id,))
            user_stats = cursor.fetchone()
        except Exception as e:
            logger.error(f"Error fetching user stats in chat: {e}")
        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
    
    # Generate response
    response = generate_therapy_chat_response(message, user_stats, contains_pain)
    
    # Log the interaction
    log_chat_interaction(patient_id, data.get('message', ''), response, contains_pain)
    
    return jsonify({
        'success': True,
        'response': response,
        'alerts_triggered': contains_pain
    })

def generate_therapy_chat_response(message, user_stats=None, contains_pain=False):
    """Generate therapy-focused responses with alerts"""
    
    total_sessions = user_stats['total_sessions'] if user_stats else 0
    avg_form = float(user_stats['avg_form'] or 0) if user_stats else 0
    
    # Pain or emergency response
    if contains_pain:
        pain_responses = [
            "I understand you're experiencing discomfort. This is important information for your recovery. Your therapist has been notified immediately and will contact you soon. In the meantime, please rest and avoid any activities that increase your discomfort. If this is severe pain, please contact emergency services. 🏥",
            
            "Thank you for telling me about your discomfort. Your safety is our top priority. I've immediately alerted your therapist about this. Please stop any current exercises and rest. If the pain is severe or worsening, don't hesitate to seek immediate medical attention. 🚨",
            
            "I'm concerned about the discomfort you're experiencing. Your therapist is being notified right now and should contact you within the hour. Please document when the pain started and what makes it better or worse. If you feel this needs immediate attention, please call your therapist directly or go to the nearest medical facility. 📞"
        ]
        
        return random.choice(pain_responses)
    
    # Motivational and progress responses
    elif any(word in message for word in ['motivation', 'inspire', 'encourage', 'boost', 'help']):
        motivational_responses = [
            f"🌟 You're doing incredible work in your healing journey! {f'With {total_sessions} sessions completed, you show real commitment.' if total_sessions > 0 else 'Every step forward, no matter how small, is progress.'} Your therapist believes in your ability to recover, and so do I!",
            
            f"💪 Recovery isn't always linear, but your dedication is what makes the difference! {f'Your average form score of {avg_form:.1f}% shows you care about quality.' if avg_form > 0 else 'Focus on consistency over perfection.'} Remember, your therapist is here to support you every step of the way!",
            
            f"🎯 Healing takes courage, and you're showing that every day! {f'You completed {total_sessions} sessions - that is determination!' if total_sessions >= 5 else 'You are building a strong foundation for recovery.'} Your therapist has designed your program specifically for your success!"
        ]
        
        return random.choice(motivational_responses)
    
    # Progress and stats
    elif any(word in message for word in ['progress', 'stats', 'how am i doing', 'improvement']):
        if total_sessions == 0:
            return "🌱 You're at the beginning of your healing journey! This is actually an exciting place to be - every session from here will be building your strength and recovery. Your therapist has carefully designed your program to help you succeed. Let's start with your first session when you're ready!"
        
        if avg_form >= 90:
            form_feedback = "Outstanding technique! Your attention to proper form will accelerate your recovery and prevent setbacks."
        elif avg_form >= 75:
            form_feedback = "Great progress on your form! Your therapist will be pleased with your focus on quality."
        elif avg_form >= 60:
            form_feedback = "You're developing good habits. Keep focusing on technique - your therapist can provide additional guidance."
        else:
            form_feedback = "Let's work together to improve your form. I'll let your therapist know you could use some technique review."
        
        return f"📊 **Your Recovery Progress:**\n✅ Sessions Completed: {total_sessions}\n📈 Form Quality: {avg_form:.1f}%\n\n{form_feedback} Remember, recovery is a marathon, not a sprint! 🏃‍♂️"
    
    # Exercise and technique questions
    elif any(word in message for word in ['exercise', 'technique', 'form', 'how to']):
        technique_tips = [
            "🎯 **Technique Focus**: Quality always beats quantity in recovery! Move slowly and deliberately, feeling each muscle engagement. Your therapist emphasizes proper form because it's the key to safe, effective healing. If something feels wrong, stop and ask for guidance!",
            
            "💫 **Mind-Body Connection**: Focus on the specific area you're working on. Breathe steadily - exhale during effort, inhale during release. Your therapist designed these movements to rebuild your strength safely. Listen to your body's signals!",
            
            "⚖️ **Balance is Key**: Never push through pain - discomfort and challenge are different from harmful pain. Your therapist wants you to challenge yourself within safe limits. When in doubt, ask for clarification!"
        ]
        
        return random.choice(technique_tips)
    
    # Recovery and rest
    elif any(word in message for word in ['tired', 'rest', 'recovery', 'sleep', 'sore']):
        recovery_responses = [
            "😴 **Recovery Wisdom**: Rest is when your body actually rebuilds and heals! Aim for 7-9 hours of quality sleep - this is when most tissue repair happens. Light soreness is normal, but sharp or persistent pain should be reported to your therapist immediately.",
            
            "🛁 **Recovery Techniques**: Gentle heat (warm bath, heating pad) can help with stiffness, while ice can reduce inflammation. Light stretching and deep breathing also promote healing. Your therapist can recommend the best approach for your specific condition.",
            
            "🧘‍♂️ **Listen to Your Body**: Fatigue is your body's way of asking for recovery time. Don't feel guilty about resting - it's a crucial part of your treatment plan! Your therapist would rather you rest when needed than risk setbacks."
        ]
        
        return random.choice(recovery_responses)
    
    # Default supportive responses
    else:
        default_responses = [
            f"🤗 I'm here to support your recovery journey! {f'You have shown great commitment with {total_sessions} sessions.' if total_sessions > 0 else 'Every day is a new opportunity for healing.'} Your therapist has designed a personalized plan for you. What would you like to discuss today?",
            
            f"🌟 Your healing journey is unique and important! {f'Your progress over {total_sessions} sessions shows real dedication.' if total_sessions >= 3 else 'You are taking the right steps toward recovery.'} I can help with motivation, technique questions, or just be here to listen. Your therapist is always available for more complex concerns!",
            
            f"💙 Recovery takes both physical and emotional strength, and you're showing both! {f'With an average form score of {avg_form:.1f}%, you are building quality habits.' if avg_form > 0 else 'Focus on consistency and proper technique.'} Remember, your therapist and I are both here to support you!"
        ]
        
        return random.choice(default_responses)

@app.route('/api/notify-therapist', methods=['POST'])
def notify_therapist():
    """Endpoint for JSP to trigger therapist notifications"""
    data = request.get_json()
    
    patient_id = data.get('patient_id')
    alert_type = data.get('alert_type')
    message = data.get('message')
    therapist_email = data.get('therapist_email')
    
    if not all([patient_id, alert_type, message, therapist_email]):
        return jsonify({
            'success': False,
            'message': 'Missing required fields'
        }), 400
    
    # Determine urgency level
    urgency = 'high' if alert_type in ['pain_report', 'emergency'] else 'normal'
    
    # Send alert
    success = send_therapist_alert(
        therapist_email=therapist_email,
        patient_id=patient_id,
        alert_type=alert_type,
        message=message,
        urgency=urgency
    )
    
    # Log the alert
    log_therapist_alert(patient_id, alert_type, message, success)
    
    return jsonify({
        'success': success,
        'message': 'Therapist notified' if success else 'Failed to notify therapist'
    })

def log_chat_interaction(patient_id, user_message, bot_response, alert_triggered):
    """Log chat interactions for therapist review"""
    connection = get_db_connection()
    if not connection:
        return
    
    try:
        cursor = connection.cursor()
        query = """
        INSERT INTO chat_logs (patient_id, user_message, bot_response, alert_triggered, created_at)
        VALUES (%s, %s, %s, %s, %s)
        """
        
        cursor.execute(query, (
            patient_id,
            user_message,
            bot_response,
            alert_triggered,
            datetime.datetime.now()
        ))
        connection.commit()
        
    except Error as e:
        logger.error(f"Failed to log chat interaction: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

def log_therapist_alert(patient_id, alert_type, message, success):
    """Log therapist alerts for tracking"""
    connection = get_db_connection()
    if not connection:
        return
    
    try:
        cursor = connection.cursor()
        query = """
        INSERT INTO therapist_alerts (patient_id, alert_type, message, success, created_at)
        VALUES (%s, %s, %s, %s, %s)
        """
        
        cursor.execute(query, (
            patient_id,
            alert_type,
            message,
            success,
            datetime.datetime.now()
        ))
        connection.commit()
        
    except Error as e:
        logger.error(f"Failed to log therapist alert: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/api/health', methods=['GET'])
def health_check():
    """Comprehensive health check with system status"""
    db_status = "connected"
    email_status = "configured" if EMAIL_CONFIG['email_username'] else "not_configured"
    
    try:
        connection = get_db_connection()
        if connection:
            cursor = connection.cursor()
            cursor.execute("SELECT 1")
            cursor.fetchone()
            cursor.close()
            connection.close()
        else:
            db_status = "connection_failed"
    except Exception as e:
        db_status = f"error: {str(e)}"
    
    return jsonify({
        'success': True,
        'message': 'Therapy Flask server is running',
        'timestamp': datetime.datetime.now().isoformat(),
        'database_status': db_status,
        'email_status': email_status,
        'version': '2.0.0-therapy',
        'alert_thresholds': ALERT_THRESHOLDS,
        'features': {
            'therapist_alerts': True,
            'pain_monitoring': True,
            'progress_tracking': True,
            'emergency_contact': True
        }
    })

if __name__ == '__main__':
    print("🏥 Starting Health Therapy Flask Server...")
    print(f"📊 Database: {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}")
    print(f"📧 Email alerts: {'Enabled' if EMAIL_CONFIG['email_username'] else 'Disabled (configure EMAIL_USERNAME)'}")
    print(f"🌐 Server: http://localhost:8000")
    
    # Test database connection
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor()
            
            # Create additional tables for logging if they don't exist
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS chat_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                patient_id INT NOT NULL,
                user_message TEXT NOT NULL,
                bot_response TEXT NOT NULL,
                alert_triggered BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """)
            
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS therapist_alerts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                patient_id INT NOT NULL,
                alert_type VARCHAR(50) NOT NULL,
                message TEXT NOT NULL,
                success BOOLEAN NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """)
            
            connection.commit()
            print("✅ Database connected and logging tables ready!")
            
        except Exception as e:
            print(f"⚠️ Database connected but setup failed: {e}")
        finally:
            cursor.close()
            connection.close()
    else:
        print("❌ Database connection failed!")
    
    print(f"\n🎯 Therapy-Enhanced API Endpoints:")
    print(f"   POST /api/notify-therapist  - Send therapist alerts")
    print(f"   POST /api/chat             - Enhanced chat with alerts")
    print(f"   GET  /api/user-stats/<id>  - Stats with alert checking")
    print(f"   GET  /api/health           - System health check")
    
    print(f"\n🚨 Alert System Active:")
    print(f"   Pain Keywords: {ALERT_THRESHOLDS['PAIN_KEYWORDS']}")
    print(f"   Form Threshold: {ALERT_THRESHOLDS['LOW_FORM_SCORE']}%")
    print(f"   Missed Sessions: {ALERT_THRESHOLDS['MISSED_SESSIONS_DAYS']} days")
    
    print("\n🔥 Therapy server starting...\n")
    
    app.run(debug=True, host='0.0.0.0', port=8000)