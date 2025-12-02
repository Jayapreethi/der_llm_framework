#!/bin/bash

echo "===== DER LLM Framework Data Analysis Tests ====="
echo ""

# Test 1: Grid stability analysis  
echo "Test 1: Grid Stability Analysis (1min interval)"
curl -X POST http://localhost:8000/analyze_data \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "1min",
    "analysis_type": "grid_stability"
  }'
echo -e "\n"

# Test 2: Renewable energy integration
echo "Test 2: Renewable Energy Integration (3min interval)"
curl -X POST http://localhost:8000/analyze_data \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "3min", 
    "analysis_type": "renewable_integration"
  }'
echo -e "\n"

# Test 3: Anomaly Detection
echo "Test 3: Anomaly Detection (5min interval)"
curl -X POST http://localhost:8000/detect_anomalies \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "5min"
  }'
echo -e "\n"

# Test 4: Predictive Analysis
echo "Test 4: Predictive Analysis (1min interval)"
curl -X POST http://localhost:8000/predictive_analysis \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "1min"
  }'
echo -e "\n"

echo "===== Analysis Complete ====="
