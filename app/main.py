import os
import time
import logging
from fastapi import FastAPI, HTTPException, Body
import psycopg2
from psycopg2.extras import RealDictCursor

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Cloud-Native Employee API")

def get_db_connection():
    db_host = os.getenv("DB_HOST")
    db_name = os.getenv("DB_NAME")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")

    # Resilience connection loops for cluster recovery
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
    """Liveness probe metric handler."""
    return {"status": "healthy"}

@app.get("/employees", status_code=200)
def get_employees():
    """Fetches all records systematically to show data."""
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT id, name, role, department FROM employees ORDER BY id ASC;")
            return cursor.fetchall()
    except Exception as e:
        logger.error(f"Query failure: {e}")
        raise HTTPException(status_code=500, detail="Internal Query Error")
    finally:
        conn.close()

@app.post("/employees", status_code=201)
def create_employee(
    name: str = Body(..., embed=True), 
    role: str = Body(..., embed=True), 
    department: str = Body(..., embed=True)
):
    """Inserts a new entry using raw JSON body parameters to demonstrate write persistence."""
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(
                "INSERT INTO employees (name, role, department) VALUES (%s, %s, %s) RETURNING id;",
                (name, role, department)
            )
            new_id = cursor.fetchone()["id"]
            conn.commit()
            return {"message": "Employee added successfully!", "id": new_id}
    except Exception as e:
        conn.rollback()
        logger.error(f"Insert failure: {e}")
        raise HTTPException(status_code=500, detail="Internal Insert Error")
    finally:
        conn.close()

@app.put("/employees/{employee_id}", status_code=200)
def update_employee(
    employee_id: int,
    name: str | None = Body(None, embed=True),
    role: str | None = Body(None, embed=True),
    department: str | None = Body(None, embed=True)
):
    """Updates an existing entry using individual body parameters to demonstrate state survival."""
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT * FROM employees WHERE id = %s;", (employee_id,))
            if not cursor.fetchone():
                raise HTTPException(status_code=404, detail="Employee not found")

            # Dynamically build update fields from non-null inputs
            update_fields = {}
            if name is not None: update_fields["name"] = name
            if role is not None: update_fields["role"] = role
            if department is not None: update_fields["department"] = department

            if not update_fields:
                return {"message": "No fields targets provided for update"}

            set_clause = ", ".join([f"{key} = %s" for key in update_fields.keys()])
            values = list(update_fields.values()) + [employee_id]

            cursor.execute(f"UPDATE employees SET {set_clause} WHERE id = %s;", values)
            conn.commit()
            return {"message": f"Employee {employee_id} updated successfully!", "updated_fields": list(update_fields.keys())}
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        logger.error(f"Update failure: {e}")
        raise HTTPException(status_code=500, detail="Internal Update Error")
    finally:
        conn.close()

@app.delete("/employees/{employee_id}", status_code=200)
def delete_employee(employee_id: int):
    """Removes a row from the database structure."""
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("DELETE FROM employees WHERE id = %s;", (employee_id,))
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail="Employee not found")
            conn.commit()
            return {"message": f"Employee {employee_id} deleted successfully!"}
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        logger.error(f"Delete failure: {e}")
        raise HTTPException(status_code=500, detail="Internal Delete Error")
    finally:
        conn.close()