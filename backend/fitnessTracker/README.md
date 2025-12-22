# Fitness Tracker - Full Stack Application Setup

This is a full-stack fitness tracking web application with HTML/JavaScript/CSS frontend and Python Flask backend, using MariaDB for data persistence.

## Architecture

- **Frontend**: HTML/CSS/JavaScript (Vanilla JS, no frameworks)
- **Backend**: Python Flask with REST API
- **Database**: MariaDB 10.7
- **Proxy**: Nginx reverse proxy
- **Containerization**: Docker Compose

## Directory Structure

```
InternalWebServer/
├── docker-compose.yml              # Production configuration
├── docker-compose.dev.yml          # Development configuration
├── backend/
│   └── fitnessTracker/
│       ├── Dockerfile              # Python backend container
│       ├── app.py                  # Main Flask application
│       ├── requirements.txt        # Python dependencies
│       ├── .env.example            # Environment variables template
│       ├── config/
│       │   └── database.py         # Database connection config
│       ├── routes/
│       │   └── api_routes.py       # API endpoints
│       └── models/                 # Database models (add as needed)
├── html/prod/fitnessTracker/
│   ├── index.html                  # Main frontend page
│   ├── css/
│   │   └── style.css               # Styles
│   ├── js/
│   │   └── app.js                  # Frontend JavaScript
│   └── assets/                     # Images, etc.
└── database/
    └── migrations/
        └── 01_create_items_table.sql  # Database schema

```

## Environment Separation

### Development vs Production

The setup uses **separate databases** for development and production:

- **Development** (`docker-compose.dev.yml`):
  - Database: `fitness_tracker_dev`
  - Backend Port: `5001`
  - MariaDB Port: `3307` (mapped from container's 3306)
  - Debug mode enabled
  - Live code reloading

- **Production** (`docker-compose.yml`):
  - Database: `fitness_tracker_prod`
  - Backend Port: `5000`
  - MariaDB Port: `3306`
  - Debug mode disabled
  - Read-only volumes

This ensures **test data never overwrites production data**.

## Setup Instructions

### 1. Environment Variables

Create a `.env` file in the `backend/fitnessTracker/` directory (copy from `.env.example`):

```bash
cp backend/fitnessTracker/.env.example backend/fitnessTracker/.env
```

Edit `.env` with your desired credentials:
```env
DB_ROOT_PASSWORD=your_secure_password
DB_USER=fitness_user
DB_PASSWORD=your_app_password
ENVIRONMENT=development
```

### 2. Development Setup

Start the development environment:

```bash
docker-compose -f docker-compose.dev.yml up -d
```

This will:
- Start MariaDB with `fitness_tracker_dev` database
- Run database migrations automatically
- Start Python backend on port 5001
- Start nginx proxy

Access the app:
- Frontend: http://localhost/fitnessTracker/
- Backend API: http://localhost:5001/api
- Health Check: http://localhost:5001/api/health

### 3. Production Setup

Start the production environment:

```bash
docker-compose up -d
```

This will:
- Start MariaDB with `fitness_tracker_prod` database
- Run database migrations automatically
- Start Python backend on port 5000
- Start nginx proxy with SSL

Access the app:
- Frontend: https://your-domain.com/fitnessTracker/
- Backend API: http://localhost:5000/api

### 4. Database Migrations

Database migrations are automatically run when the MariaDB container starts. Place SQL files in `database/migrations/` and they will be executed in alphabetical order.

Example migration file naming:
- `01_create_items_table.sql`
- `02_add_users_table.sql`
- `03_add_indexes.sql`

## API Endpoints

### Health Check
```
GET /api/health
```

### Items
```
GET    /api/items         # Get all items
POST   /api/items         # Create new item
DELETE /api/items/:id     # Delete item by ID
```

Example POST request:
```json
{
  "name": "My Item",
  "description": "Item description"
}
```

## Common Commands

### View Logs
```bash
# Development
docker-compose -f docker-compose.dev.yml logs -f fitness-tracker-backend

# Production
docker-compose logs -f fitness-tracker-backend
```

### Access Database
```bash
# Development
docker exec -it mariadb-dev mysql -u fitness_user -pfitness_password fitness_tracker_dev

# Production
docker exec -it mariadb-prod mysql -u fitness_user -pfitness_password fitness_tracker_prod
```

### Rebuild Backend
```bash
# Development
docker-compose -f docker-compose.dev.yml build fitness-tracker-backend
docker-compose -f docker-compose.dev.yml up -d

# Production
docker-compose build fitness-tracker-backend
docker-compose up -d
```

### Stop Everything
```bash
# Development
docker-compose -f docker-compose.dev.yml down

# Production
docker-compose down
```

### Remove Volumes (CAUTION: Deletes all data)
```bash
# Development
docker-compose -f docker-compose.dev.yml down -v

# Production
docker-compose down -v
```

## Development Workflow

1. **Make changes** to your code in `backend/fitnessTracker/` or `html/prod/fitnessTracker/`
2. **Backend changes**: Restart the container (changes auto-reload if FLASK_DEBUG=1)
3. **Frontend changes**: Refresh your browser (no restart needed)
4. **Database changes**: Add a new migration file in `database/migrations/`

## Nginx Configuration

To make the app accessible via nginx proxy, add to your nginx configuration:

```nginx
# In nginx/conf.d/prod.conf or appropriate config file

location /fitnessTracker/ {
    alias /usr/share/nginx/html/fitnessTracker/;
    index index.html;
}

location /api/ {
    proxy_pass http://fitness-tracker-backend:5000/api/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

## Troubleshooting

### Backend won't start
- Check logs: `docker-compose logs myapp-backend`
- Verify database is running: `docker ps | grep mariadb`
- Check environment variables in `.env`

### Database connection failed
- Ensure MariaDB container is healthy
- Verify credentials in environment variables
- Check that database name matches (fitness_tracker_dev or fitness_tracker_prod)

### Frontend can't reach API
- Verify backend is running: `curl http://localhost:5001/api/health`
- Check CORS settings in backend
- Verify API_BASE_URL in frontend JavaScript

## Security Notes

For production:
1. Change all default passwords in `.env`
2. Use strong passwords for database
3. Enable HTTPS with proper SSL certificates
4. Consider adding authentication to API endpoints
5. Review and restrict CORS settings
6. Never commit `.env` file to git (it's in `.gitignore`)

## Next Steps

1. Customize the app for your use case
2. Add authentication/authorization
3. Implement additional API endpoints
4. Add more frontend features
5. Set up automated backups for production database
6. Configure CI/CD pipeline

## Support

For issues or questions, refer to:
- Flask documentation: https://flask.palletsprojects.com/
- MariaDB documentation: https://mariadb.org/documentation/
- Docker Compose documentation: https://docs.docker.com/compose/
