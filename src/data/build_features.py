import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import Pipeline   
from sklearn.impute import SimpleImputer
from sklearn.metrics import mean_absolute_error
import joblib
import os

class LagFeatureEngineer(BaseEstimator, TransformerMixin):
    def __init__(self, n_lags=12, drop_train_na=True):
        self.n_lags = n_lags
        self.drop_train_na = drop_train_na   # drop only in training rows

    def fit(self, X, y=None):
        return self                       # nothing to learn

    def transform(self, X):
        df = X.copy()
        df = df.sort_values(['store_id', 'sku_id', 'week'])
        for lag in range(1, self.n_lags + 1):
            df[f'units_sold_lag_{lag}'] = (
                df.groupby(['store_id', 'sku_id'])['units_sold'].shift(lag)
            )
        return df

class IsoWeekFeature(BaseEstimator, TransformerMixin):
    def __init__(self):
        pass

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        df = X.copy()
        # Convert week to datetime if not already
        if not pd.api.types.is_datetime64_any_dtype(df['week']):
            df['week'] = pd.to_datetime(df['week'], format='%y/%m/%d')
        
        # Extract ISO week number
        df['iso_week'] = df['week'].dt.isocalendar().week
        
        return df