@echo off
REM Batch Setup Script for GPT ML Data Analysis Service
REM Version: 3.0.0 - Windows Batch Compatible
REM Focus: GPT analysis and ML-based DER data analysis

echo ========================================
echo Starting GPT ML Data Analysis Service
echo ========================================
echo.

REM Step 0: Set API Tokens
echo Step 0: Setting up API tokens...
set OPENAI_API_KEY=PUT_YOUR_OPENAI_API_KEY_HERE
echo OPENAI_API_KEY: %OPENAI_API_KEY%
echo.

REM Step 1: Environment Check
echo Step 1: Checking environment...
where docker-compose >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: docker-compose not found!
    echo Please install Docker Desktop for Windows.
    exit /b 1
)

where curl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: curl not found! Some tests may fail.
    echo Please install curl or use Windows 10+
)

echo Environment check passed.
echo.

REM Step 2: Docker Compose Build
echo Step 2: Building Docker containers...
echo Stopping existing containers...
docker-compose down

echo Cleaning up Docker system...
docker system prune -f

echo Building Docker containers with --no-cache...
docker-compose build --no-cache --progress=plain
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker build failed!
    exit /b 1
)

echo Final cleanup...
docker system prune -f
echo.

REM Step 3: Docker Compose Up
echo Step 3: Starting Docker containers...
docker-compose up -d
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker Compose up failed!
    exit /b 1
)
echo.

REM Step 4: Wait for Services
echo Step 4: Waiting for services to start...
echo Waiting 20 seconds...
timeout /t 20 /nobreak >nul
echo.

REM Step 5: Test Data Service
echo Step 5: Testing Data Service endpoints...
echo =========================================
echo Testing data service root...
curl -X GET "http://localhost:7871/" -H "Content-Type: application/json" --max-time 10
echo.

echo Fetching 1min data...
curl -X GET "http://localhost:7871/data/1min" -H "Content-Type: application/json" --max-time 15
echo.

echo Fetching 3min data...
curl -X GET "http://localhost:7871/data/3min" -H "Content-Type: application/json" --max-time 15
echo.

echo Fetching 5min data...
curl -X GET "http://localhost:7871/data/5min" -H "Content-Type: application/json" --max-time 15
echo.

REM Step 6: Test LLM Service
echo Step 6: Testing LLM Service...
echo ==============================
echo Testing LLM root...
curl -X GET "http://localhost:8000/" -H "Content-Type: application/json" --max-time 10
echo.

echo Testing health check...
curl -X GET "http://localhost:8000/health" -H "Content-Type: application/json" --max-time 10
echo.

REM Step 7: Test GPT Analysis
echo Step 7: Testing GPT Analysis...
echo ===============================
echo Testing GPT endpoint...
curl -X POST "http://localhost:8000/query_gpt" -H "Content-Type: application/json" -d "{\"prompt\": \"What is DER analysis?\"}" --max-time 30
echo.

echo Testing data analysis...
curl -X POST "http://localhost:8000/analyze_data" -H "Content-Type: application/json" -d "{\"interval\": \"1min\", \"analysis_type\": \"summary\"}" --max-time 45
echo.

REM Step 8: Test ML Analysis
echo Step 8: Testing ML Analysis...
echo ==============================
echo Testing anomaly detection...
curl -X POST "http://localhost:8000/detect_anomalies" -H "Content-Type: application/json" -d "{\"interval\": \"1min\"}" --max-time 60
echo.

echo Testing clustering...
curl -X POST "http://localhost:8000/cluster_analysis" -H "Content-Type: application/json" -d "{\"interval\": \"1min\", \"n_clusters\": 3}" --max-time 60
echo.

REM Step 9: Final Status
echo Step 9: Final Status Check...
echo =============================
docker-compose ps
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Services:
echo - Data Service: http://localhost:7871
echo - LLM Service: http://localhost:8000
echo - Health Check: http://localhost:8000/health
echo - API Docs: http://localhost:8000/docs
echo.
echo Your GPT ML Analysis Service is running!
echo ========================================

pause
