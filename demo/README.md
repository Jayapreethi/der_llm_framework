# Windows Setup: Running setup.sh for Free

To run the Bash-based `setup.sh` script for free on Windows:

1. **Install Docker Desktop for Windows** (free for personal/education use):
	- Download: https://www.docker.com/products/docker-desktop/
	- During install, enable WSL2 integration.

2. **Install WSL2 and Ubuntu (free, from Microsoft Store):**
	- Open PowerShell as admin:
	  ```powershell
	  wsl --install
	  ```
	- Reboot if prompted.
	- Install Ubuntu from the Microsoft Store.

3. **Open Ubuntu (WSL2) from Start menu.**

4. **In Ubuntu, install git and curl if missing:**
	```bash
	sudo apt update
	sudo apt install -y git curl
	```

5. **Clone the repository:**
	```bash
	git clone https://github.com/Jayapreethi/der_llm_framework.git
	cd der_llm
	```

6. **Make the script executable:**
	```bash
	chmod +x setup.sh
	```

7. **(Optional) Create a `.env` file if needed (with dummy or local model settings).**

8. **Run the script:**
	```bash
	./setup.sh
	```

9. **Access your services at** `http://localhost:8000` **and** `http://localhost:7871` **from your browser.**

This method is 100% free (no paid API keys required if you use local models) and gives you a full Linux environment on Windows for Bash scripts and Docker. No need for paid cloud APIs or extra licenses.
# der_llm

A secure containerized framework for multi-cloud federated LLM + DER (Distributed Energy Resource) analytics.

## Overview
This repository provides:
1. Containerized LLM + data processing services (FastAPI based)
2. Automated build & validation script (`setup.sh`)
3. Lightweight security/pentest helper (`security_pentest.sh`)
4. ML + GPT endpoints for DER time‑series analysis, anomaly detection, clustering, predictive analytics, and performance metrics.

![alt text](image.png)

**Figure: DER_LLM framework architecture: Secure, containerized multi-cloud LLM and DER analytics stack.** 

## Repository Structure (key items)
```
docker-compose.yml        # Orchestrates services
setup.sh                  # Build + smoke/integration test harness
security_pentest.sh       # Basic container/API security scanning
requirements.txt          # Base dependencies
llm_service/              # LLM FastAPI service code
data/                     # Source & processed datasets
```

## 1. Prerequisites
Install / enable:
- Docker Engine + Docker Compose v2 (`docker compose version`)
- curl
- Python 3.9+ (only needed locally for pretty printing JSON)
- (Optional) GNU diffutils for comparing outputs

Security tooling pulled automatically as containers during the pentest phase:
- `aquasec/trivy`
- `owasp/zap2docker-stable`
- `docker/docker-bench-security`

## 2. Environment Variables & Secrets
Create a `.env` file in the repo root (never commit) with content such as:
```
OPENAI_API_KEY=sk-...redacted...
# ANTHROPIC_API_KEY=...
# HUGGINGFACE_TOKEN=...
```
Then ensure `.env` is listed in `.gitignore` (already done). The current `setup.sh` example previously hard‑coded keys; those MUST be rotated and removed. Replace the hard‑coded export lines with loading from `.env` (see Hardening section below).

## 3. setup.sh Script
Purpose: Full clean rebuild of all service containers, start them, wait for readiness, and perform a curated battery of endpoint smoke & functional tests for both the data and LLM services.

### What It Does
1. Validates `docker-compose` & `curl` availability
2. Brings down any existing stack (`docker-compose down`)
3. Removes residual containers/images + prunes unused Docker artifacts
4. Rebuilds images with `--no-cache` (ensures dependency freshness)
5. Starts services in detached mode
6. Waits 20s for initialization
7. Exercises data service endpoints for multiple aggregation intervals
8. Exercises LLM service root + health
9. Runs GPT + ML analysis endpoints (query, anomaly detection, clustering, prediction, composite analysis, multi-interval comparison, metrics)
10. Prints status & performance summary

### Usage
```bash
./setup.sh
```
Run from repository root. To make executable:
```bash
chmod +x setup.sh
```

### Typical Output Artifacts
- Console responses from each curl invocation
- Final status table via `/metrics/table`

### Exit Behavior
The script uses `set -e` so it aborts on the first failing command (except those explicitly guarded with manual checks). Curl timeouts are capped (`--max-time`) to prevent indefinite hangs.

### Cross‑Platform Notes
- Native Windows CMD / PowerShell is not supported. Use WSL2 Ubuntu or Git Bash.
- Replace `docker-compose` with `docker compose` if using Compose V2 exclusively.

### Hardening Recommendations
- Remove hard‑coded API keys; source `.env` instead:
	```bash
	# Replace export lines with:
	if [ -f .env ]; then set -a; . ./.env; set +a; fi
	```
- Consider reducing rebuild cost by adding a `--build` flag only when dependencies change
- Parameterize wait time: `STARTUP_WAIT=${STARTUP_WAIT:-20}` then `sleep "$STARTUP_WAIT"`
- Add health loop instead of fixed sleep (poll `/health` with retries)

## 4. security_pentest.sh Script
Purpose: Perform a quick, automation-friendly baseline security review of the running stack and image(s).

### Tests Included
1. Image vulnerability scan with Trivy (HIGH & CRITICAL severity) => `vulnerabilities.txt`
2. Passive API baseline scan with OWASP ZAP => `api_security.html`
3. Docker host / daemon configuration benchmark via Docker Bench => `docker_bench.txt`

### Usage
Ensure the main stack is running (after `setup.sh` or `docker-compose up -d`) and then execute:
```bash
chmod +x security_pentest.sh
./security_pentest.sh
```
Reports are stored in a timestamped directory: `security_reports_YYYYmmdd_HHMMSS/`.

### Requirements & Permissions
- Docker daemon access (bind mounts of `/var/run/docker.sock`)
- Linux host or WSL2 (Docker Bench uses host namespaces & may not function on Mac/Win exactly the same)

### Interpreting Results
- `vulnerabilities.txt`: Inspect CVEs; patch by updating base image or dependencies.
- `api_security.html`: Look for missing security headers, potential injection points.
- `docker_bench.txt`: Focus on scored FAIL items (e.g., container privilege, logging configuration).

### Extending Scans
- Add Snyk or Grype for complementary image scanning
- Add authenticated API scans (supply tokens via `.env` and export before invoking ZAP)
- Integrate into CI: run Trivy on each build; fail if new HIGH/CRITICAL CVEs introduced.

## 5. Recommended Development Workflow
```bash
git switch -c feature/my-change
./setup.sh               # build & test
./security_pentest.sh    # optional security review
git add .
git commit -m "feat: my change"
git push -u origin feature/my-change
```

## 6. Troubleshooting
| Symptom | Possible Cause | Fix |
|---------|----------------|-----|
| Curl timeouts | Service slow to start | Increase `STARTUP_WAIT` or implement health polling |
| Trivy pull slow | First-time image download | Allow cache; remove `--no-cache` in rebuild for dev loops |
| ZAP scan fails DNS | host.docker.internal unsupported on Linux | Replace target with `http://$API_HOST:$API_PORT` and ensure network access |
| Permission denied on docker bench | Rootless Docker or missing caps | Run with elevated privileges or skip this test in CI |

## 7. Security Notes
- Rotate any API keys committed historically; they should be considered compromised.
- Enforce principle of least privilege for containers (drop `CAP_SYS_ADMIN`, run as non-root if possible).
- Consider network segmentation with Docker networks for data vs public APIs.
- Add rate limiting & auth (API keys / OAuth) for public endpoints.

---

