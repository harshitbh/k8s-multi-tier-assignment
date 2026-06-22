# Use a clean, lightweight Python image
FROM python:3.11-alpine

WORKDIR /app

# Install libpq runtime engine dependencies safely for psycopg2
RUN apk add --no-cache libpq

# Copy requirements matrix from the root context
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy main.py from the local app/ directory into the container's active /app directory
COPY app/main.py .

EXPOSE 8000

# Since main.py was copied directly into the working directory (/app), 
# we launch it directly as 'main:app'
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]