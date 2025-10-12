#!/usr/bin/env python3
"""Fix admin password in database"""
import psycopg2
from passlib.context import CryptContext
import os

# Password context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Database connection
conn = psycopg2.connect(
    dbname="uns_claudejp",
    user="uns_admin",
    password="57UD10R",
    host="db",
    port="5432"
)

try:
    cur = conn.cursor()

    # Generate correct hash
    password = "admin123"
    correct_hash = pwd_context.hash(password)

    print(f"Updating admin password...")
    print(f"Password: {password}")
    print(f"New hash: {correct_hash}")

    # Update password
    cur.execute(
        "UPDATE users SET password_hash = %s WHERE username = %s",
        (correct_hash, "admin")
    )

    conn.commit()

    # Verify
    cur.execute("SELECT username, password_hash FROM users WHERE username = 'admin'")
    result = cur.fetchone()

    if result:
        username, db_hash = result
        verification = pwd_context.verify(password, db_hash)
        print(f"\nVerification:")
        print(f"  Username: {username}")
        print(f"  Hash in DB: {db_hash[:30]}...")
        print(f"  Password verification: {verification}")

        if verification:
            print("\n✅ SUCCESS: Password updated correctly!")
        else:
            print("\n❌ ERROR: Password verification failed!")

    cur.close()

except Exception as e:
    print(f"❌ Error: {e}")
    conn.rollback()

finally:
    conn.close()
