
import vertexai
from vertexai.generative_models import GenerativeModel
import os

project_id = "firearmappraiser"
location = "us-central1"

print(f"Initializing Vertex AI for {project_id} in {location}...")
vertexai.init(project=project_id, location=location)

print("Listing models...")
models_to_test = [
    "gemini-2.0-flash-exp",
    "gemini-2.0-pro-exp-02-05", 
    "gemini-1.5-pro",
    "gemini-1.5-flash"
]

for model_name in models_to_test:
    print(f"\nTesting {model_name}...")
    try:
        model = GenerativeModel(model_name)
        response = model.generate_content("Hello")
        print(f"✅ {model_name}: SUCCESS")
    except Exception as e:
        print(f"❌ {model_name}: FAILED - {e}")
