# Use a clean, lightweight Python image
FROM python:3.11-alpine

WORKDIR /app

# Install libpq (required runtime library for postgres) 
# without bringing in heavy build tools like gcc
RUN apk add --no-cache libpq

# Copy requirements and install them instantly using pre-compiled binaries
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your application code
COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]