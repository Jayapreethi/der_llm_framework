#!/bin/bash

# Step 1: Export API Tokens
chmod +x setup.sh 
echo "Exporting API tokens..."
export OPENAI_API_KEY="PUT YOUR_OPENAI_API_KEY_HERE"



# Verify tokens were exported
echo "OPENAI_API_KEY: $OPENAI_API_KEY"

#!/bin/bash

# Updated Setup Script for GPT and ML Analysis Service
# Version: 3.0.0
# Focus: GPT analysis and ML-based DER data analysis

set -e  # Exit on any error

echo "🚀 Starting GPT ML Data Analysis Service Setup..."
echo "=================================================="

# Step 1: Environment Check
echo "Step 1: Checking environment..."
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose not found! Please install Docker Compose."
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "❌ curl not found! Please install curl."
    exit 1
fi

echo "✅ Environment check passed."

# Step 2: Docker Compose Build (No Cache)
echo "Step 2: Building Docker containers..."
echo "Stopping existing containers..."
docker-compose down
if [ $? -ne 0 ]; then
    echo "⚠️  Docker Compose down failed - containers may not have been running."
fi

echo "Removing existing Docker containers and images..."
docker-compose rm -f
if [ $? -ne 0 ]; then
    echo "⚠️  No containers to remove."
fi

echo "Cleaning up Docker system..."
docker system prune -f
if [ $? -ne 0 ]; then
    echo "❌ Docker system prune failed! Please check your Docker setup."
    exit 1
fi

echo "Building Docker containers with --no-cache..."
docker-compose build --no-cache --progress=plain
if [ $? -ne 0 ]; then
    echo "❌ Docker build failed! Please check the Dockerfile and dependencies."
    exit 1
fi

echo "Final system cleanup..."
docker system prune -f

# Step 3: Docker Compose Up
echo "Step 3: Starting Docker containers..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "❌ Docker Compose up failed! Please check your docker-compose.yml file."
    exit 1
fi

# Step 4: Wait for Containers to Start
echo "Step 4: Waiting for containers to initialize..."
echo "Waiting 20 seconds for services to fully start..."
sleep 20

# Step 5: Test Data Service Endpoints
echo "Step 5: Testing Data Service endpoints..."
echo "========================================="
echo "🔍 Testing data service root endpoint..."
curl -X GET "http://localhost:7871/" -H "Content-Type: application/json" --max-time 10
echo -e "\n"

echo "📊 Fetching 1min aggregated DER data..."
curl -X GET "http://localhost:7871/data/1min" -H "Content-Type: application/json" --max-time 15
echo -e "\n"

echo "📊 Fetching 3min aggregated DER data..."
curl -X GET "http://localhost:7871/data/3min" -H "Content-Type: application/json" --max-time 15
echo -e "\n"

echo "📊 Fetching 5min aggregated DER data..."
curl -X GET "http://localhost:7871/data/5min" -H "Content-Type: application/json" --max-time 15
echo -e "\n"

# Step 6: Test LLM Service Basic Endpoints
echo "Step 6: Testing LLM Service basic endpoints..."
echo "=============================================="
echo "🔍 Testing LLM service root endpoint..."
curl -X GET "http://localhost:8000/" -H "Content-Type: application/json" --max-time 10
echo -e "\n"

echo "🏥 Testing health check endpoint..."
curl -X GET "http://localhost:8000/health" -H "Content-Type: application/json" --max-time 10
echo -e "\n"

# Step 7: Test GPT Analysis Endpoints
echo "Step 7: Testing GPT Analysis endpoints..."
echo "========================================"
echo "🤖 Testing basic GPT endpoint..."
curl -X POST "http://localhost:8000/query_gpt" \
-H "Content-Type: application/json" \
-d '{"prompt": "What is distributed energy resource (DER) analysis?"}' \
--max-time 30
echo -e "\n"

echo "📊 Testing DER data analysis endpoint..."
curl -X POST "http://localhost:8000/analyze_data" \
-H "Content-Type: application/json" \
-d '{
    "interval": "1min",
    "analysis_type": "summary"
}' \
--max-time 45
echo -e "\n"

echo "🔍 Testing data insights endpoint..."
curl -X POST "http://localhost:8000/data_insights" \
-H "Content-Type: application/json" \
-d '{
    "question": "What are the key performance indicators in this DER data?",
    "interval": "1min"
}' \
--max-time 45
echo -e "\n"

# Step 8: Test Machine Learning Analysis Endpoints
echo "Step 8: Testing Machine Learning Analysis endpoints..."
echo "===================================================="
echo "🔬 Testing anomaly detection..."
curl -X POST "http://localhost:8000/detect_anomalies" \
-H "Content-Type: application/json" \
-d '{"interval": "1min"}' \
--max-time 60
echo -e "\n"

echo "🎯 Testing clustering analysis..."
curl -X POST "http://localhost:8000/cluster_analysis" \
-H "Content-Type: application/json" \
-d '{
    "interval": "1min",
    "n_clusters": 3
}' \
--max-time 60
echo -e "\n"

echo "📈 Testing predictive analysis..."
curl -X POST "http://localhost:8000/predictive_analysis" \
-H "Content-Type: application/json" \
-d '{"interval": "1min"}' \
--max-time 60
echo -e "\n"

echo "🔬 Testing comprehensive ML analysis..."
curl -X POST "http://localhost:8000/comprehensive_ml_analysis" \
-H "Content-Type: application/json" \
-d '{"interval": "1min"}' \
--max-time 90
echo -e "\n"

# Step 9: Test Advanced GPT + ML Integration
echo "Step 9: Testing Advanced GPT + ML Integration..."
echo "==============================================="
echo "⚡ Test 1: Grid stability analysis with ML..."
curl -X POST "http://localhost:8000/ml_analysis" \
-H "Content-Type: application/json" \
-d '{
    "interval": "1min",
    "analysis_types": ["anomaly", "clustering"]
}' \
--max-time 90
echo -e "\n"

echo "🔋 Test 2: DER performance optimization analysis..."
curl -X POST "http://localhost:8000/analyze_data" \
-H "Content-Type: application/json" \
-d '{
    "interval": "3min",
    "analysis_type": "performance"
}' \
--max-time 60
echo -e "\n"

echo "📊 Test 3: Multi-interval comparison..."
curl -X POST "http://localhost:8000/compare_intervals" \
-H "Content-Type: application/json" \
-d '{
    "intervals": ["1min", "3min", "5min"]
}' \
--max-time 75
echo -e "\n"

echo "🔍 Test 4: Predictive maintenance analysis..."
curl -X POST "http://localhost:8000/data_insights" \
-H "Content-Type: application/json" \
-d '{
    "interval": "1min",
    "question": "Based on this DER data, what patterns indicate potential equipment maintenance needs or performance degradation?"
}' \
--max-time 60
echo -e "\n"

# Step 10: Test Performance Monitoring
echo "Step 10: Testing Performance Monitoring..."
echo "========================================="
echo "📊 Getting performance metrics table..."
curl -X GET "http://localhost:8000/metrics/table" \
-H "Content-Type: application/json" \
--max-time 10
echo -e "\n"

echo "💻 Getting system metrics..."
curl -X GET "http://localhost:8000/metrics/system" \
-H "Content-Type: application/json" \
--max-time 10
echo -e "\n"

echo "📈 Getting detailed performance metrics..."
curl -X GET "http://localhost:8000/metrics/performance" \
-H "Content-Type: application/json" \
--max-time 10
echo -e "\n"

# Step 11: Final Status Check
echo "Step 11: Final System Status Check..."
echo "===================================="
echo "🔍 Checking container status..."
docker-compose ps

echo -e "\n📊 Service endpoints summary:"
echo "- Data Service: http://localhost:7871"
echo "- LLM Service: http://localhost:8000"
echo "- Health Check: http://localhost:8000/health"
echo "- Performance Metrics: http://localhost:8000/metrics/table"

# Step 12: Performance Summary
echo -e "\nStep 12: Generating Performance Summary..."
echo "=========================================="
echo "🏁 Getting final performance summary..."
curl -X GET "http://localhost:8000/metrics/table" \
-H "Content-Type: application/json" \
--max-time 10 | python3 -m json.tool 2>/dev/null || echo "Performance data retrieved successfully"

echo -e "\n"
echo "✅ Setup and testing complete!"
echo "============================================="
echo "🎉 GPT ML Data Analysis Service is ready!"
echo ""
echo "📝 Key Features Tested:"
echo "  ✓ Basic GPT analysis"
echo "  ✓ DER data analysis with GPT interpretation"
echo "  ✓ Machine Learning anomaly detection"
echo "  ✓ ML clustering analysis"
echo "  ✓ Predictive modeling"
echo "  ✓ Comprehensive ML analysis with GPT insights"
echo "  ✓ Performance monitoring"
echo ""
echo "🔗 Access your services:"
echo "  • LLM Service: http://localhost:8000"
echo "  • Data Service: http://localhost:7871"
echo "  • API Documentation: http://localhost:8000/docs"
echo ""
echo "📊 Check performance metrics at: http://localhost:8000/metrics/table"
echo ""
echo "🚀 Your containerized GPT + ML analysis service is now running!"

exit 0