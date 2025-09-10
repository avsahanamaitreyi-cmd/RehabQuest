from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
import logging
from datetime import datetime

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests from Tomcat

# Configure logging
logging.basicConfig(level=logging.INFO)

# Database configuration
DB_CONFIG = {
    "host": "localhost",
    "user": "root", 
    "password": "admin",
    "database": "rehabquest"
}

def get_db_connection():
    """Create a new database connection for each request"""
    try:
        return mysql.connector.connect(**DB_CONFIG)
    except mysql.connector.Error as err:
        logging.error(f"Database connection error: {err}")
        raise

@app.route("/save_session", methods=["GET","POST", "OPTIONS"])
def save_session():
    # Handle preflight OPTIONS request

    if request.method == "OPTIONS":
        return jsonify({"status": "ok"}), 200

    try:
        
        data = request.json
        # Validate required fields
        required_fields = ["patient_id","exercise_name", "total_reps", "correct_form", "adherence", "points_earned"]
        print("start1")
        #for field in required_fields:
        #    if field not in data:
        #        return jsonify({"status": "error", "message": f"Missing required field: {field}"}), 400
        #return jsonify("My data session")
        # Validate data types and ranges
        patient_id = int(data["patient_id"])
        exercise_name = str(data["exercise_name"])
        print("start2",data)
        total_reps = int(data["total_reps"])
        correct_form = float(data["correct_form"])
        adherence = float(data["adherence"])
        print("Data received:", exercise_name)
        points_Earned = int(data["points_Earned"])
        print("points_earned:", points_Earned)
        # Validate ranges
        if correct_form < 0 or correct_form > 100:
            return jsonify({"status": "error", "message": "correct_form must be between 0 and 100"}), 400
        if adherence < 0 or adherence > 100:
            return jsonify({"status": "error", "message": "adherence must be between 0 and 100"}), 400

        # Database operations
        db = get_db_connection()
        cursor = db.cursor()
        print("Before query execution")
        query = """
        INSERT INTO exercise_sessions (patient_id, exercise_name, total_reps, correct_form, adherence, points_Earned)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        values = (patient_id, exercise_name, total_reps, correct_form, adherence, points_Earned)

        cursor.execute(query, values)
        db.commit()
        print("After query execution")
        session_id = cursor.lastrowid

        cursor.close()
        db.close()

        logging.info(f"Session saved successfully: ID {session_id}, Patient {patient_id}")

        return jsonify({
            "status": "success", 
            "session_id": session_id,
            "message": "Exercise session saved successfully"
        }), 200

    except ValueError as e:
        return jsonify({"status": "error", "message": f"Invalid data format: {str(e)}"}), 400
    except mysql.connector.Error as e:
        logging.error(f"Database error: {e}")
        return jsonify({"status": "error", "message": "Database error occurred"}), 500
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return jsonify({"status": "error", "message": "An unexpected error occurred"}), 500

@app.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint"""
    try:
        db = get_db_connection()
        cursor = db.cursor()
        cursor.execute("SELECT 1")
        cursor.close()
        db.close()
        return jsonify({"status": "healthy", "timestamp": datetime.now().isoformat()}), 200
    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 500

@app.route("/sessions/<int:patient_id>", methods=["GET"])
def get_patient_sessions(patient_id):
    """Get all sessions for a specific patient"""
    try:
        db = get_db_connection()
        cursor = db.cursor(dictionary=True)

        query = """
        SELECT id, patient_id, total_reps, correct_form, adherence, points_earned, created_at
        FROM exercise_sessions 
        WHERE patient_id = %s 
        ORDER BY created_at DESC
        """
        cursor.execute(query, (patient_id,))
        sessions = cursor.fetchall()

        cursor.close()
        db.close()

        return jsonify({"status": "success", "sessions": sessions}), 200

    except Exception as e:
        logging.error(f"Error fetching sessions: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    #app.run(host="0.0.0.0", port=8000, debug=True)
    app.run(debug=True)