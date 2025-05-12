import pandas as pd 
import numpy as np 
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import logging
import time

# In need for an OpenTelemetry collector with OLTP exporter

# Configure logger
logger = logging.getLogger('app')

app = FastAPI()

# Add middleware for request logging
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    
    # Log the incoming request
    logger.info(f"Request started: {request.method} {request.url.path}")
    
    try:
        response = await call_next(request)
        process_time = time.time() - start_time
        logger.info(f"Request completed: {request.method} {request.url.path} - Status: {response.status_code} - Time: {process_time:.2f}s")
        return response
    except Exception as e:
        logger.error(f"Request failed: {request.method} {request.url.path} - Error: {str(e)}")
        raise

@app.get("/")
async def root():
    logger.info("Root endpoint called")
    return {"message": "Hello World"}

@app.post("/predict")
async def predict(*args, **kwargs):
    """
    Predict the output based on the input features.
    """
    logger.info("Predict endpoint called")
    try:
        # Your prediction logic here
        logger.info("Prediction completed successfully")
        return {"message": "Prediction endpoint success"}
    except Exception as e:
        logger.error(f"Prediction failed: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={"message": "Prediction failed", "error": str(e)}
        )

if __name__ == "__main__":
    logger.info("Application started")
    pass