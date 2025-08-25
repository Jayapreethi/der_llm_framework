import requests
import json
import time

def test_ml_operations():
    base_url = "http://localhost:8000"
    
    print("🔬 Testing ML Operations on DER Data")
    print("=" * 50)
    
    # Test 1: Basic ML Analysis
    print("\n1. Testing basic ML analysis...")
    ml_response = requests.post(f"{base_url}/ml_analysis", json={
        "interval": "1min",
        "operations": ["anomaly", "clustering"]
    })
    
    if ml_response.status_code == 200:
        result = ml_response.json()
        print(f"✅ ML Analysis completed")
        print(f"   Data size: {result['ml_analysis']['data_size_mb']} MB")
        print(f"   Operations: {result['ml_analysis']['operations_performed']}")
        
        # Print cost estimates
        costs = result['cloud_cost_estimates']
        print(f"\n💰 Cloud Cost Estimates:")
        for provider, cost_data in costs.items():
            print(f"   {provider.upper()}: ${cost_data['total_cost']} (Training + Inference)")
            print(f"      Training: {cost_data['training']['instance_type']} - ${cost_data['training']['total_cost']}")
            print(f"      Monthly: ${cost_data['monthly_estimate']}")
    else:
        print(f"❌ ML Analysis failed: {ml_response.text}")
    
    # Test 2: Cost Comparison
    print("\n2. Testing cost comparison across intervals...")
    cost_response = requests.post(f"{base_url}/cost_comparison", json={
        "intervals": ["1min", "3min"],
        "ml_operations": ["anomaly", "clustering", "predictive"]
    })
    
    if cost_response.status_code == 200:
        result = cost_response.json()
        print(f"✅ Cost comparison completed")
        
        for interval, data in result['cost_comparison'].items():
            print(f"\n📊 {interval} interval:")
            print(f"   Data size: {data['data_size_mb']} MB")
            
            # Show cost for 1 hour scenario
            hour_costs = data['cost_scenarios']['1.0h']
            cheapest = min(hour_costs.keys(), key=lambda k: hour_costs[k]['total_cost'])
            print(f"   Cheapest provider: {cheapest.upper()} (${hour_costs[cheapest]['total_cost']})")
    else:
        print(f"❌ Cost comparison failed: {cost_response.text}")
    
    # Test 3: Performance metrics
    print("\n3. Getting performance metrics...")
    metrics_response = requests.get(f"{base_url}/metrics/table")
    
    if metrics_response.status_code == 200:
        print("✅ Performance metrics retrieved")
        print(json.dumps(metrics_response.json(), indent=2))
    else:
        print(f"❌ Metrics failed: {metrics_response.text}")

if __name__ == "__main__":
    test_ml_operations()