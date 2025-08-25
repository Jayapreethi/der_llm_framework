#!/bin/bash

echo "🧪 Testing Working Endpoints"
echo "=========================="

# Test basic endpoints
echo "1. Testing health check..."
curl -s http://localhost:8000/health | jq '.'

echo -e "\n2. Testing GPT (working)..."
curl -X POST http://localhost:8000/query_gpt \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is renewable energy?", "max_tokens": 100}' | jq '.response'

echo -e "\n3. Testing data summary..."
curl -s http://localhost:8000/data_summary/1min | jq '.'

echo -e "\n4. Testing energy data analysis..."
curl -X POST http://localhost:8000/analyze_energy_data \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "1min",
    "question": "What patterns do you see in this energy data?",
    "model": "gpt"
  }' | jq '.analysis'

echo -e "\n✅ Testing complete!"