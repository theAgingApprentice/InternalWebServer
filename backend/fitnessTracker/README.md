# Fitness Tracker - Calendar-Based Activity Logging Application

A full-stack fitness tracking web application featuring a calendar-based interface for logging and visualizing daily activities. Built with HTML/JavaScript/CSS frontend and Python Flask backend, using MariaDB for data persistence.

## Features

### User Features
- **Calendar Interface**: Monthly calendar view with navigation
- **Activity Highlighting**: Days with logged activities are highlighted in green
- **Activity Logging**: Track multiple activities per day with values and units
- **CRUD Operations**: Add, edit, and delete activity log entries
- **Activity Types**: Pre-configured activities (Walk, Plank, Wall Sits, Crunches, Push-ups) with units
- **Real-time Updates**: Calendar automatically refreshes after adding/deleting activities

### Admin Features
- **Admin Dashboard**: Dedicated admin interface for managing the fitness tracker system
- **Unit Types Management**: Add, edit, and delete unit types (e.g., Number-whole, Time, Distance)
- **Units Management**: Create and manage measurement units with specific types
- **Activities Management**: Add custom activities with configurable units and default values
- **Data Protection**: Prevents deletion of units/activities that are in use
- **Dynamic Updates**: Changes to activities immediately reflect in the main tracker interface

## Architecture

- **Frontend**: HTML/CSS/JavaScript (Vanilla JS, no frameworks)
- **Backend**: Python Flask with REST API
- **Database**: MariaDB 10.7 (dev) / 10.11 (prod)
- **Proxy**: Nginx reverse proxy
- **Containerization**: Docker Compose

## Directory Structure

```
InternalWebServer/
├── docker-compose.yml              # Production configuration
├── docker-compose.dev.yml          # Development configuration
├── deploy-to-prod.sh               # Deployment script to production server
├── backend/
│   └── fitnessTracker/
│       admin.html                  # Admin dashboard for managing activities/units
│   ├── css/
│   │   ├── style.css               # Calendar grid and activity styles
│   │   └── admin.css               # Admin interface styles
│   └── js/
│       ├── app.js                  # Calendar rendering and API calls
│       └── admin.js                # Admin dashboard functionality
│       │   └── database.py         # Database connection config
│       └── routes/
│           └── api_routes.py       # REST API endpoints
├── html/prod/fitnessTracker/
│   ├── index.html                  # Calendar-based frontend
│   ├── css/
│   │   └── style.css               # Calendar grid and activity styles
│   └── js/
│       └── app.js                  # Calendar rendering and API calls
├── database/fitnessTracker/structure/
│   ├── units.sql                   # Units table (Minutes, Meters, Laps, Reps)
│   ├── activities.sql              # Activities table with unit relationships
│   └── activityLog.sql             # Activity log entries (670+ entries)
└── nginx/
    └── conf.d/
        └── prod.conf               # Nginx proxy with API routing
```

## Environment Separation

### Development Environment (Local macOS with Docker Desktop)

The development environment runs on your local macOS machine using Docker Desktop:

- **Docker Compose**: `docker-compose.dev.yml`
- **Database**: `fitness_tracker_dev` on MariaDB 10.7
- **Backend Port**: `5001` (http://localhost:5001)
- **MariaDB Port**: `3307` (mapped from container's 3306)
- **Container Names**: `mariadb-dev`, `fitness-tracker-backend-dev`
- **Access URL**: http://mitchellnet.dev.local/fitnessTracker/
- **API URL**: http://localhost:5001/api
- **Features**:
  - Debug mode enabled (FLASK_DEBUG=1)
  - Live code reloading via volume mounts
  - Separate test data from production

### Production Environment (Ubuntu Server at 192.168.2.10)

The production environment runs on a dedicated Ubuntu 24.04.2 LTS server:

- **Server**: andrew@192.168.2.10 (2019 iMac server)
- **Docker Compose**: `docker-compose.yml`
- **Database**: `fitness_tracker_prod` on MariaDB 10.7
- **Backend Port**: `5000` (internal only)
- **MariaDB Port**: `3306` (internal only)
- **Container Names**: `mariadb-prod`, `fitness-tracker-backend-prod`
- **Access URL**: https://mitchellnet.local/fitnessTracker/
- **API URL**: https://mitchellnet.local/api (proxied through nginx)
- **Features**:
  - Debug mode disabled
  - Read-only volume mounts for code
  - SSL/TLS termination at nginx proxy
  - API requests proxied through nginx (no direct backend access)

**Important**: Development and production use **separate databases** to ensure test data never overwrites production data.

## Setup Instructions

### 1. Database Setup

The fitness tracker uses a structured database schema with three tables:

1. **units** - Measurement units (Minutes, Meters, Laps, Reps)
2. **activities** - Activity types (Swimming, Cycling, Running, Gym, Walking)
3. **activityLog** - Daily activity entries with values

**Development Database Setup:**

```bash
# Start MariaDB container
docker-compose -f docker-compose.dev.yml up -d mariadb

# Wait for MariaDB to be ready (about 10 seconds)
sleep 10

# Run SQL scripts in order
docker exec -i mariadb-dev mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_dev < database/fitnessTracker/structure/units.sql
docker exec -i mariadb-dev mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_dev < database/fitnessTracker/structure/activities.sql
docker exec -i mariadb-dev mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_dev < database/fitnessTracker/structure/activityLog.sql
```

**Verify Data Load:**
```bash
# Should return 670
docker exec mariadb-dev mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_dev -e "SELECT COUNT(*) FROM activityLog;"
```

### 2. Development Setup

Start the complete development environment:

```bash
# Start all services
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f fitness-tracker-backend
```

Access the app:
- **Frontend**: http://mitchellnet.dev.local/fitnessTracker/
- **Backend API**: http://localhost:5001/api
- **Health Check**: http://localhost:5001/api/health

The frontend will automatically detect the dev environment and use `http://localhost:5001/api` for API calls.

### 3. Production Deployment

**Option A: Automated Deployment Script**

Use the provided deployment script to sync all files to production:

```bash
./deploy-to-prod.sh
```

This script will:
1. Copy updated HTML/CSS/JS files to production server
2. Copy backend Python code to production server
3. Copy database SQL files to production server
4. Copy docker-compose.yml to production server
5. Pull latest Docker images
6. Start mariadb-prod and fitness-tracker-backend-prod containers
7. Run database setup scripts
8. Restart nginx containers

**Option B: Manual Deployment**

SSH to production server and set up manually:

```bash
# SSH to production server
ssh andrew@192.168.2.10

# Navigate to web server directory
cd /home/andrew/web_server

# Pull/copy latest code (deployment method varies - see notes below)

# Start containers
docker-compose up -d mariadb fitness-tracker-backend

# Wait for MariaDB
sleep 10

# Run database scripts
docker exec -i mariadb-prod mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_prod < database/fitnessTracker/structure/units.sql
docker exec -i mariadb-prod mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_prod < database/fitnessTracker/structure/activities.sql
docker exec -i mariadb-prod mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_prod < database/fitnessTracker/structure/activityLog.sql

# Restart nginx to pick up changes
docker-compose restart nginx-proxy nginx-prod
```

**Note**: The production server directory `/home/andrew/web_server` is NOT a git repository. Files must be copied via SCP or rsync.

Access the production app:
- **Frontend**: https://mitchellnet.local/fitnessTracker/
- **API**: https://mitchellnet.local/api (proxied through nginx)

## API Endpoints

### Health Check
```
GET /api/health
```
Returns backend health status and database connection info.

### Public Endpoints

#### Get All Activities
```
GET /api/activities
```
Returns all available activities with their associated units.

**Response Example:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Walk",
      "default_amt": 30,
      "fkUnitID": 3,
      "unit_name": "Time-Minutes",
      "unit_type": "Number-whole"
    }
  ]
}
```

### Activity Log - Get Dates with Activities
```
GET /api/activity-log?month=YYYY-MM
```
Returns array of dates (YYYY-MM-DD) that have logged activities for the specified month.

**Response Example:**
```json
{
  "success": true,
  "data": ["2025-12-01", "2025-12-03", "2025-12-15"]
}
```

### Activity Log - Get Activities for a Date
```
GET /api/activity-log?date=YYYY-MM-DD
```
Returns all logged activities for a specific date.

**Response Example:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "date": "2025-12-15",
      "fkActivityId": 1,
      "activity_name": "Walk",
      "unit_name": "Time-Minutes",
      "duration": 30
    }
  ]
}
```

### Activity Log - Create Entry
```
POST /api/activity-log
Content-Type: application/json
```

**Request Body:**
```json
{
  "activityId": 1,
  "date": "2025-12-22",
  "duration": 25
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 671,
    "activityId": 1,
    "date": "2025-12-22",
    "duration": 25
  }
}
```

### Activity Log - Update Entry
```
PUT /api/activity-log/<id>
Content-Type: application/json
```

**Request Body:**
```json
{
  "duration": 45
}
```

### Activity Log - Delete Entry
```
DELETE /api/activity-log/<id>
```

### Admin Endpoints

#### Unit Types Management

**Get All Unit Types**
```
GET /api/admin/unit-types
```
Returns all unique unit types currently in use.

**Response Example:**
```json
{
  "success": true,
  "data": ["Number-whole", "Time", "Distance"]
}
```

**Add Unit Type**
```
POST /api/admin/unit-types
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Weight"
}
```

**Delete Unit Type**
```
DELETE /api/admin/unit-types/<type_name>
```
Only succeeds if no units are using this type.

#### Units Management

**Get All Units**
```
GET /api/admin/units
```

**Response Example:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Count",
      "unit": "Number-whole"
    }
  ]
}
```

**Create Unit**
```
POST /api/admin/units
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Distance-Kilometers",
  "unit": "Distance"
}
```

**Update Unit**
```
PUT /api/admin/units/<id>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Distance-Kilometers",
  "unit": "Distance"
}
```

**Delete Unit**
```
DELETE /api/admin/units/<id>
```
Only succeeds if no activities are using this unit.

#### Activities Management

**Create Activity**
```
POST /api/admin/activities
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Squats",
  "unitId": 1,
  "defaultAmt": 20
}
```

**Update Activity**
```
PUT /api/admin/activities/<id>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Squats",
  "unitId": 1,
  "defaultAmt": 25
}
```

**Delete Activity**
```
DELETE /api/admin/activities/<id>
```
Only succeeds if no activity log entries exist for this activity.

**Request Body:**
```json
{
  "value": 30
}
```

**Response:**
```json
{
  "success": true
}
```

### Activity Log - Delete Entry
```
DELETE /api/activity-log/<id>
```

**Response:**
```json
{
  "success": true
}
```

## Common Commands

### View Container Logs
```bash
# Development - Backend
docker-compose -f docker-compose.dev.yml logs -f fitness-tracker-backend

# Development - Database
docker-compose -f docker-compose.dev.yml logs -f mariadb

# Production - Backend (on server)
ssh andrew@192.168.2.10 "docker logs -f fitness-tracker-backend-prod"

# Production - Database (on server)
ssh andrew@192.168.2.10 "docker logs -f mariadb-prod"
```

### Access Database Console
```bash
# Development
docker exec -it mariadb-dev mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_dev

# Production (via SSH)
ssh andrew@192.168.2.10
docker exec -it mariadb-prod mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_prod
```

### Useful Database Queries
```sql
-- Count total activity log entries
SELECT COUNT(*) FROM activityLog;

-- View all activities
SELECT * FROM activities;

-- Get activity log for specific date
SELECT al.*, a.name as activity_name, u.name as unit
FROM activityLog al
JOIN activities a ON al.activity_id = a.id
JOIN units u ON a.unit_id = u.id
WHERE al.date = '2025-12-15';

-- Count activities by type
SELECT a.name, COUNT(*) as count
FROM activityLog al
JOIN activities a ON al.activity_id = a.id
GROUP BY a.name;
```

### Rebuild Backend Container
```bash
# Development
docker-compose -f docker-compose.dev.yml build fitness-tracker-backend
docker-compose -f docker-compose.dev.yml up -d fitness-tracker-backend

# Production (via SSH)
ssh andrew@192.168.2.10
cd /home/andrew/web_server
docker-compose build fitness-tracker-backend
docker-compose up -d fitness-tracker-backend
```

### Restart Services
```bash
# Development - Restart backend only
docker-compose -f docker-compose.dev.yml restart fitness-tracker-backend

# Production - Restart all fitness tracker services (via SSH)
ssh andrew@192.168.2.10 "cd /home/andrew/web_server && docker-compose restart mariadb-prod fitness-tracker-backend-prod nginx-proxy"
```

### Stop Services
```bash
# Development - Stop all
docker-compose -f docker-compose.dev.yml down

# Development - Stop specific service
docker-compose -f docker-compose.dev.yml stop fitness-tracker-backend

# Production - Stop fitness tracker services (via SSH)
ssh andrew@192.168.2.10 "cd /home/andrew/web_server && docker-compose stop mariadb-prod fitness-tracker-backend-prod"
```

### Check Running Containers
```bash
# Development
docker ps | grep -E '(mariadb-dev|fitness-tracker-backend-dev)'

# Production (via SSH)
ssh andrew@192.168.2.10 "docker ps | grep -E '(mariadb-prod|fitness-tracker-backend-prod)'"
```

## Development Workflow

1. **Make code changes** in your local development environment
   - Backend: `backend/fitnessTracker/`
   - Frontend: `html/prod/fitnessTracker/`
   - Database: `database/fitnessTracker/structure/`

2. **Test locally** using development environment
   ```bash
   # Restart backend if needed (Flask auto-reloads with FLASK_DEBUG=1)
   docker-compose -f docker-compose.dev.yml restart fitness-tracker-backend
   
   # Frontend changes: Just refresh browser
   ```

3. **Verify changes** at http://mitchellnet.dev.local/fitnessTracker/

4. **Deploy to production** when ready
   ```bash
   ./deploy-to-prod.sh
   ```

5. **Test production** at https://mitchellnet.local/fitnessTracker/

### Frontend Environment Detection

The frontend JavaScript (`app.js`) automatically detects the environment:

```javascript
const isDevEnv = /mitchellnet\.dev\.local$/i.test(window.location.hostname) || 
                 window.location.hostname === 'localhost';
const API_BASE_URL = isDevEnv
    ? 'http://localhost:5001/api'  // Development - direct backend access
    : '/api';                       // Production - nginx proxy
```

This means:
- **Development**: API calls go directly to `http://localhost:5001/api`
- **Production**: API calls use relative path `/api` (proxied through nginx to backend)

## Nginx Configuration

### Production API Proxy Setup

The production nginx configuration (`nginx/conf.d/prod.conf`) includes API proxying:

```nginx
# API proxy to fitness tracker backend
location /api/ {
    proxy_pass http://fitness-tracker-backend-prod:5000/api/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

# Frontend static files
location / {
    ssi on;
    proxy_set_header Accept-Encoding "";
    proxy_pass http://nginx-prod;
    add_header X-Upstream production;
}
```

**Important**: This configuration:
- Routes `/api/*` requests to the backend container
- Prevents CORS issues by keeping all requests on the same origin
- Adds proper proxy headers for request tracking
- The backend is NOT directly accessible from outside the Docker network

### Development Nginx Configuration

In development, the proxy configuration in `proxy/default.conf` handles routing to the dev containers.

## Troubleshooting

### Backend won't start
```bash
# Check logs
docker-compose -f docker-compose.dev.yml logs fitness-tracker-backend

# Common issues:
# 1. Database not running
docker ps | grep mariadb

# 2. Port already in use
lsof -i :5001  # For development
lsof -i :5000  # For production

# 3. Python dependencies missing
docker-compose -f docker-compose.dev.yml build --no-cache fitness-tracker-backend
```

### Database connection failed
```bash
# Verify MariaDB is running and healthy
docker ps | grep mariadb

# Check database exists
docker exec mariadb-dev mysql -u ${DB_USER} -p"${DB_PASSWORD}" -e "SHOW DATABASES;"

# Test connection from backend container
docker exec fitness-tracker-backend-dev python -c "from config.database import get_db_connection; print(get_db_connection())"
```

### Frontend can't reach API

**Development:**
```bash
# Test backend health
curl http://localhost:5001/api/health

# Check CORS headers
curl -H "Origin: http://mitchellnet.dev.local" -v http://localhost:5001/api/health

# Verify API_BASE_URL in browser console
# Should show: http://localhost:5001/api
```

**Production:**
```bash
# Test from production server
ssh andrew@192.168.2.10 "curl http://localhost:5000/api/health"

# Test through nginx proxy
curl https://mitchellnet.local/api/health

# Check nginx configuration
ssh andrew@192.168.2.10 "cat /home/andrew/web_server/nginx/conf.d/prod.conf"

# Verify API_BASE_URL in browser console
# Should show: /api
```

### Calendar not showing activity highlights

```bash
# Check if data exists in database
docker exec mariadb-dev mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_dev -e "SELECT COUNT(*) FROM activityLog;"

# Test month query endpoint
curl "http://localhost:5001/api/activity-log?month=2025-12"

# Check browser console for errors
# Look for: "Error loading active dates"
```

### CORS errors in production

If you see CORS errors in production:
1. Verify nginx proxy is routing `/api/` correctly
2. Check that app.js uses relative path `/api` for production
3. Restart nginx-proxy container:
   ```bash
   ssh andrew@192.168.2.10 "docker restart nginx-proxy"
   ```

### Date formatting issues

The backend uses parameterized queries for date formatting:
```python
# Correct (in api_routes.py)
cursor.execute("""
    SELECT DISTINCT DATE_FORMAT(date, %s) as date 
    FROM activityLog 
    WHERE DATE_FORMAT(date, %s) = %s
""", ('%Y-%m-%d', '%Y-%m', month))

# Incorrect - DO NOT USE %%Y-%%m-%%d with mysql-connector-python
```

## Database Schema

### Units Table
```sql
CREATE TABLE units (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);
```

**Data:**
- Minutes
- Meters
- Laps
- Reps

### Activities Table
```sql
CREATE TABLE activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unit_id INT NOT NULL,
    FOREIGN KEY (unit_id) REFERENCES units(id)
);
```

**Data:**
- Swimming (Laps)
- Cycling (Minutes)
- Running (Meters)
- Gym (Reps)
- Walking (Meters)

### Activity Log Table
```sql
CREATE TABLE activityLog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    activity_id INT NOT NULL,
    value INT NOT NULL,
    FOREIGN KEY (activity_id) REFERENCES activities(id),
    INDEX idx_date (date)
);
```

**Sample Data:** 670+ activity log entries spanning multiple months

## Security Notes

### Current Setup
- Uses HTTP in development, HTTPS in production
- Self-signed SSL certificate in production
- Database credentials configured in docker-compose files
- Backend only accessible through nginx proxy in production
- No authentication/authorization currently implemented

### Production Recommendations
1. **SSL Certificate**: Replace self-signed certificate with proper CA-signed certificate
2. **Database Passwords**: Use strong passwords in production
3. **Authentication**: Add user authentication to protect activity data
4. **API Security**: Consider adding API key or JWT authentication
5. **Network Isolation**: Backend containers not directly exposed outside Docker network
6. **CORS Settings**: Currently allows all origins in development, restricted in production via nginx

### Backup Strategy

**Development:**
```bash
# Backup dev database
docker exec mariadb-dev mysqldump -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_dev > backup_dev_$(date +%Y%m%d).sql

# Restore dev database
docker exec -i mariadb-dev mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_dev < backup_dev_20251222.sql
```

**Production:**
```bash
# Backup production database (via SSH)
ssh andrew@192.168.2.10 "docker exec mariadb-prod mysqldump -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_prod" > backup_prod_$(date +%Y%m%d).sql

# Restore production database (via SSH)
cat backup_prod_20251222.sql | ssh andrew@192.168.2.10 "docker exec -i mariadb-prod mysql -u ${DB_USER} -p"${DB_PASSWORD}" fitness_tracker_prod"
```

## Technology Stack

### Backend
- **Language**: Python 3.11
- **Framework**: Flask 3.0.0
- **Database Driver**: mysql-connector-python 8.2.0
- **CORS**: Flask-CORS 4.0.0
- **Environment**: python-dotenv 1.0.0

### Frontend
- **Languages**: HTML5, CSS3, JavaScript (ES6+)
- **Styling**: Custom CSS with CSS Grid for calendar layout
- **API Communication**: Fetch API
- **No frameworks**: Pure vanilla JavaScript

### Database
- **Development**: MariaDB 10.7
- **Production**: MariaDB 10.7
- **Data Persistence**: Docker volumes (`mariadb_dev_data`, `mariadb_prod_data`)

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Reverse Proxy**: Nginx 1.29
- **Development Platform**: macOS with Docker Desktop
- **Production Platform**: Ubuntu 24.04.2 LTS

## Browser Compatibility

The application uses modern JavaScript features:
- Fetch API
- Template Literals
- Arrow Functions
- Async/Await
- CSS Grid

**Recommended Browsers:**
- Chrome/Edge 90+
- Firefox 88+
- Safari 14+

## Performance Notes

- Calendar loads activities for current month only
- Database queries use indexed date column
- Activities and units cached in frontend after initial load
- API responses are lightweight JSON
- Static assets served directly by nginx

## Known Limitations

1. **No User Authentication**: Activity data is accessible to anyone with network access
2. **Single Database**: All activity data in one database (not multi-tenant)
3. **No Data Export**: Must export manually via database tools
4. **No Activity Graphs**: Only calendar view and daily lists
5. **Mobile Responsive**: Basic responsiveness, optimized for desktop
6. **Time Zone**: Uses server's time zone, no user time zone selection

## Future Enhancements

Potential improvements:
- User authentication and authorization
- Activity graphs and statistics
- Data export (CSV, PDF)
- Mobile-optimized responsive design
- User time zone support
- Activity goals and tracking
- Custom activity types
- Dark mode theme
- Progressive Web App (PWA) support

## Version History

- **V2.0** (December 2025) - Calendar-based interface with activity logging
  - Complete redesign from item tracker to fitness tracker
  - Calendar grid view with monthly navigation
  - Activity highlighting and CRUD operations
  - Database restructure with units, activities, and activityLog tables
  - 670+ sample activity entries

- **V1.0** (Earlier) - Basic item tracker
  - Simple item list management
  - Add/delete items functionality

## Support & Documentation

- **Flask**: https://flask.palletsprojects.com/
- **MariaDB**: https://mariadb.org/documentation/
- **Docker Compose**: https://docs.docker.com/compose/
- **Nginx**: https://nginx.org/en/docs/

## License

See LICENSE file in the repository root.

## Contributing

This is a personal project. For questions or issues, contact the repository owner.
