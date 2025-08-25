# Test 1: Grid stability analysis  
curl -X POST http://localhost:8000/analyze_energy_data \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "1min",
    "question": "Analyze this data for grid stability indicators. Look for frequency variations, voltage irregularities, and power quality issues.",
    "model": "gpt"
  }'

# Test 2: Renewable energy integration
curl -X POST http://localhost:8000/analyze_energy_data \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "3min", 
    "question": "Assuming this is renewable energy data, analyze the variability patterns and suggest grid integration strategies.",
    "model": "gpt"
  }'

# Test 3: Demand response opportunities
curl -X POST http://localhost:8000/analyze_energy_data \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "5min",
    "question": "Identify potential demand response opportunities and times when energy consumption could be shifted for better grid balance.",
    "model": "gpt"
  }'

# Test 4: Predictive maintenance indicators
curl -X POST http://localhost:8000/analyze_energy_data \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "1min",
    "question": "Look for patterns that might indicate equipment maintenance needs or performance degradation in this energy system.",
    "model": "gpt"
  }'
