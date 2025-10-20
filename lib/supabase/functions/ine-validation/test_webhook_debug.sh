#!/bin/bash

# Script para debuggear el webhook
SUPABASE_URL="https://bsactypehgxluqyaymui.supabase.co"
SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzYWN0eXBlaGd4bHVxeWF5bXVpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0ODMxNDA2MiwiZXhwIjoyMDYzODkwMDYyfQ.AyydXU9oFcMVnWuj09bnhJWwcSOg3lDEJCSOl9S0oxc"

# Usar los IDs del test anterior
SESSION_ID="session_1760911438448_ivttfu7h0to"
VERIFICAMEX_ID="a0276a14-6f74-4639-8e93-9ed89427fd70"
USER_ID="5a59b3b9-cbee-413a-9487-faf28689f372"

echo "🔍 Verificando estado actual en BD..."
curl -s "${SUPABASE_URL}/rest/v1/identity_verifications?session_id=eq.${SESSION_ID}&select=*" \
  -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" | jq

echo ""
echo "📤 Enviando webhook..."

WEBHOOK_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/functions/v1/ine-validation" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "object": "VerificationSession",
      "id": "'"${VERIFICAMEX_ID}"'",
      "status": "FINISHED",
      "result": 95,
      "errors": [],
      "ine": {
        "data": {
          "status": true,
          "name": "JUAN",
          "first_lastname": "PEREZ",
          "second_lastname": "LOPEZ",
          "birthdate": "1990-01-15",
          "curp": "PELJ900115HDFRZN09",
          "gender": "H",
          "address": "CALLE REFORMA 123",
          "zip_code": "06000",
          "state": "DISTRITO FEDERAL",
          "municipality": "CUAUHTEMOC",
          "colony": "CENTRO",
          "voter_id": "PELJ900115HDFRZN12",
          "emission_date": "2018",
          "expiration_date": "2028"
        }
      },
      "renapo": {
        "data": {
          "status": true,
          "curp": "PELJ900115HDFRZN09",
          "name": "JUAN",
          "first_lastname": "PEREZ",
          "second_lastname": "LOPEZ",
          "birthdate": "1990-01-15",
          "gender": "HOMBRE",
          "birthplace": "DISTRITO FEDERAL"
        }
      },
      "optionals": {
        "session_id": "'"${SESSION_ID}"'",
        "user_id": "'"${USER_ID}"'",
        "email": "test.verificamex+1760911435@dalk.com"
      }
    }
  }')

echo "📦 Respuesta del webhook:"
echo "$WEBHOOK_RESPONSE" | jq

echo ""
echo "🔍 Verificando estado después del webhook..."
sleep 2
curl -s "${SUPABASE_URL}/rest/v1/identity_verifications?session_id=eq.${SESSION_ID}&select=*" \
  -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" | jq

echo ""
echo "📋 Ver logs de la Edge Function:"
echo "   supabase functions logs ine-validation --limit 50"