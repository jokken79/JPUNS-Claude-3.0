"""
Azure Computer Vision Configuration - UNS-ClaudeJP 2.0
Load Azure credentials from environment variables
"""
import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file in parent directory
ENV_PATH = Path(__file__).parent.parent.parent / '.env'
load_dotenv(ENV_PATH)

# Debug info
print(f"Loading .env from: {ENV_PATH}")
print(f".env file exists: {ENV_PATH.exists()}")

# Also try loading from the current directory and parent directory
CURRENT_DIR = Path(__file__).parent.parent
PARENT_DIR = Path(__file__).parent.parent.parent

# Try multiple possible locations for .env file
for path in [ENV_PATH, CURRENT_DIR / '.env', PARENT_DIR / '.env']:
    if path.exists():
        print(f"Found .env at: {path}")
        load_dotenv(path)
        break
else:
    print("No .env file found in any expected location")

# Configure Azure Computer Vision
AZURE_ENDPOINT = os.getenv("AZURE_COMPUTER_VISION_ENDPOINT")
AZURE_KEY = os.getenv("AZURE_COMPUTER_VISION_KEY")
AZURE_API_VERSION = os.getenv("AZURE_COMPUTER_VISION_API_VERSION", "2023-02-01-preview")

# Verify credentials
if not AZURE_ENDPOINT or not AZURE_KEY:
    print("WARNING: Azure Computer Vision credentials not found in environment variables")
    print(f"Looking for .env file at: {ENV_PATH}")
    print(f"File exists: {ENV_PATH.exists()}")
    
    # Don't raise error for demo purposes
    AZURE_ENDPOINT = "https://demo-resource.cognitiveservices.azure.com/"
    AZURE_KEY = "demo_key_for_testing"
else:
    print(f"Azure Computer Vision credentials loaded successfully")
    print(f"Endpoint: {AZURE_ENDPOINT}")
    print(f"API Version: {AZURE_API_VERSION}")