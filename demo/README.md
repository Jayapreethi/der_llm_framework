# DER LLM Framework - Demo

GPT-powered ML Data Analysis Service for Distributed Energy Resources

## Prerequisites

- Docker Desktop (running)
- PowerShell (Windows)
- OpenAI API Key

## Quick Start

### 1. Setup Environment

```powershell
# Set your OpenAI API key (optional - for GPT features)
$env:OPENAI_API_KEY = "your-api-key-here"
```

### 2. Run Setup

```powershell
# Allow script execution (if needed)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Run the setup script
.\setup.ps1
```

The setup script will:
- Build and start Docker containers
- Test all service endpoints
- Display performance metrics

### 3. View Metrics

```powershell
# Show metrics snapshot
.\show_metrics.ps1

# Launch interactive dashboard
.\dashboard.ps1

# Test table output formatting
.\test_table_output.ps1
```

## Services

- **Data Service**: `http://localhost:8000`
- **LLM Service**: `http://localhost:7871`

## Available Endpoints

- `/health` - Service health check
- `/der_data` - DER data retrieval
- `/analyze_data` - Data analysis
- `/query_gpt` - GPT-powered queries (requires API key)
- `/data_insights` - Data insights (requires API key)
- `/ml_analysis` - Machine learning analysis
- `/metrics/system` - System metrics
- `/metrics/performance` - Performance metrics

## Troubleshooting

If containers fail to start:
```powershell
docker-compose down
docker-compose up -d
```

View container logs:
```powershell
docker-compose logs -f
``` 
