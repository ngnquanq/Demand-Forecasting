# ────────────────────────────────────────────────────────────────
# Stage 1 : build runtime image
# ────────────────────────────────────────────────────────────────
FROM python:3.9-slim AS runtime

# 1. Prevent python from writing .pyc files & set workdir
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 
WORKDIR /app

# 2. Copy dependency definition first for better cache‑hits
COPY requirements.txt .

# You can switch to Poetry if you prefer:
# RUN pip install "poetry==$POETRY_VERSION" && \
#     poetry config virtualenvs.create false && \
#     poetry install --no-interaction --no-ansi --no-root

RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy the rest of your source & model artefact
COPY src/ ./src/
COPY models/random_forest_model.pkl ./models/random_forest_model.pkl

# 4. Expose port & declare non‑root user for k8s best practice
EXPOSE 8000
# Create a non‑privileged user (uid 1001) and switch to it
# RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
# USER appuser

# 5. Start the web server
# ------- pick ONE of the two lines below ----------

# —— FastAPI / Starlette / general ASGI
CMD ["uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000"]

# —— Flask / Django via gunicorn (comment the uvicorn line & uncomment this)
# CMD ["gunicorn", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "src.api.main:app", "--bind", "0.0.0.0:8000"]
