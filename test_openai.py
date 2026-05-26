import os
import requests
from dotenv import load_dotenv

# Membaca file .env
load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")

print(f"Mencoba API Key: {api_key[:12]}... (disensor)")

headers = {
    "Authorization": f"Bearer {api_key}"
}

# Mencoba mengambil daftar model dari OpenAI
response = requests.get("https://api.openai.com/v1/models", headers=headers)

if response.status_code == 200:
    print("✅ BERHASIL! API Key kamu valid dan OpenAI berjalan normal.")
else:
    print(f"❌ GAGAL! Error {response.status_code}: {response.text}")