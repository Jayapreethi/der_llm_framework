# DER LLM Framework

A secure containerized framework for multi-cloud federated LLM + DER (Distributed Energy Resource) analytics.

## Platform Support

**This branch supports Linux and macOS only.** All setup scripts and tools are designed for Unix-based systems.

## Overview

This repository provides:
1. Containerized LLM + data processing services (FastAPI based)
2. Automated build & validation script (`setup.sh`)
3. Lightweight security/pentest helper (`security_pentest.sh`)
4. ML + GPT endpoints for DER time‑series analysis, anomaly detection, clustering, predictive analytics, and performance metrics.

![alt text](image.png)

**Figure: DER_LLM framework architecture: Secure, containerized multi-cloud LLM and DER analytics stack.** 

## Repository Structure

```
docker-compose.yml        # Orchestrates services
setup.sh                  # Build + smoke/integration test harness
security_pentest.sh       # Basic container/API security scanning
data_analysis.sh          # Run data analysis tests
api_test.sh              # API endpoint testing
check_status.sh          # Service health checks
monitor_services.sh      # Service monitoring
rebuild-test.sh          # Quick rebuild and test
requirements.txt         # Base dependencies
llm_service/             # LLM FastAPI service code
data/                    # Source & processed datasets
  der_data.csv
  processed_results/
    data_1min.csv
    data_3min.csv
    data_5min.csv
```

## 1. Prerequisites

### Required Software
- **Docker Engine + Docker Compose v2** - Check version with `docker compose version`
- **curl** - For API testing
- **bash** - Shell scripting (pre-installed on Linux/macOS)
- **git** - Version control

### Optional Tools
- Python 3.9+ (for local development/testing)
- GNU diffutils (for comparing outputs)

### Security Tooling
Security tools are pulled automatically as containers during the pentest phase:
- `aquasec/trivy` - Container vulnerability scanning
- `owasp/zap2docker-stable` - API security testing
- `docker/docker-bench-security` - Docker configuration benchmarking

## 2. Environment Variables & Secrets

Create a `.env` file in the repo root (never commit) with your API keys:

```bash
OPENAI_API_KEY=sk-...your-key-here...
# ANTHROPIC_API_KEY=...
# HUGGINGFACE_TOKEN=...
```

**Important:** Ensure `.env` is listed in `.gitignore` to prevent accidental commits of sensitive data.

## 3. Quick Start

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/Jayapreethi/DER_LLM_framework.git
cd DER_LLM_framework/demo

# Create your .env file with API keys
echo "OPENAI_API_KEY=your-key-here" > .env

# Make scripts executable
chmod +x *.sh

# Run the setup script
./setup.sh
```

### Access Services

Once setup completes, services are available at:
- **LLM Service**: http://localhost:8000
- **Data Service**: http://localhost:7871

## 4. Available Scripts

### setup.sh - Full Setup & Testing

**Purpose:** Complete clean rebuild of all service containers, start them, wait for readiness, and perform comprehensive endpoint testing.

**What it does:**
1. Validates `docker-compose` & `curl` availability
2. Brings down any existing stack (`docker-compose down`)
3. Removes residual containers/images + prunes unused Docker artifacts
4. Rebuilds images with `--no-cache` (ensures dependency freshness)
5. Starts services in detached mode
6. Waits 20s for initialization
7. Exercises data service endpoints for multiple aggregation intervals
8. Exercises LLM service root + health
9. Runs GPT + ML analysis endpoints
10. Prints status & performance summary

**Usage:**
```bash
./setup.sh
```

### security_pentest.sh - Security Testing

**Purpose:** Perform automated security review of the running stack and container images.

**Tests included:**
1. **Image vulnerability scan** with Trivy (HIGH & CRITICAL severity)
2. **API security baseline** with OWASP ZAP
3. **Docker configuration benchmark** via Docker Bench

**Usage:**
```bash
# Ensure services are running first
./setup.sh

# Run security tests
./security_pentest.sh
```

**Reports:** Generated in timestamped directory `security_reports_YYYYmmdd_HHMMSS/`

**Interpreting Results:**
- `vulnerabilities.txt` - Inspect CVEs; patch by updating base image or dependencies
- `api_security.html` - Look for missing security headers, potential injection points
- `docker_bench.txt` - Focus on scored FAIL items (e.g., container privilege, logging configuration)

### data_analysis.sh - Data Analysis Tests

**Purpose:** Run various data analysis scenarios against the LLM service.

**Tests included:**
1. Grid Stability Analysis (1min interval)
2. Renewable Energy Integration (3min interval)
3. Anomaly Detection (5min interval)
4. Predictive Analysis (1min interval)

**Usage:**
```bash
./data_analysis.sh
```

### api_test.sh - API Endpoint Testing

**Purpose:** Test all available API endpoints.

**Usage:**
```bash
./api_test.sh
```

### check_status.sh - Service Health Checks

**Purpose:** Check the health and status of all running services.

**Usage:**
```bash
./check_status.sh
```

### monitor_services.sh - Service Monitoring

**Purpose:** Continuous monitoring of service health and performance.

**Usage:**
```bash
./monitor_services.sh
```

### rebuild-test.sh - Quick Rebuild

**Purpose:** Quick rebuild and test cycle for development.

**Usage:**
```bash
./rebuild-test.sh
```

## 5. API Endpoints

### LLM Service (Port 8000)

#### Core Endpoints
- `GET /` - Service information
- `GET /health` - Health check
- `POST /query_gpt` - Basic GPT query
- `POST /analyze_data` - DER data analysis with cost tracking
- `POST /data_insights` - Data insights (alias for analyze_data)

#### ML Analysis Endpoints
- `POST /detect_anomalies` - Anomaly detection
- `POST /cluster_analysis` - Clustering analysis
- `POST /predictive_analysis` - Predictive modeling
- `POST /comprehensive_ml_analysis` - Comprehensive ML analysis
- `POST /ml_analysis` - ML analysis (alias)

#### Utility Endpoints
- `POST /compare_intervals` - Compare different time intervals
- `POST /calculate_cloud_costs` - Cloud cost calculations

#### Metrics Endpoints
- `GET /metrics/table` - Performance metrics table
- `GET /metrics/system` - System metrics
- `GET /metrics/performance` - Detailed performance metrics
- `GET /metrics/cost_breakdown` - Cost breakdown by interval

### Data Service (Port 7871)
- `GET /` - Service information
- `GET /data/{interval}` - Get processed data by interval (1min, 3min, 5min)

## 6. Development Workflow

```bash
# Create a feature branch
git switch -c feature/my-change

# Make your changes...

# Build and test
./setup.sh

# Run security checks (optional)
./security_pentest.sh

# Run data analysis tests
./data_analysis.sh


```

## 7. Troubleshooting

| Symptom | Possible Cause | Fix |
|---------|----------------|-----|
| Curl timeouts | Service slow to start | Increase wait time in `setup.sh` or implement health polling |
| Container won't start | Port already in use | Check `docker ps` and stop conflicting services |
| Permission denied | Script not executable | Run `chmod +x *.sh` |
| API key errors | Missing or invalid .env | Create `.env` file with valid `OPENAI_API_KEY` |
| Import errors | Missing dependencies | Rebuild with `./setup.sh` |
| Trivy scan slow | First-time image download | Allow cache; subsequent runs will be faster |
| ZAP scan fails | Path with spaces issue | Known issue with workspace paths containing spaces |

### Common Commands

```bash
# Check service logs
docker-compose logs -f

# Check specific service
docker-compose logs -f llm_service

# Restart services
docker-compose restart

# Stop all services
docker-compose down

# Remove all containers and volumes
docker-compose down -v

# Check container status
docker ps -a

# Access container shell
docker exec -it llm_service bash
```

## 8. Security Best Practices

### Secrets Management
- **Never commit** API keys or credentials to Git
- Use `.env` files for local development
- Rotate any keys that were accidentally committed
- Consider using secret management tools (Vault, AWS Secrets Manager) for production

### Container Security
- Run containers as non-root users when possible
- Drop unnecessary capabilities (`CAP_SYS_ADMIN`, etc.)
- Use network segmentation with Docker networks
- Regularly scan images for vulnerabilities with Trivy

### API Security
- Add rate limiting for public endpoints
- Implement authentication (API keys / OAuth)
- Use HTTPS in production
- Add security headers (configured in FastAPI)

### Regular Maintenance
- Keep base images updated
- Review and patch CVEs from security scans
- Monitor container logs for suspicious activity
- Perform regular security audits

### Known Vulnerabilities

Based on latest security scan:
- **starlette** (0.27.0) has CVE-2024-47874 (HIGH) - DoS via multipart/form-data
  - **Fix:** Update to starlette >=0.40.0 or update fastapi to latest version

## 9. Cloud Cost Tracking

The framework includes built-in cloud cost tracking for AWS, GCP, and Azure:

- **Interval-specific pricing** for 1min, 3min, and 5min data processing
- **Cost breakdown** by compute, storage, ML, and data transfer
- **Provider comparison** to identify cheapest options
- **Hourly and daily cost estimates**

Access cost metrics via:
- `/metrics/cost_breakdown` - Detailed cost analysis
- `/calculate_cloud_costs` - Calculate costs for specific scenarios

## 10. Performance Monitoring

Monitor system and application performance:

- **CPU and memory usage** tracking
- **Request duration** metrics
- **Operation-specific** performance data
- **System resource** monitoring

Access performance metrics via:
- `/metrics/table` - Performance summary table
- `/metrics/system` - System resource metrics
- `/metrics/performance` - Detailed performance analysis

## 11. Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`./setup.sh` and `./data_analysis.sh`)
5. Commit your changes (`git commit -m 'feat: add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 12. License

[Add your license information here]

## 13. Support

For issues, questions, or contributions:
- GitHub Repository: https://github.com/Jayapreethi/DER_LLM_framework
- Open an issue on GitHub for bug reports or feature requests

---

**Last Updated:** December 2, 2025  
**Version:** 2.3.0  
**Branch:** demo-unix (Linux/macOS)

