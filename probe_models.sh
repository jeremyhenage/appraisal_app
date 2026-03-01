#!/bin/bash

PROJECT_ID="firearmappraiser"
LOCATION="us-central1"
TOKEN=$(gcloud auth print-access-token)

MODELS=(
  "gemini-2.0-flash-exp"
  "gemini-1.5-pro"
  "gemini-1.5-pro-001"
  "gemini-1.5-pro-002"
  "gemini-1.5-flash"
  "gemini-1.5-flash-001"
  "gemini-1.5-flash-002"
  "gemini-1.0-pro"
  "gemini-1.0-pro-vision"
)

echo "Probing models in project $PROJECT_ID ($LOCATION)..."

for model in "${MODELS[@]}"; do
  echo -n "Checking $model... "
  
  response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "https://$LOCATION-aiplatform.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/publishers/google/models/$model:generateContent" \
    -d '{ "contents": [{ "role": "user", "parts": [{ "text": "Hi" }] }] }')

  if [[ "$response" == "200" ]]; then
    echo "✅ AVAILABLE"
  elif [[ "$response" == "404" ]]; then
    echo "❌ NOT FOUND"
  else
    echo "⚠️ Code $response"
  fi
done
