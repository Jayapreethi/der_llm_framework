#!/bin/bash
# filepath: /Users/moha907/Library/CloudStorage/OneDrive-PNNL/Documents/PhD/cloud/fastapi_llm/check_status.sh
# Enhanced status check script

echo "=== Docker Container Status ==="
if ! docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; then
    echo "❌ Failed to retrieve Docker container status. Is Docker running?"
    exit 1
fi

echo -e "\n=== Testing Services ==="
# Test data service
if curl -s http://localhost:7871/ > /dev/null; then
    echo "✅ Data Service: Running"
else
    echo "❌ Data Service: Not responding. Check if the container is running."
fi

# Test LLM service
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ LLM Service: Running"
else
    echo "❌ LLM Service: Not responding. Check if the container is running."
fi

echo -e "\n=== Recent Logs ==="
if ! docker-compose logs --tail=5 llm_service; then
    echo "❌ Failed to retrieve logs. Ensure docker-compose is installed and configured."
fi