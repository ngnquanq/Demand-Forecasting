import pandas as pd 
import numpy as np 
from fastapi import FastAPI
from fastapi.responses import JSONResponse  

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/predict")
async def predict(*args, **kwargs):
    """
    Predict the output based on the input features.
    """
    return {"message": "Prediction endpoint"}

if __name__ == "__main__":
    print("all good")
    pass