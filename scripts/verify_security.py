import requests
import json
import sys

# Replace with your actual function URL or retrieve it dynamically
# For now, we will try to find it or asking the user to provide it if local testing
FUNCTION_URL = "https://us-central1-firearmappraiser.cloudfunctions.net/appraise_item"

def test_unauthenticated_access():
    print(f"Testing unauthenticated access to {FUNCTION_URL}...")
    try:
        response = requests.post(
            FUNCTION_URL, 
            json={"data": {"imageUrl": "gs://bucket/file.jpg"}},
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Response Status: {response.status_code}")
        print(f"Response Body: {response.text}")

        # specific behavior for Callable functions:
        # Without auth, it might return 401 or 403, or 200 with an error object if the SDK handles it? 
        # Actually, https.onCall automatically checks auth token.
        # If we manually raise HttpsError.UNAUTHENTICATED, it should return an error structure.
        
        if response.status_code == 401 or response.status_code == 403:
             print("✅ PASS: Request denied as expected (Http status).")
        elif "error" in response.json():
             error_code = response.json().get("error", {}).get("status")
             error_message = response.json().get("error", {}).get("message")
             if error_code == "UNAUTHENTICATED" or "unauthenticated" in str(response.text).lower():
                 print("✅ PASS: Request denied as expected (Error body).")
             else:
                 print(f"❌ FAIL: Unexpected error: {error_code} - {error_message}")
                 sys.exit(1)
        else:
             print("❌ FAIL: Request was accepted (200 OK without error).")
             sys.exit(1)

    except Exception as e:
        print(f"❌ FAIL: Request failed with exception: {e}")
        sys.exit(1)

if __name__ == "__main__":
    test_unauthenticated_access()
