from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import os

# FastAPI app setup
app = FastAPI(title="DER Data Aggregation API")

# File paths
input_file_path = "/app/data/der_data.csv"
output_dir = "/app/data/processed_results/"
data_files = {
    "1min": os.path.join(output_dir, "data_1min.csv"),
    "3min": os.path.join(output_dir, "data_3min.csv"),
    "5min": os.path.join(output_dir, "data_5min.csv"),
}

# Function to preprocess data
def preprocess_data():
    try:
        if not os.path.exists(input_file_path):
            raise FileNotFoundError(f"The file '{input_file_path}' does not exist.")
        
        data = pd.read_csv(input_file_path)
        if 'datetimestamp' not in data.columns:
            raise KeyError("'datetimestamp' column is missing.")
        data['datetimestamp'] = pd.to_datetime(data['datetimestamp'], errors='coerce')
        if data['datetimestamp'].isnull().any():
            raise ValueError("Invalid 'datetimestamp' values detected.")
        data.set_index('datetimestamp', inplace=True)
        if not isinstance(data.index, pd.DatetimeIndex):
            raise TypeError("Index is not a DatetimeIndex.")
        numeric_data = data.select_dtypes(include=['number'])
        data_1min = numeric_data.resample('1min').mean()
        data_3min = numeric_data.resample('3min').mean()
        data_5min = numeric_data.resample('5min').mean()
        os.makedirs(output_dir, exist_ok=True)
        data_1min.to_csv(data_files["1min"])
        data_3min.to_csv(data_files["3min"])
        data_5min.to_csv(data_files["5min"])
        print("Data aggregation completed successfully.")
    except Exception as e:
        print(f"Error: {e}")

# Preprocess the data on startup
preprocess_data()

@app.get("/data/{interval}")
def get_data(interval: str):
    """
    Endpoint for fetching aggregated data.
    """
    if interval not in data_files:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid interval '{interval}'. Valid intervals: '1min', '3min', '5min'."
        )
    
    file_path = data_files[interval]
    try:
        df = pd.read_csv(file_path)
        return df.to_dict(orient="records")
    except FileNotFoundError:
        raise HTTPException(
            status_code=404,
            detail=f"Aggregated data file for interval '{interval}' not found."
        )

# Sample welcome endpoint
@app.get("/")
def read_root():
    return {
        "message": "Welcome to the DER Data Aggregation FastAPI service!",
        "endpoints": ["/data/1min", "/data/3min", "/data/5min"]
    }