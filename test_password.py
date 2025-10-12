#!/usr/bin/env python3
"""Test password verification"""
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Hash from database
db_hash = "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu"

# Test passwords
test_passwords = ["admin123", "admin", "Admin123", "password"]

print("Testing password verification:")
print(f"Hash from DB: {db_hash}")
print("-" * 60)

for password in test_passwords:
    result = pwd_context.verify(password, db_hash)
    print(f"Password: '{password}' -> {result}")

print("-" * 60)
print("\nGenerating new hash for 'admin123':")
new_hash = pwd_context.hash("admin123")
print(f"New hash: {new_hash}")
print(f"Verify new hash: {pwd_context.verify('admin123', new_hash)}")
