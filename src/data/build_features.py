import pandas as pd
import numpy as np
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import TimeSeriesSplit
from sklearn.metrics import mean_squared_error, mean_absolute_error

# Custom transformer definitions
class LagFeatureEngineer(BaseEstimator, TransformerMixin):
    def __init__(self, n_lags=12):
        self.n_lags = n_lags

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        df = X.copy()
        df = df.sort_values(['store_id', 'sku_id', 'week'])
        for lag in range(1, self.n_lags + 1):
            df[f'units_sold_lag_{lag}'] = (
                df.groupby(['store_id', 'sku_id'])['units_sold'].shift(lag)
            )
        return df

class IsoWeekFeature(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        return self

    def transform(self, X):
        df = X.copy()
        df['iso_week'] = df['week'].dt.isocalendar().week
        return df

class WeekendBinaryEncoder(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        return self

    def transform(self, X):
        df = X.copy()
        df['is_weekend'] = (df['week'].dt.dayofweek >= 5).astype(int)
        return df

class CyclicalEncoder(BaseEstimator, TransformerMixin):
    def __init__(self, period='dayofweek', prefix='dow'):
        self.period = period
        self.prefix = prefix

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        df = X.copy()
        if self.period == 'dayofweek':
            vals = df['week'].dt.dayofweek
            period_len = 7
        elif self.period == 'month':
            vals = df['week'].dt.month
            period_len = 12
        else:
            raise ValueError("Unsupported period")
        df[f'{self.prefix}_sin'] = np.sin(2 * np.pi * vals / period_len)
        df[f'{self.prefix}_cos'] = np.cos(2 * np.pi * vals / period_len)
        return df

