FROM python:3.9-slim

WORKDIR /app

COPY app.py /app/app.py
COPY requirements.txt /app/requirements.txt
COPY data/der_data.csv /app/data/der_data.csv

RUN pip install --upgrade pip && pip install -r requirements.txt

EXPOSE 7860

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7860"]