#!/bin/bash
# Deployment script for InternalWebServer to production

set -e

PROD_SERVER="andrew@192.168.2.10"
PROD_DIR="/home/andrew/web_server"

echo "=== Deploying InternalWebServer to Production ==="

# 1. Copy updated HTML files
echo "Copying HTML files..."
scp -r html/prod/* ${PROD_SERVER}:${PROD_DIR}/html/prod/

# 2. Copy backend files
echo "Copying backend files..."
ssh ${PROD_SERVER} "mkdir -p ${PROD_DIR}/backend"
scp -r backend/fitnessTracker ${PROD_SERVER}:${PROD_DIR}/backend/

# 3. Copy database structure files
echo "Copying database structure files..."
ssh ${PROD_SERVER} "mkdir -p ${PROD_DIR}/database/fitnessTracker/structure"
scp database/fitnessTracker/structure/*.sql ${PROD_SERVER}:${PROD_DIR}/database/fitnessTracker/structure/

# 4. Copy docker-compose file
echo "Copying docker-compose.yml..."
scp docker-compose.yml ${PROD_SERVER}:${PROD_DIR}/

# 5. Start/restart services on production
echo "Starting services on production..."
ssh ${PROD_SERVER} << 'ENDSSH'
cd /home/andrew/web_server

# Pull latest images
docker-compose pull

# Start MariaDB and fitness-tracker-backend
docker-compose up -d mariadb fitness-tracker-backend

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
sleep 10

# Run database setup scripts
echo "Setting up database tables..."
docker exec -i mariadb-prod mysql -u fitness_user -pfitness_password fitness_tracker_prod < database/fitnessTracker/structure/units.sql
docker exec -i mariadb-prod mysql -u fitness_user -pfitness_password fitness_tracker_prod < database/fitnessTracker/structure/activities.sql
docker exec -i mariadb-prod mysql -u fitness_user -pfitness_password fitness_tracker_prod < database/fitnessTracker/structure/activityLog.sql

# Restart nginx to pick up any config changes
docker-compose restart nginx-proxy nginx-prod

echo "Deployment complete!"
ENDSSH

echo "=== Deployment Finished ==="
echo "Access the site at: https://mitchellnet.local"
