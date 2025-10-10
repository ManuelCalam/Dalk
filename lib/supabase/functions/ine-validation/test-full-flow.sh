#!/bin/bash
# filepath: /Users/noeibarra/Documents/ceti/7mo_semestre /proyecto/dalk/lib/supabase/functions/ine-validation/test-index-flow.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🧪 TEST EXACTO DEL FLUJO INDEX.TS    ║${NC}"
echo -e "${BLUE}║  Simula comportamiento de Verificamex ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

BASE_URL="https://bsactypehgxluqyaymui.supabase.co/functions/v1/ine-validation"

# ========================================
# PASO 1: CREATE_SESSION (línea 177-300)
# ========================================
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📍 PASO 1: createVerificationSession()${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Simula: Usuario presiona 'Continuar' en la app${NC}"
echo -e "${YELLOW}📝 Función: createVerificationSession() línea 177${NC}\n"

sleep 1

CREATE_PAYLOAD='{
  "action": "create_session",
  "user_id": "test_user_'$(date +%s)'",
  "email": "test@dalk.com"
}'

echo -e "${BLUE}📤 Enviando POST a: ${BASE_URL}${NC}"
echo -e "${BLUE}📦 Payload:${NC}"
echo "$CREATE_PAYLOAD" | jq '.'

CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$CREATE_PAYLOAD")

HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$CREATE_RESPONSE" | sed '$d')

echo -e "\n${BLUE}📥 HTTP Status: ${HTTP_CODE}${NC}"
echo -e "${BLUE}📥 Respuesta:${NC}"
echo "$RESPONSE_BODY" | jq '.'

if [ "$HTTP_CODE" != "200" ]; then
  echo -e "\n${RED}❌ FALLO: createVerificationSession() no respondió 200${NC}"
  exit 1
fi

SESSION_ID=$(echo "$RESPONSE_BODY" | jq -r '.session_id')
VERIFICAMEX_ID=$(echo "$RESPONSE_BODY" | jq -r '.verificamex_session_id')
FORM_URL=$(echo "$RESPONSE_BODY" | jq -r '.form_url')

if [ "$SESSION_ID" == "null" ] || [ "$VERIFICAMEX_ID" == "null" ]; then
  echo -e "\n${RED}❌ FALLO: No se creó la sesión correctamente${NC}"
  exit 1
fi

echo -e "\n${GREEN}✅ ÉXITO: Sesión creada en BD${NC}"
echo -e "${GREEN}   ├─ session_id: ${SESSION_ID}${NC}"
echo -e "${GREEN}   ├─ verificamex_session_id: ${VERIFICAMEX_ID}${NC}"
echo -e "${GREEN}   ├─ status: pending (en BD)${NC}"
echo -e "${GREEN}   └─ form_url: ${FORM_URL}${NC}"

# ========================================
# PASO 2: CHECK STATUS - Estado inicial (línea 37-76)
# ========================================
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📍 PASO 2: Endpoint check-status (GET)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Simula: GitHub Pages hace polling (línea 37-76)${NC}\n"

sleep 2

echo -e "${BLUE}📤 Enviando GET a: ${BASE_URL}/check-status?session_id=${SESSION_ID}${NC}"

CHECK_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${BASE_URL}/check-status?session_id=${SESSION_ID}")

HTTP_CODE=$(echo "$CHECK_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$CHECK_RESPONSE" | sed '$d')

echo -e "\n${BLUE}📥 HTTP Status: ${HTTP_CODE}${NC}"
echo -e "${BLUE}📥 Respuesta:${NC}"
echo "$RESPONSE_BODY" | jq '.'

INITIAL_STATUS=$(echo "$RESPONSE_BODY" | jq -r '.status')

if [ "$INITIAL_STATUS" == "pending" ]; then
  echo -e "\n${GREEN}✅ ÉXITO: Status inicial es 'pending'${NC}"
else
  echo -e "\n${YELLOW}⚠️  ADVERTENCIA: Status es '${INITIAL_STATUS}' (esperado: 'pending')${NC}"
  echo -e "${YELLOW}    Puede que Verificamex ya haya enviado webhook OPEN${NC}"
fi

# ========================================
# PASO 3: WEBHOOK OPEN - Verificamex notifica inicio (línea 305-413)
# ========================================
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📍 PASO 3: handleVerificamexWebhook() - Status OPEN${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Simula: Verificamex envía webhook inicial (status: OPEN)${NC}"
echo -e "${YELLOW}📝 Función: handleVerificamexWebhook() línea 305${NC}\n"

sleep 2

WEBHOOK_OPEN_PAYLOAD=$(cat <<EOF
{
  "data": {
    "object": "VerificationSession",
    "id": "${VERIFICAMEX_ID}",
    "status": "OPEN",
    "result": null,
    "errors": null,
    "comments": null,
    "only_mobile_devices": true,
    "redirect_url": "intent://verificamex/success?session_id=${SESSION_ID}",
    "webhook": "${BASE_URL}",
    "validations": ["INE", "CURP"],
    "optionals": {
      "session_id": "${SESSION_ID}",
      "temp_user_id": "test_user",
      "email": "test@dalk.com",
      "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z")"
    },
    "ine_reading": null,
    "form_url": "${FORM_URL}",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z")",
    "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z")",
    "readable_created_at": "hace 0 segundos",
    "readable_updated_at": "hace 0 segundos"
  },
  "meta": {
    "include": ["ine", "renapo", "files"],
    "custom": []
  },
  "ine": null,
  "renapo": null
}
EOF
)

echo -e "${BLUE}📤 Enviando POST (webhook OPEN) a: ${BASE_URL}${NC}"
echo -e "${BLUE}📦 Payload:${NC}"
echo "$WEBHOOK_OPEN_PAYLOAD" | jq '.'

WEBHOOK_OPEN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$WEBHOOK_OPEN_PAYLOAD")

HTTP_CODE=$(echo "$WEBHOOK_OPEN_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$WEBHOOK_OPEN_RESPONSE" | sed '$d')

echo -e "\n${BLUE}📥 HTTP Status: ${HTTP_CODE}${NC}"
echo -e "${BLUE}📥 Respuesta:${NC}"
echo "$RESPONSE_BODY" | jq '.'

if [ "$HTTP_CODE" == "200" ]; then
  NEW_STATUS=$(echo "$RESPONSE_BODY" | jq -r '.status')
  echo -e "\n${GREEN}✅ ÉXITO: Webhook OPEN procesado${NC}"
  echo -e "${GREEN}   └─ Nuevo status en BD: ${NEW_STATUS}${NC}"
else
  echo -e "\n${RED}❌ FALLO: handleVerificamexWebhook() no procesó el webhook OPEN${NC}"
fi

# ========================================
# PASO 4: Usuario toma fotos
# ========================================
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⏳ Simulando que el usuario toma fotos de INE y CURP...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
sleep 3
echo -e "${GREEN}📸 Fotos tomadas (simulado)${NC}"

# ========================================
# PASO 5: WEBHOOK FINISHED - Verificamex envía resultado (línea 305-413)
# ========================================
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📍 PASO 5: handleVerificamexWebhook() - Status FINISHED${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Simula: Verificamex envía resultado final (status: FINISHED)${NC}"
echo -e "${YELLOW}📝 Función: handleVerificamexWebhook() línea 305${NC}"
echo -e "${YELLOW}📝 Condiciones de éxito (línea 369-374):${NC}"
echo -e "${YELLOW}    - status === 'FINISHED'${NC}"
echo -e "${YELLOW}    - result >= 90${NC}"
echo -e "${YELLOW}    - ine?.data?.status === true${NC}"
echo -e "${YELLOW}    - renapo?.data?.status === true${NC}\n"

sleep 2

WEBHOOK_FINISHED_PAYLOAD=$(cat <<EOF
{
  "data": {
    "object": "VerificationSession",
    "id": "${VERIFICAMEX_ID}",
    "status": "FINISHED",
    "result": 95,
    "errors": null,
    "comments": null,
    "only_mobile_devices": true,
    "redirect_url": "intent://verificamex/success?session_id=${SESSION_ID}",
    "webhook": "${BASE_URL}",
    "validations": ["INE", "CURP"],
    "optionals": {
      "session_id": "${SESSION_ID}",
      "temp_user_id": "test_user",
      "email": "test@dalk.com",
      "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z")"
    },
    "ine_reading": {
      "DocumentData": [
        {
          "field": "name",
          "value": "JUAN CARLOS"
        },
        {
          "field": "last_name",
          "value": "PEREZ GARCIA"
        },
        {
          "field": "curp",
          "value": "PEGJ850101HDFRNS09"
        }
      ],
      "DocumentVerifications": [
        {
          "name": "hologram_validation",
          "status": true
        },
        {
          "name": "photo_validation",
          "status": true
        }
      ]
    },
    "form_url": "${FORM_URL}",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z")",
    "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z")",
    "readable_created_at": "hace 2 minutos",
    "readable_updated_at": "hace 0 segundos"
  },
  "meta": {
    "include": ["ine", "renapo", "files"],
    "custom": []
  },
  "ine": {
    "data": {
      "status": true,
      "name": "JUAN CARLOS",
      "last_name": "PEREZ GARCIA",
      "curp": "PEGJ850101HDFRNS09",
      "credential_number": "1234567890123",
      "birth_date": "1985-01-01",
      "valid": true
    }
  },
  "renapo": {
    "data": {
      "status": true,
      "curp": "PEGJ850101HDFRNS09",
      "name": "JUAN CARLOS",
      "first_surname": "PEREZ",
      "second_surname": "GARCIA",
      "birth_date": "01/01/1985",
      "valid": true
    }
  }
}
EOF
)

echo -e "${BLUE}📤 Enviando POST (webhook FINISHED) a: ${BASE_URL}${NC}"
echo -e "${BLUE}📦 Payload (extracto):${NC}"
echo "$WEBHOOK_FINISHED_PAYLOAD" | jq '{
  data: {
    status: .data.status,
    result: .data.result
  },
  ine: {
    data: {
      status: .ine.data.status
    }
  },
  renapo: {
    data: {
      status: .renapo.data.status
    }
  }
}'

WEBHOOK_FINISHED_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$WEBHOOK_FINISHED_PAYLOAD")

HTTP_CODE=$(echo "$WEBHOOK_FINISHED_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$WEBHOOK_FINISHED_RESPONSE" | sed '$d')

echo -e "\n${BLUE}📥 HTTP Status: ${HTTP_CODE}${NC}"
echo -e "${BLUE}📥 Respuesta:${NC}"
echo "$RESPONSE_BODY" | jq '.'

if [ "$HTTP_CODE" == "200" ]; then
  WEBHOOK_STATUS=$(echo "$RESPONSE_BODY" | jq -r '.status')
  echo -e "\n${GREEN}✅ ÉXITO: Webhook FINISHED procesado${NC}"
  echo -e "${GREEN}   └─ Nuevo status en BD: ${WEBHOOK_STATUS}${NC}"
  
  if [ "$WEBHOOK_STATUS" == "completed" ]; then
    echo -e "${GREEN}   └─ ✅ Condiciones de éxito cumplidas (línea 369-374)${NC}"
  else
    echo -e "${YELLOW}   └─ ⚠️  Status no es 'completed': ${WEBHOOK_STATUS}${NC}"
  fi
else
  echo -e "\n${RED}❌ FALLO: handleVerificamexWebhook() no procesó el webhook FINISHED${NC}"
fi

# ========================================
# PASO 6: CHECK STATUS FINAL (línea 37-76)
# ========================================
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📍 PASO 6: Verificar status final (GET)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Simula: GitHub Pages detecta 'completed' y redirige${NC}\n"

sleep 2

echo -e "${BLUE}📤 Enviando GET a: ${BASE_URL}/check-status?session_id=${SESSION_ID}${NC}"

FINAL_CHECK_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${BASE_URL}/check-status?session_id=${SESSION_ID}")

HTTP_CODE=$(echo "$FINAL_CHECK_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$FINAL_CHECK_RESPONSE" | sed '$d')

echo -e "\n${BLUE}📥 HTTP Status: ${HTTP_CODE}${NC}"
echo -e "${BLUE}📥 Respuesta completa:${NC}"
echo "$RESPONSE_BODY" | jq '.'

FINAL_STATUS=$(echo "$RESPONSE_BODY" | jq -r '.status')
VERIFICATION_RESULT=$(echo "$RESPONSE_BODY" | jq -r '.verification_result')
COMPLETED_AT=$(echo "$RESPONSE_BODY" | jq -r '.completed_at')

if [ "$FINAL_STATUS" == "completed" ]; then
  echo -e "\n${GREEN}✅ ÉXITO: Status final es 'completed'${NC}"
  echo -e "${GREEN}   ├─ verification_result: ${VERIFICATION_RESULT}${NC}"
  echo -e "${GREEN}   ├─ completed_at: ${COMPLETED_AT}${NC}"
  echo -e "${GREEN}   └─ failure_reason: null${NC}"
else
  echo -e "\n${RED}❌ FALLO: Status final no es 'completed': ${FINAL_STATUS}${NC}"
fi

# ========================================
# RESUMEN FINAL
# ========================================
echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         📊 RESUMEN FINAL              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

echo -e "${CYAN}🔍 Funciones probadas:${NC}"
echo -e "   ├─ ${GREEN}✅${NC} createVerificationSession() (línea 177-300)"
echo -e "   ├─ ${GREEN}✅${NC} Endpoint check-status GET (línea 37-76)"
echo -e "   ├─ ${GREEN}✅${NC} handleVerificamexWebhook() OPEN (línea 305-413)"
echo -e "   ├─ ${GREEN}✅${NC} handleVerificamexWebhook() FINISHED (línea 305-413)"
echo -e "   └─ ${GREEN}✅${NC} Lógica isSuccess (línea 369-374)\n"

echo -e "${CYAN}📋 Datos de la sesión:${NC}"
echo -e "   ├─ session_id: ${YELLOW}${SESSION_ID}${NC}"
echo -e "   ├─ verificamex_id: ${YELLOW}${VERIFICAMEX_ID}${NC}"
echo -e "   ├─ status_inicial: ${YELLOW}${INITIAL_STATUS}${NC}"
echo -e "   ├─ status_final: ${YELLOW}${FINAL_STATUS}${NC}"
echo -e "   └─ verification_result: ${YELLOW}${VERIFICATION_RESULT}${NC}\n"

if [ "$FINAL_STATUS" == "completed" ] && [ "$VERIFICATION_RESULT" == "95" ]; then
  echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ✅ TODAS LAS PRUEBAS EXITOSAS ✅     ║${NC}"
  echo -e "${GREEN}║  El flujo de index.ts funciona OK     ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
  exit 0
else
  echo -e "${RED}╔════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  ❌ ALGUNAS PRUEBAS FALLARON ❌       ║${NC}"
  echo -e "${RED}║  Revisa los logs de Supabase          ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════╝${NC}"
  exit 1
fi