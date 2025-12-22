from flask import Blueprint, jsonify, request
from config.database import get_db_connection, close_db_connection

api_bp = Blueprint('api', __name__)

@api_bp.route('/items', methods=['GET'])
def get_items():
    """Get all items from database"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM items ORDER BY created_at DESC")
        items = cursor.fetchall()
        close_db_connection(conn)
        
        return jsonify({
            'success': True,
            'data': items
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/items', methods=['POST'])
def create_item():
    """Create a new item"""
    try:
        data = request.get_json()
        name = data.get('name')
        description = data.get('description', '')
        
        if not name:
            return jsonify({
                'success': False,
                'error': 'Name is required'
            }), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO items (name, description) VALUES (%s, %s)",
            (name, description)
        )
        conn.commit()
        item_id = cursor.lastrowid
        close_db_connection(conn)
        
        return jsonify({
            'success': True,
            'data': {
                'id': item_id,
                'name': name,
                'description': description
            }
        }), 201
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/items/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    """Delete an item by ID"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM items WHERE id = %s", (item_id,))
        conn.commit()
        affected = cursor.rowcount
        close_db_connection(conn)
        
        if affected == 0:
            return jsonify({
                'success': False,
                'error': 'Item not found'
            }), 404
        
        return jsonify({
            'success': True,
            'message': 'Item deleted successfully'
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/test-month', methods=['GET'])
def test_month():
    """Test endpoint to debug month query"""
    try:
        month = request.args.get('month', '2025-04')
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute("""
            SELECT DISTINCT DATE_FORMAT(al.date, %s) as date
            FROM activityLog al
            WHERE DATE_FORMAT(al.date, %s) = %s
            ORDER BY al.date
            LIMIT 10
        """, ('%Y-%m-%d', '%Y-%m', month))
        
        result = cursor.fetchall()
        close_db_connection(conn)
        
        return jsonify({
            'success': True,
            'count': len(result),
            'data': result
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/activities', methods=['GET'])
def get_activities():
    """Get all activities with their units"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT a.id, a.name, a.default_amt, a.fkUnitID,
                   u.name as unit_name, u.unit as unit_type
            FROM activities a
            JOIN units u ON a.fkUnitID = u.id
            ORDER BY a.name
        """)
        activities = cursor.fetchall()
        close_db_connection(conn)
        
        return jsonify({
            'success': True,
            'data': activities
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/activity-log', methods=['GET'])
def get_activity_log():
    """Get activity log entries, optionally filtered by date or month"""
    try:
        date = request.args.get('date')  # Format: YYYY-MM-DD
        month = request.args.get('month')  # Format: YYYY-MM
        
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        if date:
            # Get activities for specific date
            cursor.execute("""
                SELECT al.id, DATE_FORMAT(al.date, '%%Y-%%m-%%d') as date, 
                       al.duration, al.fkActivityId,
                       a.name as activity_name,
                       u.name as unit_name
                FROM activityLog al
                JOIN activities a ON al.fkActivityId = a.id
                JOIN units u ON a.fkUnitID = u.id
                WHERE al.date = %s
                ORDER BY al.id
            """, (date,))
        elif month:
            # Get all dates with activities for a specific month
            cursor.execute("""
                SELECT DISTINCT DATE_FORMAT(al.date, %s) as date
                FROM activityLog al
                WHERE DATE_FORMAT(al.date, %s) = %s
                ORDER BY al.date
            """, ('%Y-%m-%d', '%Y-%m', month))
            result = cursor.fetchall()
            close_db_connection(conn)
            return jsonify({
                'success': True,
                'data': result
            })
        else:
            # Get all activity log entries
            cursor.execute("""
                SELECT al.id, DATE_FORMAT(al.date, '%%Y-%%m-%%d') as date, 
                       al.duration, al.fkActivityId,
                       a.name as activity_name,
                       u.name as unit_name
                FROM activityLog al
                JOIN activities a ON al.fkActivityId = a.id
                JOIN units u ON a.fkUnitID = u.id
                ORDER BY al.date DESC, al.id
            """)
        
        logs = cursor.fetchall()
        close_db_connection(conn)
        
        return jsonify({
            'success': True,
            'data': logs
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/activity-log', methods=['POST'])
def create_activity_log():
    """Create a new activity log entry"""
    try:
        data = request.get_json()
        activity_id = data.get('activityId')
        date = data.get('date')
        duration = data.get('duration')
        
        if not all([activity_id, date, duration]):
            return jsonify({
                'success': False,
                'error': 'Activity ID, date, and duration are required'
            }), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO activityLog (fkActivityId, date, duration) VALUES (%s, %s, %s)",
            (activity_id, date, duration)
        )
        conn.commit()
        log_id = cursor.lastrowid
        close_db_connection(conn)
        
        return jsonify({
            'success': True,
            'data': {
                'id': log_id,
                'activityId': activity_id,
                'date': date,
                'duration': duration
            }
        }), 201
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/activity-log/<int:log_id>', methods=['PUT'])
def update_activity_log(log_id):
    """Update an activity log entry"""
    try:
        data = request.get_json()
        duration = data.get('duration')
        
        if not duration:
            return jsonify({
                'success': False,
                'error': 'Duration is required'
            }), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE activityLog SET duration = %s WHERE id = %s",
            (duration, log_id)
        )
        conn.commit()
        affected = cursor.rowcount
        close_db_connection(conn)
        
        if affected == 0:
            return jsonify({
                'success': False,
                'error': 'Activity log not found'
            }), 404
        
        return jsonify({
            'success': True,
            'message': 'Activity log updated successfully'
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/activity-log/<int:log_id>', methods=['DELETE'])
def delete_activity_log(log_id):
    """Delete an activity log entry"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM activityLog WHERE id = %s", (log_id,))
        conn.commit()
        affected = cursor.rowcount
        close_db_connection(conn)
        
        if affected == 0:
            return jsonify({
                'success': False,
                'error': 'Activity log not found'
            }), 404
        
        return jsonify({
            'success': True,
            'message': 'Activity log deleted successfully'
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
