#!/bin/bash

echo "🔍 Monitoring Docker Services"
echo "============================="

# Function to keep terminal active
keep_alive() {
    while true; do
        echo -e "\n📊 Service Status ($(date)):"
        echo "----------------------------"
        
        # Check container status
        docker-compose ps
        
        echo -e "\n🔗 API Endpoints Status:"
        
        # Test main endpoints
        curl -s http://localhost:8000/health | jq -r '.status // "ERROR"' | sed 's/^/  LLM Service: /'
        curl -s http://localhost:7871/ | jq -r '.message // "ERROR"' | sed 's/^/  Data Service: /'
        
        echo -e "\n📈 Recent Logs (last 5 lines):"
        docker-compose logs --tail=5 llm_service | sed 's/^/  /'
        
        echo -e "\n⏳ Next check in 30 seconds... (Ctrl+C to exit)"
        sleep 30
    done
}

# Start monitoring
keep_alive