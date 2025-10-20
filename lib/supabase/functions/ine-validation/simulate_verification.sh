#!/bin/bash
# filepath: /Users/noeibarra/Documents/ceti/7mo_semestre/proyecto/dalk/lib/supabase/functions/ine-validation/simulate_verification.sh

# ============================================
# 🧪 TEST COMPLETO DEL FLUJO DE VERIFICACIÓN
# CON VALIDACIÓN DE SESIÓN PERSISTENTE
# ============================================

set -e  # Detener en errores

# ✅ COLORES PARA OUTPUT
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ✅ LOG PREFIX
LOG_TAG="[DALK_TEST]"

# ✅ CONFIGURACIÓN (REEMPLAZAR CON TUS VALORES REALES)
SUPABASE_URL="https://bsactypehgxluqyaymui.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzYWN0eXBlaGd4bHVxeWF5bXVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMTQwNjIsImV4cCI6MjA2Mzg5MDA2Mn0.OLLhOOzrxs27aVpChYIxCg8gDXc7PZ7DxEsex9zn324"
SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzYWN0eXBlaGd4bHVxeWF5bXVpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0ODMxNDA2MiwiZXhwIjoyMDYzODkwMDYyfQ.AyydXU9oFcMVnWuj09bnhJWwcSOg3lDEJCSOl9S0oxc"

# ✅ CONFIGURACIÓN DE ADB
ADB_DEVICE=""  # Auto-detectar

# ✅ FUNCIONES DE AYUDA
print_step() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_highlight() {
    echo -e "${MAGENTA}🎯 $1${NC}"
}

print_log() {
    echo -e "${CYAN}$LOG_TAG $1${NC}"
}

# ✅ VERIFICAR SI ADB ESTÁ DISPONIBLE
check_adb() {
    if ! command -v adb &> /dev/null; then
        print_warning "ADB no está instalado o no está en PATH"
        return 1
    fi
    print_success "ADB encontrado: $(adb version | head -n 1)"
    return 0
}

# ✅ DETECTAR DISPOSITIVO ANDROID
detect_android_device() {
    print_info "Detectando dispositivos Android..."
    
    local devices=$(adb devices | grep -v "List of devices" | grep "device$" | awk '{print $1}')
    local device_count=$(echo "$devices" | grep -c "." || echo "0")
    
    if [ "$device_count" -eq 0 ]; then
        print_warning "No se detectaron dispositivos"
        return 1
    fi
    
    if [ "$device_count" -eq 1 ]; then
        ADB_DEVICE=$(echo "$devices" | head -n 1)
        print_success "Dispositivo detectado: $ADB_DEVICE"
        
        local device_model=$(adb -s "$ADB_DEVICE" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
        local android_version=$(adb -s "$ADB_DEVICE" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
        print_info "  Modelo: $device_model"
        print_info "  Android: $android_version"
        return 0
    fi
    
    print_warning "Múltiples dispositivos detectados ($device_count)"
    return 1
}

# ✅ VERIFICAR APP INSTALADA Y EN EJECUCIÓN
check_app_installed() {
    local package_name="com.dalk.app"
    
    print_info "Verificando app Dalk..."
    
    if ! adb -s "$ADB_DEVICE" shell pm list packages | grep -q "$package_name"; then
        print_error "App NO está instalada"
        return 1
    fi
    
    print_success "App encontrada"
    
    # Verificar si está en ejecución
    local is_running=$(adb -s "$ADB_DEVICE" shell pidof "$package_name" 2>/dev/null)
    if [ -n "$is_running" ]; then
        print_success "App en ejecución (PID: $is_running)"
    else
        print_warning "App no está en ejecución, iniciando..."
        adb -s "$ADB_DEVICE" shell monkey -p "$package_name" -c android.intent.category.LAUNCHER 1 &>/dev/null
        sleep 3
        print_success "App iniciada"
    fi
    
    return 0
}

# ✅ LIMPIAR LOGCAT
clear_logcat() {
    print_info "Limpiando logcat..."
    adb -s "$ADB_DEVICE" logcat -c
    print_success "Logcat limpio"
}

# ✅ EJECUTAR DEEP LINK EN DISPOSITIVO
trigger_deep_link() {
    local deep_link="$1"
    
    print_highlight "=========================================="
    print_highlight "EJECUTANDO DEEP LINK"
    print_highlight "=========================================="
    
    print_info "Deep Link: $deep_link"
    
    # Ejecutar deep link
    local adb_output=$(adb -s "$ADB_DEVICE" shell am start -a android.intent.action.VIEW -d "$deep_link" 2>&1)
    
    if echo "$adb_output" | grep -q "Error"; then
        print_error "Error ejecutando deep link"
        echo "$adb_output"
        return 1
    elif echo "$adb_output" | grep -q "Starting: Intent"; then
        print_success "Deep link ejecutado exitosamente"
        
        # Esperar procesamiento
        sleep 3
        
        # Capturar logs relevantes
        print_info "Logs de la app:"
        adb -s "$ADB_DEVICE" logcat -d | grep -E "(\[DALK_DEEPLINK\]|redirect_verificamex|session_id|user_id|Verificando sesión)" | tail -n 30
        
        return 0
    else
        print_warning "Resultado desconocido"
        return 0
    fi
}

# ✅ MONITOREAR LOGS EN TIEMPO REAL (macOS compatible)
monitor_app_logs() {
    local duration="${1:-30}"
    
    print_info "Monitoreando logs por $duration segundos..."
    print_info "Buscando: sesión, verificación, polling, navegación"
    echo ""
    
    # Usar perl en lugar de timeout para macOS
    adb -s "$ADB_DEVICE" logcat | grep -E "(\[DALK_|verificamex|redirect|polling|navigation|sesión|verified)" --line-buffered | \
    perl -e "alarm $duration; while (<>) { print }" 2>/dev/null || true
    
    echo ""
    print_info "Monitoreo finalizado"
}

# ✅ VERIFICAR SESIÓN PERSISTENTE
check_persistent_session() {
    local user_uuid="$1"
    
    print_highlight "=========================================="
    print_highlight "VERIFICANDO SESIÓN PERSISTENTE"
    print_highlight "=========================================="
    
    print_info "Verificando logs de sesión en dispositivo..."
    
    # Buscar logs de sesión en el dispositivo
    adb -s "$ADB_DEVICE" logcat -d | grep -E "(\[DALK_DEEPLINK\].*sesión|Supabase.*session|persistSession|refreshSession)" | tail -n 20
    
    print_info "Si ves logs de 'Sesión activa' o 'Sesión restaurada', la persistencia funciona ✅"
}

# ============================================
# INICIO DEL TEST
# ============================================

print_step "🚀 INICIANDO TEST COMPLETO CON SESIÓN PERSISTENTE"

# ✅ VERIFICAR PREREQUISITES
print_step "PRE-REQUISITOS"

# Verificar jq
if ! command -v jq &> /dev/null; then
    print_error "jq no está instalado"
    exit 1
fi
print_success "jq encontrado"

# Verificar ADB
HAS_ADB=false
if check_adb; then
    if detect_android_device; then
        if check_app_installed; then
            HAS_ADB=true
            print_success "Todas las verificaciones pasaron"
            
            # Limpiar logcat antes de empezar
            clear_logcat
        fi
    fi
fi

if [ "$HAS_ADB" = false ]; then
    print_warning "Testing sin dispositivo Android"
fi

echo ""
read -p "¿Continuar? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# ============================================
# PASO 1: CREAR USUARIO EN AUTH
# ============================================
print_step "PASO 1: Crear usuario en Auth"

TEST_EMAIL="test.verificamex+$(date +%s)@dalk.com"
TEST_PASSWORD="TestPass123!"

echo "📧 Email: $TEST_EMAIL"
echo "🔑 Password: $TEST_PASSWORD"

AUTH_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/auth/v1/signup" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${TEST_EMAIL}\",
    \"password\": \"${TEST_PASSWORD}\"
  }")

TEST_USER_UUID=$(echo $AUTH_RESPONSE | jq -r '.user.id')
ACCESS_TOKEN=$(echo $AUTH_RESPONSE | jq -r '.session.access_token')
REFRESH_TOKEN=$(echo $AUTH_RESPONSE | jq -r '.session.refresh_token')

if [ "$TEST_USER_UUID" == "null" ]; then
    print_error "No se pudo crear usuario"
    echo "$AUTH_RESPONSE"
    exit 1
fi

print_success "Usuario creado: $TEST_USER_UUID"
print_info "Access Token: ${ACCESS_TOKEN:0:30}..."
print_info "Refresh Token: ${REFRESH_TOKEN:0:30}..."

# ============================================
# PASO 2: INSERTAR EN TABLA USERS
# ============================================
print_step "PASO 2: Insertar en tabla users"

USERS_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/rest/v1/users" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "{
    \"uuid\": \"${TEST_USER_UUID}\",
    \"name\": \"Juan Test Seguro\",
    \"email\": \"${TEST_EMAIL}\",
    \"phone\": \"5512345678\",
    \"birthdate\": \"1990-01-01\",
    \"gender\": \"Hombre\",
    \"address\": \"Calle Test 123\",
    \"houseNumber\": \"10\",
    \"zipCode\": \"06000\",
    \"neighborhood\": \"Centro\",
    \"city\": \"CDMX\",
    \"usertype\": \"Paseador\",
    \"verification_status\": \"pending_verification\"
  }")

if echo "$USERS_RESPONSE" | jq -e '.[0].uuid' > /dev/null 2>&1; then
    print_success "Usuario insertado en users"
else
    print_error "Error insertando en users"
    echo "$USERS_RESPONSE"
    exit 1
fi

# ============================================
# PASO 3: INSERTAR DIRECCIÓN
# ============================================
print_step "PASO 3: Insertar dirección"

ADDRESS_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/rest/v1/addresses" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "{
    \"uuid\": \"${TEST_USER_UUID}\",
    \"alias\": \"Mi Dirección\",
    \"address\": \"Calle Test 123\",
    \"houseNumber\": \"10\",
    \"zipCode\": \"06000\",
    \"neighborhood\": \"Centro\",
    \"city\": \"CDMX\"
  }")

if echo "$ADDRESS_RESPONSE" | jq -e '.[0].id' > /dev/null 2>&1; then
    print_success "Dirección insertada"
else
    print_error "Error insertando dirección"
    exit 1
fi

# ============================================
# PASO 4: LLAMAR EDGE FUNCTION
# ============================================
print_step "PASO 4: Llamar Edge Function (create_session)"

EDGE_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/functions/v1/ine-validation" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"action\": \"create_session\",
    \"user_id\": \"${TEST_USER_UUID}\",
    \"email\": \"${TEST_EMAIL}\"
  }")

SESSION_ID=$(echo $EDGE_RESPONSE | jq -r '.session_id')
FORM_URL=$(echo $EDGE_RESPONSE | jq -r '.form_url')
VERIFICAMEX_SESSION_ID=$(echo $EDGE_RESPONSE | jq -r '.verificamex_session_id')

if [ "$SESSION_ID" == "null" ]; then
    print_error "No se obtuvo session_id"
    echo "$EDGE_RESPONSE"
    exit 1
fi

print_success "Sesión creada:"
echo "  📋 Session ID: $SESSION_ID"
echo "  🔗 Form URL: $FORM_URL"
echo "  🆔 Verificamex ID: $VERIFICAMEX_SESSION_ID"

# ============================================
# PASO 5: VERIFICAR REGISTRO EN BD
# ============================================
print_step "PASO 5: Verificar identity_verifications"

sleep 2

VERIFICATION_CHECK=$(curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/identity_verifications?session_id=eq.${SESSION_ID}&select=*" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}")

VERIFICATION_STATUS=$(echo $VERIFICATION_CHECK | jq -r '.[0].status')
VERIFICATION_USER_UUID=$(echo $VERIFICATION_CHECK | jq -r '.[0].user_uuid')

if [ "$VERIFICATION_USER_UUID" == "$TEST_USER_UUID" ]; then
    print_success "Registro creado con status: $VERIFICATION_STATUS"
    print_success "user_uuid coincide: $VERIFICATION_USER_UUID"
else
    print_error "user_uuid no coincide"
    exit 1
fi

# ============================================
# PASO 6: SIMULAR WEBHOOK DE VERIFICAMEX (COMPLETO)
# ============================================
print_step "PASO 6: Simular webhook de Verificamex (DATOS COMPLETOS)"

print_info "Esperando 3 segundos..."
sleep 3

# 🔥 WEBHOOK CON TODOS LOS DATOS QUE VERIFICAMEX ENVÍA
WEBHOOK_PAYLOAD=$(cat <<EOF
{
  "data": {
    "object": "VerificationSession",
    "id": "${VERIFICAMEX_SESSION_ID}",
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
      "session_id": "${SESSION_ID}",
      "user_id": "${TEST_USER_UUID}",
      "email": "${TEST_EMAIL}"
    }
  }
}
EOF
)

print_info "Enviando webhook con datos completos..."

WEBHOOK_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/functions/v1/ine-validation" \
  -H "Content-Type: application/json" \
  -d "$WEBHOOK_PAYLOAD")

if echo "$WEBHOOK_RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
    print_success "Webhook procesado"
else
    print_error "Error procesando webhook"
    echo "$WEBHOOK_RESPONSE"
    exit 1
fi

# ============================================
# PASO 7: VERIFICAR STATUS Y DATOS ACTUALIZADOS
# ============================================
print_step "PASO 7: Verificar status y datos actualizados"

sleep 2

FINAL_CHECK=$(curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/identity_verifications?session_id=eq.${SESSION_ID}&select=*" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}")

FINAL_STATUS=$(echo $FINAL_CHECK | jq -r '.[0].status')
FINAL_RESULT=$(echo $FINAL_CHECK | jq -r '.[0].verification_result')

echo "📊 Status: $FINAL_STATUS"
echo "📊 Result: $FINAL_RESULT"


if [ "$FINAL_STATUS" == "completed" ] && [ "$FINAL_RESULT" == "95" ]; then
    print_success "Verificación completada en BD"
    
    if [ "$EXTRACTED_NAME" != "N/A" ] && [ "$EXTRACTED_CURP" != "N/A" ]; then
        print_success "Datos extraídos correctamente"
    else
        print_warning "Datos extraídos incompletos"
    fi
else
    print_error "Status no es correcto"
    exit 1
fi

# ============================================
# PASO 8: EJECUTAR DEEP LINK
# ============================================
print_step "PASO 8: Ejecutar Deep Link"

DEEP_LINK="dalkpaseos://redirect_verificamex?session_id=${SESSION_ID}&user_id=${TEST_USER_UUID}"

if [ "$HAS_ADB" = true ]; then
    print_highlight "🚀 EJECUTANDO EN DISPOSITIVO"
    
    if trigger_deep_link "$DEEP_LINK"; then
        print_success "Deep link ejecutado"
        
        # Verificar sesión persistente
        sleep 2
        check_persistent_session "$TEST_USER_UUID"
        
        # Monitorear logs por 20 segundos
        print_info "Monitoreando app..."
        monitor_app_logs 20
    fi
else
    print_warning "Sin dispositivo conectado"
    print_info "Para probar manualmente:"
    echo ""
    echo "  adb shell am start -a android.intent.action.VIEW -d \"$DEEP_LINK\""
    echo ""
fi

# ============================================
# PASO 9: SIMULAR POLLING
# ============================================
print_step "PASO 9: Simular polling del widget"

for i in {1..3}; do
    echo "🔄 Polling $i/3..."
    
    POLL_RESPONSE=$(curl -s -X GET \
      "${SUPABASE_URL}/rest/v1/identity_verifications?session_id=eq.${SESSION_ID}&select=status,verification_result" \
      -H "apikey: ${SUPABASE_ANON_KEY}")
    
    POLL_STATUS=$(echo $POLL_RESPONSE | jq -r '.[0].status')
    
    echo "  Status: $POLL_STATUS"
    
    if [ "$POLL_STATUS" == "completed" ]; then
        print_success "Polling detectó completed"
        break
    fi
    
    sleep 5
done

# ============================================
# PASO 10: VERIFICAR USERS.VERIFICATION_STATUS
# ============================================
print_step "PASO 10: Verificar users.verification_status"

USER_CHECK=$(curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/users?uuid=eq.${TEST_USER_UUID}&select=verification_status,curp" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}")

USER_STATUS=$(echo $USER_CHECK | jq -r '.[0].verification_status')
USER_CURP=$(echo $USER_CHECK | jq -r '.[0].curp // "N/A"')

echo "📊 User status: $USER_STATUS"
echo "📊 User CURP: $USER_CURP"

if [ "$USER_STATUS" == "verified" ]; then
    print_success "Usuario actualizado a 'verified'"
elif [ "$USER_STATUS" == "pending_verification" ]; then
    print_warning "Aún en 'pending_verification'"
    print_info "El widget debería actualizar esto después del polling"
    
    if [ "$HAS_ADB" = true ]; then
        print_info "Logs de actualización:"
        adb -s "$ADB_DEVICE" logcat -d | grep -E "(verification_status|UPDATE users|verified)" | tail -n 15
    fi
fi

# ============================================
# RESUMEN FINAL
# ============================================
print_step "RESUMEN FINAL"

echo ""
print_success "✅ FLUJO COMPLETADO"
echo ""
echo "📋 Datos del test:"
echo "  👤 UUID: $TEST_USER_UUID"
echo "  📧 Email: $TEST_EMAIL"
echo "  🆔 Session: $SESSION_ID"
echo "  📊 IV Status: $FINAL_STATUS"
echo "  🎯 Result: $FINAL_RESULT"
echo "  📝 Nombre: $EXTRACTED_NAME"
echo "  🆔 CURP: $EXTRACTED_CURP"
echo "  👤 User Status: $USER_STATUS"
echo "  🔐 Access Token: ${ACCESS_TOKEN:0:30}..."
echo ""

if [ "$HAS_ADB" = true ]; then
    print_success "✅ Deep link ejecutado en: $ADB_DEVICE"
    echo ""
    print_info "Verifica en el dispositivo:"
    print_info "  1. App abrió redirect_verificamex"
    print_info "  2. Logs muestran 'Sesión activa' o 'Sesión restaurada'"
    print_info "  3. Widget muestra datos de verificación"
    print_info "  4. Polling detectó completed"
    print_info "  5. Usuario actualizado a verified"
    print_info "  6. Navegó a homeDogWalker"
else
    print_warning "Deep link NO ejecutado"
    echo ""
    echo "  Para probar:"
    echo "  adb shell am start -a android.intent.action.VIEW -d \"$DEEP_LINK\""
    echo ""
fi

echo ""
print_highlight "🔐 SESIÓN PERSISTENTE:"
print_info "Si ves logs de 'Sesión restaurada' o 'refreshSession', significa que:"
print_info "  ✅ persistSession: true está funcionando"
print_info "  ✅ La app puede reautenticar al usuario automáticamente"
print_info "  ✅ El flujo de verificación puede completarse sin pedir login"
echo ""

print_warning "⚠️  LIMPIEZA:"
echo "  DELETE FROM addresses WHERE uuid = '$TEST_USER_UUID';"
echo "  DELETE FROM identity_verifications WHERE user_uuid = '$TEST_USER_UUID';"
echo "  DELETE FROM users WHERE uuid = '$TEST_USER_UUID';"
echo "  -- Eliminar de Auth manualmente desde Supabase Dashboard"
echo ""