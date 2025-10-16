#!/bin/bash
# filepath: /Users/noeibarra/Documents/ceti/7mo_semestre /proyecto/dalk/lib/supabase/functions/ine-validation/test/test-flow.sh

# ============================================
# 🧪 TEST COMPLETO DEL FLUJO DE VERIFICACIÓN
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

# ✅ CONFIGURACIÓN (REEMPLAZAR CON TUS VALORES REALES)
SUPABASE_URL="https://bsactypehgxluqyaymui.supabase.co"
SUPABASE_ANON_KEY=""
SUPABASE_SERVICE_ROLE_KEY=""

# ✅ EJECUTAR DEEP LINK EN DISPOSITIVO ANDROID
trigger_deep_link() {
    local deep_link="$1"
    
    print_highlight "=========================================="
    print_highlight "EJECUTANDO DEEP LINK EN DISPOSITIVO ANDROID"
    print_highlight "=========================================="
    
    print_info "Deep Link original: $deep_link"
    
    # ✅ ESCAPAR EL & PARA QUE BASH NO LO INTERPRETE COMO "BACKGROUND"
    # Opción 1: Usar \& en lugar de &
    local escaped_link="${deep_link//&/\\&}"
    print_info "Deep Link escapado: $escaped_link"
    
    # ✅ EJECUTAR CON COMILLAS DOBLES Y AMPERSAND ESCAPADO
    print_info "Ejecutando: adb -s \"$ADB_DEVICE\" shell am start -a android.intent.action.VIEW -d \"$escaped_link\""
    
    local adb_output=$(adb -s "$ADB_DEVICE" shell am start -a android.intent.action.VIEW -d "$escaped_link" 2>&1)
    
    echo "$adb_output"
    
    # Verificar resultado
    if echo "$adb_output" | grep -q "Error"; then
        print_error "Error ejecutando deep link"
        print_info "Salida completa: $adb_output"
        return 1
    elif echo "$adb_output" | grep -q "Starting: Intent"; then
        print_success "Deep link ejecutado exitosamente"
        
        # Esperar 3 segundos para que la app procese el deep link
        sleep 3
        
        # Verificar logs de la app (buscar session_id Y user_id)
        print_info "Capturando logs de la app..."
        adb -s "$ADB_DEVICE" logcat -d | grep -E "(🔍|PROCESANDO DEEP LINK|redirect_verificamex|session_id|user_id)" | tail -n 20
        
        return 0
    else
        print_warning "Comando ejecutado pero resultado desconocido"
        print_info "Salida: $adb_output"
        return 0
    fi
}

# ...existing code...# ...existing code...

# ✅ EJECUTAR DEEP LINK EN DISPOSITIVO ANDROID
trigger_deep_link() {
    local deep_link="$1"
    
    print_highlight "=========================================="
    print_highlight "EJECUTANDO DEEP LINK EN DISPOSITIVO ANDROID"
    print_highlight "=========================================="
    
    print_info "Deep Link original: $deep_link"
    
    # ✅ ESCAPAR EL & PARA QUE BASH NO LO INTERPRETE COMO "BACKGROUND"
    # Opción 1: Usar \& en lugar de &
    local escaped_link="${deep_link//&/\\&}"
    print_info "Deep Link escapado: $escaped_link"
    
    # ✅ EJECUTAR CON COMILLAS DOBLES Y AMPERSAND ESCAPADO
    print_info "Ejecutando: adb -s \"$ADB_DEVICE\" shell am start -a android.intent.action.VIEW -d \"$escaped_link\""
    
    local adb_output=$(adb -s "$ADB_DEVICE" shell am start -a android.intent.action.VIEW -d "$escaped_link" 2>&1)
    
    echo "$adb_output"
    
    # Verificar resultado
    if echo "$adb_output" | grep -q "Error"; then
        print_error "Error ejecutando deep link"
        print_info "Salida completa: $adb_output"
        return 1
    elif echo "$adb_output" | grep -q "Starting: Intent"; then
        print_success "Deep link ejecutado exitosamente"
        
        # Esperar 3 segundos para que la app procese el deep link
        sleep 3
        
        # Verificar logs de la app (buscar session_id Y user_id)
        print_info "Capturando logs de la app..."
        adb -s "$ADB_DEVICE" logcat -d | grep -E "(🔍|PROCESANDO DEEP LINK|redirect_verificamex|session_id|user_id)" | tail -n 20
        
        return 0
    else
        print_warning "Comando ejecutado pero resultado desconocido"
        print_info "Salida: $adb_output"
        return 0
    fi
}

# ...existing code...

# ✅ CONFIGURACIÓN DE ADB
ADB_DEVICE=""  # Dejar vacío para auto-detectar o especificar: "emulator-5554" o "device_serial"

# ✅ ARCHIVOS
TEST_DATA_FILE="./test-data.json"
WEBHOOK_SCRIPT="./simulate-webhook.sh"

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

# ✅ VERIFICAR SI ADB ESTÁ DISPONIBLE
check_adb() {
    if ! command -v adb &> /dev/null; then
        print_warning "ADB no está instalado o no está en PATH"
        print_info "Para instalar ADB:"
        print_info "  - Mac: brew install android-platform-tools"
        print_info "  - Windows: Descargar Android SDK Platform Tools"
        print_info "  - Linux: sudo apt-get install android-tools-adb"
        return 1
    fi
    
    print_success "ADB encontrado: $(adb version | head -n 1)"
    return 0
}

# ✅ DETECTAR DISPOSITIVO ANDROID
detect_android_device() {
    print_info "Detectando dispositivos Android conectados..."
    
    local devices=$(adb devices | grep -v "List of devices" | grep "device$" | awk '{print $1}')
    local device_count=$(echo "$devices" | grep -c "." || echo "0")
    
    if [ "$device_count" -eq 0 ]; then
        print_warning "No se detectaron dispositivos Android conectados"
        print_info "Para conectar un dispositivo:"
        print_info "  1. Conecta tu dispositivo Android por USB"
        print_info "  2. Habilita 'Depuración USB' en Opciones de Desarrollador"
        print_info "  3. Ejecuta: adb devices"
        print_info ""
        print_info "O inicia un emulador Android:"
        print_info "  - Android Studio > AVD Manager > Run emulator"
        return 1
    fi
    
    if [ "$device_count" -eq 1 ]; then
        ADB_DEVICE=$(echo "$devices" | head -n 1)
        print_success "Dispositivo detectado: $ADB_DEVICE"
        
        # Mostrar info del dispositivo
        local device_model=$(adb -s "$ADB_DEVICE" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
        local android_version=$(adb -s "$ADB_DEVICE" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
        print_info "  Modelo: $device_model"
        print_info "  Android: $android_version"
        return 0
    fi
    
    # Múltiples dispositivos detectados
    print_warning "Múltiples dispositivos detectados ($device_count):"
    echo "$devices" | while read device; do
        local model=$(adb -s "$device" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
        echo "  - $device ($model)"
    done
    
    print_info "Especifica el dispositivo con: export ADB_DEVICE='device_serial'"
    return 1
}

# ✅ VERIFICAR SI LA APP ESTÁ INSTALADA
check_app_installed() {
    local package_name="com.dalk.app"
    
    print_info "Verificando si Dalk está instalado en el dispositivo..."
    
    if adb -s "$ADB_DEVICE" shell pm list packages | grep -q "$package_name"; then
        print_success "App Dalk encontrada en el dispositivo"
        
        # Verificar si la app está en ejecución
        local is_running=$(adb -s "$ADB_DEVICE" shell pidof "$package_name" 2>/dev/null)
        if [ -n "$is_running" ]; then
            print_success "App está en ejecución (PID: $is_running)"
        else
            print_warning "App no está en ejecución"
            print_info "Iniciando app..."
            adb -s "$ADB_DEVICE" shell monkey -p "$package_name" -c android.intent.category.LAUNCHER 1 &>/dev/null
            sleep 3
            print_success "App iniciada"
        fi
        return 0
    else
        print_error "App Dalk NO está instalada en el dispositivo"
        print_info "Para instalar la app:"
        print_info "  flutter install"
        print_info "  o"
        print_info "  flutter build apk --debug && flutter install"
        return 1
    fi
}

# ✅ EJECUTAR DEEP LINK EN DISPOSITIVO ANDROID
trigger_deep_link() {
    local deep_link="$1"
    
    print_highlight "=========================================="
    print_highlight "EJECUTANDO DEEP LINK EN DISPOSITIVO ANDROID"
    print_highlight "=========================================="
    
    print_info "Deep Link original: $deep_link"
    
    # ✅ ESCAPAR EL & PARA QUE BASH NO LO INTERPRETE COMO "BACKGROUND"
    # Opción 1: Usar \& en lugar de &
    local escaped_link="${deep_link//&/\\&}"
    print_info "Deep Link escapado: $escaped_link"
    
    # ✅ EJECUTAR CON COMILLAS DOBLES Y AMPERSAND ESCAPADO
    print_info "Ejecutando: adb -s \"$ADB_DEVICE\" shell am start -a android.intent.action.VIEW -d \"$escaped_link\""
    
    local adb_output=$(adb -s "$ADB_DEVICE" shell am start -a android.intent.action.VIEW -d "$escaped_link" 2>&1)
    
    echo "$adb_output"
    
    # Verificar resultado
    if echo "$adb_output" | grep -q "Error"; then
        print_error "Error ejecutando deep link"
        print_info "Salida completa: $adb_output"
        return 1
    elif echo "$adb_output" | grep -q "Starting: Intent"; then
        print_success "Deep link ejecutado exitosamente"
        
        # Esperar 3 segundos para que la app procese el deep link
        sleep 3
        
        # Verificar logs de la app (buscar session_id Y user_id)
        print_info "Capturando logs de la app..."
        adb -s "$ADB_DEVICE" logcat -d | grep -E "(🔍|PROCESANDO DEEP LINK|redirect_verificamex|session_id|user_id)" | tail -n 20
        
        return 0
    else
        print_warning "Comando ejecutado pero resultado desconocido"
        print_info "Salida: $adb_output"
        return 0
    fi
}

# ✅ MONITOREAR LOGS DE LA APP EN TIEMPO REAL
monitor_app_logs() {
    local duration_seconds="${1:-30}"
    
    print_info "Monitoreando logs de Dalk por $duration_seconds segundos..."
    print_info "Presiona Ctrl+C para detener"
    
    # Limpiar logcat
    adb -s "$ADB_DEVICE" logcat -c
    
    # Monitorear logs filtrados
    timeout $duration_seconds adb -s "$ADB_DEVICE" logcat | grep -E "(flutter|Dalk|verificamex|redirect)" --line-buffered | while read line; do
        if echo "$line" | grep -q "✅"; then
            echo -e "${GREEN}$line${NC}"
        elif echo "$line" | grep -q "❌"; then
            echo -e "${RED}$line${NC}"
        elif echo "$line" | grep -q "⚠️"; then
            echo -e "${YELLOW}$line${NC}"
        else
            echo "$line"
        fi
    done || true
    
    print_info "Monitoreo de logs finalizado"
}

# ============================================
# INICIO DEL TEST
# ============================================

print_step "🚀 INICIANDO TEST COMPLETO DE VERIFICACIÓN"

# ✅ VERIFICAR PREREQUISITES
print_step "PRE-REQUISITOS: Verificando herramientas necesarias"

# Verificar jq
if ! command -v jq &> /dev/null; then
    print_error "jq no está instalado"
    print_info "Instalar con: brew install jq (Mac) o apt-get install jq (Linux)"
    exit 1
fi
print_success "jq encontrado"

# Verificar ADB
HAS_ADB=false
if check_adb; then
    HAS_ADB=true
    
    # Detectar dispositivo
    if detect_android_device; then
        # Verificar app instalada
        if check_app_installed; then
            print_success "Todas las verificaciones de ADB pasaron"
        else
            print_warning "App no está instalada, deep link no se podrá probar en dispositivo real"
            HAS_ADB=false
        fi
    else
        print_warning "No se pudo detectar dispositivo Android"
        HAS_ADB=false
    fi
else
    print_warning "ADB no disponible, deep link no se podrá probar en dispositivo real"
fi

echo ""
read -p "¿Continuar con el test? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Test cancelado por el usuario"
    exit 0
fi

# ============================================
# PASO 1: CREAR USUARIO DE PRUEBA EN AUTH
# ============================================
print_step "PASO 1: Creando usuario de prueba en Supabase Auth"

TEST_EMAIL="test.verificamex+$(date +%s)@dalk.com"
TEST_PASSWORD="TestPass123!"
TEST_USER_UUID=""

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

echo "📊 Auth Response: $AUTH_RESPONSE"

TEST_USER_UUID=$(echo $AUTH_RESPONSE | jq -r '.user.id')

if [ "$TEST_USER_UUID" == "null" ] || [ -z "$TEST_USER_UUID" ]; then
    print_error "No se pudo crear usuario en Auth"
    echo "Response completo: $AUTH_RESPONSE"
    exit 1
fi

print_success "Usuario creado en Auth con UUID: $TEST_USER_UUID"

# ============================================
# PASO 2: INSERTAR EN TABLA USERS
# ============================================
print_step "PASO 2: Insertando usuario en tabla users"

USERS_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/rest/v1/users" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "{
    \"uuid\": \"${TEST_USER_UUID}\",
    \"name\": \"Juan Pérez Test\",
    \"email\": \"${TEST_EMAIL}\",
    \"phone\": \"5512345678\",
    \"birthdate\": \"1990-01-01\",
    \"gender\": \"Masculino\",
    \"address\": \"Calle Test 123\",
    \"houseNumber\": \"10\",
    \"zipCode\": \"06000\",
    \"neighborhood\": \"Centro\",
    \"city\": \"Ciudad de México\",
    \"usertype\": \"Paseador\",
    \"verification_status\": \"pending_verification\"
  }")

echo "📊 Users Response: $USERS_RESPONSE"

if echo "$USERS_RESPONSE" | jq -e '.[0].uuid' > /dev/null 2>&1; then
    print_success "Usuario insertado en tabla users"
else
    print_error "Error insertando en tabla users"
    echo "Response: $USERS_RESPONSE"
    exit 1
fi

# ============================================
# PASO 3: INSERTAR DIRECCIÓN
# ============================================
print_step "PASO 3: Insertando dirección"

ADDRESS_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/rest/v1/addresses" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "{
    \"uuid\": \"${TEST_USER_UUID}\",
    \"alias\": \"Mi Dirección Test\",
    \"address\": \"Calle Test 123\",
    \"houseNumber\": \"10\",
    \"zipCode\": \"06000\",
    \"neighborhood\": \"Centro\",
    \"city\": \"Ciudad de México\"
  }")

echo "📊 Address Response: $ADDRESS_RESPONSE"

if echo "$ADDRESS_RESPONSE" | jq -e '.[0].id' > /dev/null 2>&1; then
    print_success "Dirección insertada"
else
    print_error "Error insertando dirección"
    echo "Response: $ADDRESS_RESPONSE"
    exit 1
fi

# ============================================
# PASO 4: LLAMAR EDGE FUNCTION (CREATE SESSION)
# ============================================
print_step "PASO 4: Llamando Edge Function para crear sesión"

EDGE_FUNCTION_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/functions/v1/ine-validation" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"action\": \"create_session\",
    \"user_id\": \"${TEST_USER_UUID}\",
    \"email\": \"${TEST_EMAIL}\"
  }")

echo "📊 Edge Function Response: $EDGE_FUNCTION_RESPONSE"

SESSION_ID=$(echo $EDGE_FUNCTION_RESPONSE | jq -r '.session_id')
FORM_URL=$(echo $EDGE_FUNCTION_RESPONSE | jq -r '.form_url')
VERIFICAMEX_SESSION_ID=$(echo $EDGE_FUNCTION_RESPONSE | jq -r '.verificamex_session_id')
REDIRECT_URL=$(echo $EDGE_FUNCTION_RESPONSE | jq -r '.redirect_url')

if [ "$SESSION_ID" == "null" ] || [ -z "$SESSION_ID" ]; then
    print_error "No se obtuvo session_id de la Edge Function"
    echo "Response: $EDGE_FUNCTION_RESPONSE"
    exit 1
fi

print_success "Sesión creada:"
echo "  📋 Session ID: $SESSION_ID"
echo "  🔗 Form URL: $FORM_URL"
echo "  🆔 Verificamex Session ID: $VERIFICAMEX_SESSION_ID"
echo "  🔄 Redirect URL: $REDIRECT_URL"

# ============================================
# PASO 5: VERIFICAR REGISTRO EN BD
# ============================================
print_step "PASO 5: Verificando registro en identity_verifications"

sleep 2

VERIFICATION_CHECK=$(curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/identity_verifications?session_id=eq.${SESSION_ID}&select=*" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}")

echo "📊 Verification Record: $VERIFICATION_CHECK"

VERIFICATION_STATUS=$(echo $VERIFICATION_CHECK | jq -r '.[0].status')

if [ "$VERIFICATION_STATUS" == "pending" ] || [ "$VERIFICATION_STATUS" == "OPEN" ]; then
    print_success "Registro creado en identity_verifications con status: $VERIFICATION_STATUS"
else
    print_error "Registro no encontrado o status incorrecto"
    echo "Response: $VERIFICATION_CHECK"
    exit 1
fi

# ============================================
# PASO 6: SIMULAR WEBHOOK DE VERIFICAMEX (ÉXITO)
# ============================================
print_step "PASO 6: Simulando webhook de Verificamex (ÉXITO)"

print_warning "Esperando 3 segundos antes de enviar webhook..."
sleep 3

WEBHOOK_PAYLOAD=$(cat <<EOF
{
  "data": {
    "object": "VerificationSession",
    "id": "${VERIFICAMEX_SESSION_ID}",
    "status": "FINISHED",
    "result": 95,
    "errors": [],
    "comments": null,
    "only_mobile_devices": true,
    "redirect_url": "${REDIRECT_URL}",
    "webhook": "${SUPABASE_URL}/functions/v1/ine-validation",
    "validations": ["INE", "CURP"],
    "ine_reading": {
      "DocumentData": [
        {
          "field": "nombre",
          "value": "JUAN PÉREZ GARCÍA",
          "confidence": 0.98
        },
        {
          "field": "curp",
          "value": "PEGJ900101HDFRRN09",
          "confidence": 0.99
        }
      ]
    },
    "ine": {
      "data": {
        "status": true,
        "message": "Credencial vigente"
      }
    },
    "renapo": {
      "data": {
        "status": true,
        "curp": "PEGJ900101HDFRRN09",
        "nombre": "JUAN",
        "apellido_paterno": "PÉREZ",
        "apellido_materno": "GARCÍA",
        "fecha_nacimiento": "1990-01-01",
        "sexo": "HOMBRE"
      }
    },
    "optionals": {
      "session_id": "${SESSION_ID}",
      "user_id": "${TEST_USER_UUID}",
      "email": "${TEST_EMAIL}",
      "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")"
    },
    "form_url": "${FORM_URL}",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z")",
    "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z")"
  }
}
EOF
)

echo "📤 Enviando webhook..."
echo "$WEBHOOK_PAYLOAD" | jq .

WEBHOOK_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/functions/v1/ine-validation" \
  -H "Content-Type: application/json" \
  -d "$WEBHOOK_PAYLOAD")

echo "📊 Webhook Response: $WEBHOOK_RESPONSE"

WEBHOOK_SUCCESS=$(echo $WEBHOOK_RESPONSE | jq -r '.success')

if [ "$WEBHOOK_SUCCESS" == "true" ]; then
    print_success "Webhook procesado exitosamente"
else
    print_error "Error procesando webhook"
    echo "Response: $WEBHOOK_RESPONSE"
    exit 1
fi

# ============================================
# PASO 7: VERIFICAR STATUS ACTUALIZADO
# ============================================
print_step "PASO 7: Verificando actualización de status"

sleep 2

FINAL_CHECK=$(curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/identity_verifications?session_id=eq.${SESSION_ID}&select=*" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}")

echo "📊 Final Check: $FINAL_CHECK"

FINAL_STATUS=$(echo $FINAL_CHECK | jq -r '.[0].status')
FINAL_RESULT=$(echo $FINAL_CHECK | jq -r '.[0].verification_result')
INE_STATUS=$(echo $FINAL_CHECK | jq -r '.[0].ine_status')
CURP_STATUS=$(echo $FINAL_CHECK | jq -r '.[0].curp_status')

echo ""
echo "📋 RESULTADO FINAL:"
echo "  Status: $FINAL_STATUS"
echo "  Result: $FINAL_RESULT"
echo "  INE Status: $INE_STATUS"
echo "  CURP Status: $CURP_STATUS"

if [ "$FINAL_STATUS" == "completed" ] && [ "$FINAL_RESULT" == "95" ]; then
    print_success "✅ VERIFICACIÓN COMPLETADA EXITOSAMENTE"
else
    print_error "Status no es 'completed' o result no es correcto"
    exit 1
fi

# ============================================
# PASO 8: EJECUTAR DEEP LINK AUTOMÁTICAMENTE
# ============================================
print_step "PASO 8: Ejecutando Deep Link en Dispositivo Android"

# Construir deep link correcto
DEEP_LINK="dalkpaseos://redirect_verificamex?session_id=${SESSION_ID}&user_id=${TEST_USER_UUID}"

if [ "$HAS_ADB" = true ]; then
    print_highlight "🚀 EJECUTANDO DEEP LINK AUTOMÁTICAMENTE EN DISPOSITIVO"
    
    # Ejecutar deep link
    if trigger_deep_link "$DEEP_LINK"; then
        print_success "Deep link ejecutado en dispositivo"
        
        # Monitorear logs por 15 segundos
        print_info "Monitoreando logs de la app..."
        monitor_app_logs 15
    else
        print_error "Error ejecutando deep link"
    fi
else
    print_warning "ADB no disponible o dispositivo no conectado"
    print_info "Para probar manualmente en dispositivo real, ejecuta:"
    echo ""
    echo "  adb shell am start -a android.intent.action.VIEW -d \"${DEEP_LINK}\""
    echo ""
    print_info "O escanea este QR code con tu dispositivo:"
    echo ""
    echo "  Deep Link: $DEEP_LINK"
    echo ""
fi

# ============================================
# PASO 9: SIMULAR POLLING DE REDIRECT WIDGET
# ============================================
print_step "PASO 9: Simulando polling de redirect_verificamex_widget"

for i in {1..3}; do
    echo "🔄 Polling intento $i/3..."
    
    POLLING_RESPONSE=$(curl -s -X GET \
      "${SUPABASE_URL}/rest/v1/identity_verifications?session_id=eq.${SESSION_ID}&select=status,verification_result,failure_reason" \
      -H "apikey: ${SUPABASE_ANON_KEY}" \
      -H "Authorization: Bearer ${SUPABASE_ANON_KEY}")
    
    POLL_STATUS=$(echo $POLLING_RESPONSE | jq -r '.[0].status')
    POLL_RESULT=$(echo $POLLING_RESPONSE | jq -r '.[0].verification_result')
    
    echo "  Status: $POLL_STATUS"
    echo "  Result: $POLL_RESULT"
    
    if [ "$POLL_STATUS" == "completed" ]; then
        print_success "✅ Polling detectó verificación completada"
        break
    fi
    
    sleep 5
done

# ============================================
# PASO 10: VERIFICAR ACTUALIZACIÓN DE USERS
# ============================================
print_step "PASO 10: Verificando users.verification_status"

USER_CHECK=$(curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/users?uuid=eq.${TEST_USER_UUID}&select=verification_status" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}")

USER_VERIFICATION_STATUS=$(echo $USER_CHECK | jq -r '.[0].verification_status')

echo "📊 User verification_status: $USER_VERIFICATION_STATUS"

if [ "$USER_VERIFICATION_STATUS" == "verified" ]; then
    print_success "✅ Usuario actualizado a 'verified'"
elif [ "$USER_VERIFICATION_STATUS" == "pending_verification" ]; then
    print_warning "Status aún es 'pending_verification'"
    print_info "Si el deep link se ejecutó correctamente, el widget debería actualizar este campo"
    
    if [ "$HAS_ADB" = true ]; then
        print_info "Verificando logs del dispositivo..."
        adb -s "$ADB_DEVICE" logcat -d | grep -E "(verification_status|verified|redirect_verificamex)" | tail -n 20
    fi
fi

# ============================================
# RESUMEN FINAL
# ============================================
print_step "RESUMEN FINAL"

echo ""
print_success "✅ ✅ FLUJO COMPLETADO EXITOSAMENTE"
echo ""
echo "📋 Datos del test:"
echo "  👤 User UUID: $TEST_USER_UUID"
echo "  📧 Email: $TEST_EMAIL"
echo "  🆔 Session ID: $SESSION_ID"
echo "  🔗 Form URL: $FORM_URL"
echo "  📊 Status Final: $FINAL_STATUS"
echo "  🎯 Result: $FINAL_RESULT"
echo "  👤 User Status: $USER_VERIFICATION_STATUS"
echo ""

if [ "$HAS_ADB" = true ]; then
    print_success "✅ Deep link ejecutado en dispositivo: $ADB_DEVICE"
    print_info "Verifica visualmente en el dispositivo que:"
    print_info "  1. La app abrió la pantalla redirect_verificamex"
    print_info "  2. Muestra el mensaje de 'Verificación completada'"
    print_info "  3. Después de polling, navega a homeDogWalker"
else
    print_warning "⚠️  Deep link NO ejecutado automáticamente"
    print_info "Para probar manualmente:"
    echo ""
    echo "  adb shell am start -a android.intent.action.VIEW -d \"$DEEP_LINK\""
    echo ""
fi

echo ""
print_warning "⚠️  ⚠️  LIMPIEZA: Para eliminar datos de prueba, ejecuta:"
echo "  supabase db reset"
echo "  o elimina manualmente el usuario: $TEST_USER_UUID"
echo ""