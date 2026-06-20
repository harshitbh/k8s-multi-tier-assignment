import os
import time
import logging
from fastapi import FastAPI, HTTPException
import psycopg2
from psycopg2.extras import RealDictCursor

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Cloud-Native Employee API")

def get_db_connection():
    # Externalized Configuration parsed at runtime from environment
    db_host = os.getenv("DB_HOST")
    db_name = os.getenv("DB_NAME")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")

    # Connection Pooling/Retry Backoff for Cluster Resiliency (Self-Healing)
    for attempt in range(5):
        try:
            conn = psycopg2.connect(
                host=db_host, database=db_name, user=db_user, password=db_password, connect_timeout=3
            )
            return conn
        except psycopg2.OperationalError as e:
            logger.warning(f"Database unavailable. Retrying ({attempt + 1}/5)... Error: {e}")
            time.sleep(2)
    raise HTTPException(status_code=500, detail="Database connection pool exhausted")

@app.get("/healthz", status_code=200)
def health_check():
    """Liveness probe to allow Kubernetes to monitor container health."""
    return {"status": "healthy"}

@app.get("/employees", status_code=200)
def get_employees():
    """Fetches data using atomic connection lifecycle management."""
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT id, name, role, department FROM employees;")
            return cursor.fetchall()
    except Exception as e:
        logger.error(f"Query failure: {e}")
        raise HTTPException(status_code=500, detail="Internal Query Error")
    finally:
        conn.close()