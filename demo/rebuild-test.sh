# Stop services
docker-compose down

# Rebuild with new endpoints
docker-compose build --no-cache llm_service

# Start services
docker-compose up -d

# Wait for startup
sleep 10

# Make test scripts executable
chmod +x monitor_services.sh test_working_endpoints.sh

# Test working endpoints
./test_working_endpoints.sh

# Start monitoring (in background or new terminal)
./monitor_services.sh