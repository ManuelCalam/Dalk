#!/bin/bash

# 🔑 CONFIGURACIÓN
SUPABASE_URL="https://bsactypehgxluqyaymui.supabase.co"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzYWN0eXBlaGd4bHVxeWF5bXVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMTQwNjIsImV4cCI6MjA2Mzg5MDA2Mn0.OLLhOOzrxs27aVpChYIxCg8gDXc7PZ7DxEsex9zn324"
USER_ID="69ef306c-a65f-4480-9ab3-6f363e03de38"

echo "🧪 Testing Webhook VerificaMex"
echo "Session ID: $SESSION_ID"
echo "User ID: $USER_ID"

# 📝 Primero crear el registro en identity_verifications
echo ""
echo "1️⃣ Creando registro en identity_verifications..."
curl -X POST "$SUPABASE_URL/rest/v1/identity_verifications" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=minimal" \
  -d '{
    "user_id": "'"$USER_ID"'",
    "verificamex_session_id": "verificamex-test-'"$(date +%s)"'",
    "status": "OPEN"
  }'

sleep 2

# ✅ Simular webhook EXITOSO (Score 95)
echo ""
echo "2️⃣ Simulando webhook EXITOSO..."
curl -X POST "$SUPABASE_URL/functions/v1/verificamex_webhook" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "id": "verificamex-success-'"$(date +%s)"'",
      "status": "FINISHED",
      "result": 95,
      "ine": {
        "data": {
          "status": true
        }
      },
      "renapo": {
        "data": {
          "status": true
        }
      },
      "optionals": {
        "user_id": "'"$USER_ID"'"
      }
    }
  }'

echo ""
echo "✅ Webhook enviado. Verifica en Supabase:"
echo "   - identity_verifications.status debe ser 'completed'"
echo "   - identity_verifications.verification_result debe ser 95"
echo "   - users.verification_status debe ser 'verified'"