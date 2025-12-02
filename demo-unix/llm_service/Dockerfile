FROM python:3.9-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the FastAPI service script
COPY llm_service.py /app/llm_service.py

# Expose the correct port
EXPOSE 8000

# Run FastAPI server
CMD ["uvicorn", "llm_service:app", "--host", "0.0.0.0", "--port", "8000"]