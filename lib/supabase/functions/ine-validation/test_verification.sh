#!/bin/bash

# ✅ COLORES
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🧪 TEST DE VERIFICACIÓN DALK${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ✅ CONFIGURACIÓN
SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzYWN0eXBlaGd4bHVxeWF5bXVpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0ODMxNDA2MiwiZXhwIjoyMDYzODkwMDYyfQ.AyydXU9oFcMVnWuj09bnhJWwcSOg3lDEJCSOl9S0oxc"
SUPABASE_URL="https://bsactypehgxluqyaymui.supabase.co"

TEST_USER_UUID="00000000-0000-0000-0000-000000000001"
TEST_EMAIL="test@dalk.com"
PACKAGE_NAME="com.dalk.app"

echo -e "${GREEN}✅ Configuración cargada${NC}"
echo ""

echo -e "${BLUE}========================================${NC}"
echo ""

# ✅ TEST 0: VERIFICAR/CREAR USUARIO
echo -e "${YELLOW}🔍 TEST 0: Verificando usuario de prueba...${NC}"
echo ""

USER_EXISTS=$(curl -s --max-time 10 \
  "$SUPABASE_URL/rest/v1/users?uuid=eq.$TEST_USER_UUID&select=uuid,verification_status" \
  -H "apikey: $SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY")

echo -e "${BLUE}📊 Usuario:${NC}"
echo "$USER_EXISTS" | jq '.' 2>/dev/null || echo "$USER_EXISTS"

if echo "$USER_EXISTS" | jq -e '. | length == 0' > /dev/null 2>&1; then
  echo -e "${YELLOW}⚠️ Usuario no existe. Creándolo...${NC}"
  
  CREATE_USER=$(curl -s --max-time 10 -X POST \
    "$SUPABASE_URL/rest/v1/users" \
    -H "Content-Type: application/json" \
    -H "apikey: $SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
    -H "Prefer: return=representation" \
    -d "{
      \"uuid\": \"$TEST_USER_UUID\",
      \"name\": \"Test User\",
      \"email\": \"$TEST_EMAIL\",
      \"usertype\": \"Paseador\",
      \"verification_status\": \"pending_verification\"
    }")
  
  echo "$CREATE_USER" | jq '.' 2>/dev/null || echo "$CREATE_USER"
  
  if echo "$CREATE_USER" | jq -e '.[0].uuid' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Usuario creado${NC}"
  else
    echo -e "${RED}❌ Error creando usuario${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}✅ Usuario existe${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo ""

# ✅ TEST 1: CREAR SESIÓN
echo -e "${YELLOW}📡 TEST 1: Creando sesión de verificación...${NC}"
echo ""

RESPONSE=$(curl -s --max-time 15 -X POST \
  "$SUPABASE_URL/functions/v1/ine-validation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -d "{
    \"action\": \"create_session\",
    \"user_uuid\": \"$TEST_USER_UUID\",
    \"email\": \"$TEST_EMAIL\"
  }")

echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"

if echo "$RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Sesión creada${NC}"
  FORM_URL=$(echo "$RESPONSE" | jq -r '.form_url')
  SESSION_ID=$(echo "$RESPONSE" | jq -r '.session_id')
  echo -e "${GREEN}🔗 Form URL: $FORM_URL${NC}"
  echo -e "${GREEN}🆔 Session ID: $SESSION_ID${NC}"
else
  echo -e "${RED}❌ Error creando sesión${NC}"
  ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // .message // "Error desconocido"')
  echo -e "${RED}💥 Error: $ERROR_MSG${NC}"
  exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo ""

# ✅ TEST 2: WEBHOOK
echo -e "${YELLOW}📨 TEST 2: Simulando webhook de Verificamex...${NC}"
echo ""

WEBHOOK_PAYLOAD='{
  "data": {
    "id": "'$SESSION_ID'",
    "status": "FINISHED",
    "result": 95,
    "ine": {
      "status": true
    },
    "curp": {
      "valid": true
    },
    "optionals": {
      "user_uuid": "'$TEST_USER_UUID'",
      "email": "'$TEST_EMAIL'"
    }
  }
}'

echo -e "${BLUE}📦 Payload:${NC}"
echo "$WEBHOOK_PAYLOAD" | jq '.' 2>/dev/null

WEBHOOK_RESPONSE=$(curl -s --max-time 10 -X POST \
  "$SUPABASE_URL/functions/v1/ine-validation" \
  -H "Content-Type: application/json" \
  -d "$WEBHOOK_PAYLOAD")

echo -e "${BLUE}📊 Respuesta:${NC}"
echo "$WEBHOOK_RESPONSE" | jq '.' 2>/dev/null || echo "$WEBHOOK_RESPONSE"

if echo "$WEBHOOK_RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Webhook procesado${NC}"
  VERIFICATION_STATUS=$(echo "$WEBHOOK_RESPONSE" | jq -r '.verification_status')
  echo -e "${GREEN}🎯 Status: $VERIFICATION_STATUS${NC}"
else
  echo -e "${RED}❌ Error en webhook${NC}"
  ERROR_MSG=$(echo "$WEBHOOK_RESPONSE" | jq -r '.error // .message // "Error desconocido"')
  echo -e "${RED}💥 Error: $ERROR_MSG${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo ""

# ✅ TEST 3: DEEP LINK
echo -e "${YELLOW}📱 TEST 3: Probando Deep Link...${NC}"
echo ""

# ✅ VALIDAR QUE SESSION_ID NO ESTÉ VACÍO
if [ -z "$SESSION_ID" ]; then
  echo -e "${RED}❌ SESSION_ID está vacío. TEST 1 falló.${NC}"
  echo -e "${YELLOW}⏭️  Saltando TEST 3${NC}"
  exit 1
fi

DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
  echo -e "${RED}❌ No hay dispositivos conectados${NC}"
  echo -e "${YELLOW}⏭️  Saltando TEST 3${NC}"
else
  echo -e "${GREEN}✅ Dispositivo(s) conectado(s): $DEVICES${NC}"
  
  APP_INSTALLED=$(adb shell pm list packages | grep "$PACKAGE_NAME" | wc -l)
  
  if [ "$APP_INSTALLED" -eq 0 ]; then
    echo -e "${RED}❌ App no instalada: $PACKAGE_NAME${NC}"
  else
    echo -e "${GREEN}✅ App instalada: $PACKAGE_NAME${NC}"
    echo ""
    
    # ✅ DEEP LINK CON SESSION_ID
    DEEP_LINK="dalkpaseos://verificamex?user_id=$TEST_USER_UUID&session_id=$SESSION_ID"
    
    echo -e "${BLUE}🔗 Deep Link a probar:${NC}"
    echo -e "${BLUE}   $DEEP_LINK${NC}"
    echo ""
    
    # Verificar intent-filters
    echo -e "${BLUE}🔍 Intent-filters instalados:${NC}"
    adb shell dumpsys package "$PACKAGE_NAME" | grep -A 5 "dalkpaseos"
    echo ""
    
    # Matar la app si está abierta
    echo -e "${YELLOW}🔄 Cerrando app...${NC}"
    adb shell am force-stop "$PACKAGE_NAME"
    sleep 1
    
    # Abrir Deep Link
    echo -e "${YELLOW}📲 Abriendo Deep Link...${NC}"
    adb shell am start -W -a android.intent.action.VIEW -d "$DEEP_LINK"
    
    sleep 3
    
    # Verificar si se abrió
    CURRENT_FOCUS=$(adb shell dumpsys window windows | grep -E "mCurrentFocus")
    echo -e "${BLUE}📱 App en foco:${NC}"
    echo "$CURRENT_FOCUS"
    
    if echo "$CURRENT_FOCUS" | grep -q "$PACKAGE_NAME"; then
      echo -e "${GREEN}✅ La app se abrió correctamente${NC}"
      
      echo ""
      echo -e "${BLUE}📋 Logs de Flutter:${NC}"
      adb logcat -d -s flutter:I | grep -i "deep\|link\|verificamex\|redirect" | tail -20
    else
      echo -e "${RED}❌ La app no se abrió${NC}"
      
      echo ""
      echo -e "${BLUE}📋 Logs de Flutter:${NC}"
      adb logcat -d -s flutter:I | tail -20
    fi
  fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ TESTS COMPLETADOS${NC}"
echo -e "${BLUE}========================================${NC}"# ...existing code...

# ...existing code...

# ✅ TEST 3: DEEP LINK
echo -e "${YELLOW}📱 TEST 3: Probando Deep Link...${NC}"
echo ""

# ✅ VALIDAR QUE SESSION_ID NO ESTÉ VACÍO
if [ -z "$SESSION_ID" ]; then
  echo -e "${RED}❌ SESSION_ID está vacío. TEST 1 falló.${NC}"
  echo -e "${YELLOW}⏭️  Saltando TEST 3${NC}"
  exit 1
fi

DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
  echo -e "${RED}❌ No hay dispositivos conectados${NC}"
  echo -e "${YELLOW}⏭️  Saltando TEST 3${NC}"
else
  echo -e "${GREEN}✅ Dispositivo(s) conectado(s): $DEVICES${NC}"
  
  APP_INSTALLED=$(adb shell pm list packages | grep "$PACKAGE_NAME" | wc -l)
  
  if [ "$APP_INSTALLED" -eq 0 ]; then
    echo -e "${RED}❌ App no instalada: $PACKAGE_NAME${NC}"
  else
    echo -e "${GREEN}✅ App instalada: $PACKAGE_NAME${NC}"
    echo ""
    
    # ✅ PROBAR AMBOS FORMATOS
    
    # Formato 1: Path parameters (RECOMENDADO)
    DEEP_LINK_PATH="dalkpaseos://verificamex/$TEST_USER_UUID/$SESSION_ID"
    
    # Formato 2: Query parameters (FALLBACK)
    DEEP_LINK_QUERY="dalkpaseos://verificamex?user_id=$TEST_USER_UUID&session_id=$SESSION_ID"
    
    echo -e "${BLUE}🔗 Probando formato 1 (path parameters):${NC}"
    echo -e "${BLUE}   $DEEP_LINK_PATH${NC}"
    echo ""
    
    # Matar la app
    echo -e "${YELLOW}🔄 Cerrando app...${NC}"
    adb shell am force-stop "$PACKAGE_NAME"
    sleep 1
    
    # Abrir con path parameters
    echo -e "${YELLOW}📲 Abriendo Deep Link (formato 1)...${NC}"
    adb shell am start -W -a android.intent.action.VIEW -d "$DEEP_LINK_PATH" 2>&1 | head -5
    
    sleep 3
    
    # Verificar logs
    echo -e "${BLUE}📋 Logs de Flutter (últimos 15):${NC}"
    adb logcat -d -s flutter:I | grep -i "deep\|link\|verificamex\|redirect\|session.*id\|user.*id" | tail -15
    
    # Verificar si se abrió
    CURRENT_FOCUS=$(adb shell dumpsys window windows | grep -E "mCurrentFocus")
    
    if echo "$CURRENT_FOCUS" | grep -q "$PACKAGE_NAME"; then
      echo -e "${GREEN}✅ La app se abrió correctamente con formato 1${NC}"
    else
      echo -e "${YELLOW}⚠️ Formato 1 no funcionó, probando formato 2...${NC}"
      echo ""
      
      # Intentar con query parameters
      echo -e "${BLUE}🔗 Probando formato 2 (query parameters):${NC}"
      echo -e "${BLUE}   $DEEP_LINK_QUERY${NC}"
      
      adb shell am force-stop "$PACKAGE_NAME"
      sleep 1
      
      adb shell am start -W -a android.intent.action.VIEW -d "$DEEP_LINK_QUERY" 2>&1 | head -5
      
      sleep 3
      
      echo -e "${BLUE}📋 Logs de Flutter:${NC}"
      adb logcat -d -s flutter:I | grep -i "deep\|link\|verificamex\|redirect" | tail -15
    fi
  fi
fi

# ...existing code...

# ✅ DEEP LINK CON PATH PARAMETERS
DEEP_LINK_PATH="dalkpaseos://verificamex/$TEST_USER_UUID/$SESSION_ID"

echo -e "${BLUE}🔗 Deep Link (formato correcto):${NC}"
echo -e "${BLUE}   $DEEP_LINK_PATH${NC}"

adb shell am start -W -a android.intent.action.VIEW -d "$DEEP_LINK_PATH"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ TESTS COMPLETADOS${NC}"
echo -e "${BLUE}========================================${NC}"