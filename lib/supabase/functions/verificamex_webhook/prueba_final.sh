#!/bin/bash

# 🎯 SCRIPT DE PRUEBA COMPLETA - FLUJO DE VERIFICACIÓN DE IDENTIDAD
# Este script simula TODO el proceso sin gastar tokens de VerificaMex

set -e  # Salir si hay algún error

# 🔑 CONFIGURACIÓN
SUPABASE_URL="https://bsactypehgxluqyaymui.supabase.co"

# ⚠️ USAR SERVICE_ROLE_KEY PARA BYPASEAR RLS (solo para testing)
# 🔐 OBTÉN ESTA KEY DE: https://supabase.com/dashboard/project/bsactypehgxluqyaymui/settings/api
SERVICE_ROLE_KEY=""  # ⬅️ REEMPLAZA CON TU KEY

# ANON_KEY para el webhook (este sí puede quedar)
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzYWN0eXBlaGd4bHVxeWF5bXVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMTQwNjIsImV4cCI6MjA2Mzg5MDA2Mn0.OLLhOOzrxs27aVpChYIxCg8gDXc7PZ7DxEsex9zn324"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   🧪 PRUEBA COMPLETA DE VERIFICACIÓN DE IDENTIDAD             ║"
echo "║   Simula TODO el flujo sin gastar tokens de VerificaMex       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1️⃣ CREAR USUARIO DE PRUEBA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "1️⃣ CREANDO USUARIO DE PRUEBA..."

TIMESTAMP=$(date +%s)
TEST_EMAIL="paseador.test.$TIMESTAMP@example.com"
TEST_NAME="Paseador Test $TIMESTAMP"

# 🔑 GENERAR UUID CON uuidgen (comando del sistema)
USER_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')  # Convertir a minúsculas

echo "   ✅ UUID generado: $USER_ID"

# 🔑 CREAR USUARIO CON UUID EXPLÍCITO
CREATE_USER_RESPONSE=$(curl -s -X POST "$SUPABASE_URL/rest/v1/users" \
  -H "apikey: $SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "uuid": "'"$USER_ID"'",
    "name": "'"$TEST_NAME"'",
    "email": "'"$TEST_EMAIL"'",
    "usertype": "Paseador",
    "verification_status": "pending_verification",
    "birthdate": "1990-01-01",
    "gender": "Masculino",
    "phone": "3312345678",
    "address": "Calle Test",
    "ext_number": "123",
    "zipCode": "44100",
    "neighborhood": "Centro",
    "city": "Guadalajara"
  }')

# Validar respuesta
CREATED_UUID=$(echo "$CREATE_USER_RESPONSE" | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$CREATED_UUID" ]; then
  echo "❌ ERROR: No se pudo crear el usuario"
  echo "Respuesta: $CREATE_USER_RESPONSE"
  exit 1
fi

echo "   ✅ Usuario creado exitosamente"
echo "   📧 Email: $TEST_EMAIL"
echo "   🆔 UUID: $USER_ID"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2️⃣ CREAR SESIÓN DE VERIFICACIÓN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "2️⃣ CREANDO SESIÓN DE VERIFICACIÓN..."

SESSION_ID="session_${TIMESTAMP}_test"
VERIFICAMEX_SESSION_ID="verificamex_${TIMESTAMP}_test"

# 🔑 USAR SERVICE_ROLE_KEY TAMBIÉN AQUÍ
CREATE_SESSION_RESPONSE=$(curl -s -X POST "$SUPABASE_URL/rest/v1/identity_verifications" \
  -H "apikey: $SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "session_id": "'"$SESSION_ID"'",
    "user_uuid": "'"$USER_ID"'",
    "user_id": "'"$USER_ID"'",
    "email": "'"$TEST_EMAIL"'",
    "verificamex_session_id": "'"$VERIFICAMEX_SESSION_ID"'",
    "status": "OPEN"
  }')

VERIFICATION_ID=$(echo "$CREATE_SESSION_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$VERIFICATION_ID" ]; then
  echo "❌ ERROR: No se pudo crear la sesión de verificación"
  echo "Respuesta: $CREATE_SESSION_RESPONSE"
  exit 1
fi

echo "   ✅ Sesión creada exitosamente"
echo "   🔑 Session ID: $SESSION_ID"
echo "   🔐 VerificaMex Session ID: $VERIFICAMEX_SESSION_ID"
echo "   📋 Verification ID: $VERIFICATION_ID"
echo ""

sleep 2

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3️⃣ SIMULAR WEBHOOK DE VERIFICAMEX (ÉXITO)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "3️⃣ SIMULANDO WEBHOOK DE VERIFICAMEX (Verificación exitosa)..."

# ⚠️ AQUÍ SÍ USAR ANON_KEY (simula la llamada real del webhook)
WEBHOOK_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$SUPABASE_URL/functions/v1/verificamex_webhook" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "id": "'"$VERIFICAMEX_SESSION_ID"'",
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
        "session_id": "'"$SESSION_ID"'",
        "user_uuid": "'"$USER_ID"'"
      }
    }
  }')

WEBHOOK_HTTP_CODE=$(echo "$WEBHOOK_RESPONSE" | tail -n1)
WEBHOOK_BODY=$(echo "$WEBHOOK_RESPONSE" | sed '$d')

if [ "$WEBHOOK_HTTP_CODE" -eq 200 ]; then
  echo "   ✅ Webhook procesado exitosamente (HTTP $WEBHOOK_HTTP_CODE)"
else
  echo "   ⚠️  Webhook con status HTTP $WEBHOOK_HTTP_CODE"
  echo "   Respuesta: $WEBHOOK_BODY"
fi
echo ""

sleep 3

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4️⃣ VERIFICAR ACTUALIZACIÓN EN BASE DE DATOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "4️⃣ VERIFICANDO ACTUALIZACIÓN EN BASE DE DATOS..."

# 🔑 USAR SERVICE_ROLE_KEY PARA CONSULTAS
VERIFICATION_STATUS=$(curl -s "$SUPABASE_URL/rest/v1/identity_verifications?select=status,verification_result,ine_status,curp_status,failure_reason&session_id=eq.$SESSION_ID" \
  -H "apikey: $SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY")

echo "   📊 Estado en identity_verifications:"
echo "$VERIFICATION_STATUS" | python3 -m json.tool 2>/dev/null || echo "$VERIFICATION_STATUS"
echo ""

USER_STATUS=$(curl -s "$SUPABASE_URL/rest/v1/users?select=uuid,name,email,verification_status&uuid=eq.$USER_ID" \
  -H "apikey: $SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY")

echo "   👤 Estado en users:"
echo "$USER_STATUS" | python3 -m json.tool 2>/dev/null || echo "$USER_STATUS"
echo ""

# ... resto del script sin cambios (sección 5 y 6) ...