#!/usr/bin/env bash
#
# Verificación básica de buenas prácticas de seguridad (OWASP Secure Headers
# Project) en archivos HTML estáticos.
#
# Como GitHub Pages no permite configurar cabeceras HTTP a mano, la mitigación
# equivalente para un sitio estático es declarar una Content-Security-Policy
# vía meta tag y evitar patrones inseguros en el HTML/JS.
#
# Este script NO reemplaza un pentest ni un WAF: es un chequeo rápido para
# detectar errores comunes antes de mergear.

set -euo pipefail

FAIL=0
HTML_FILES=$(find . -name "*.html" -not -path "./node_modules/*")

if [ -z "$HTML_FILES" ]; then
  echo "No se encontraron archivos HTML para analizar."
  exit 0
fi

echo "== Verificando Content-Security-Policy (meta tag) =="
for f in $HTML_FILES; do
  if ! grep -qi "Content-Security-Policy" "$f"; then
    echo "⚠️  $f no declara una meta CSP. Recomendado: <meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'self'\">"
    FAIL=1
  fi
done

echo ""
echo "== Buscando uso de eval() / innerHTML sin sanitizar en JS =="
JS_FILES=$(find . -name "*.js" -not -path "./node_modules/*")
for f in $JS_FILES; do
  if grep -qE "\beval\(" "$f"; then
    echo "❌ $f usa eval(), riesgo de inyección de código. Evitarlo (OWASP A03:2021 - Injection)."
    FAIL=1
  fi
  if grep -qE "\.innerHTML\s*=" "$f"; then
    echo "⚠️  $f asigna innerHTML directamente. Verificar que el contenido esté sanitizado (riesgo de XSS)."
  fi
done

echo ""
echo "== Buscando enlaces target=\"_blank\" sin rel=\"noopener noreferrer\" =="
for f in $HTML_FILES; do
  if grep -qE 'target="_blank"' "$f" && ! grep -qE 'target="_blank"[^>]*rel="[^"]*noopener' "$f"; then
    echo "⚠️  $f tiene target=\"_blank\" sin rel=\"noopener noreferrer\" (riesgo de tabnabbing)."
  fi
done

echo ""
if [ "$FAIL" -eq 1 ]; then
  echo "Se encontraron problemas de seguridad. Revisar el detalle arriba."
  exit 1
else
  echo "✅ No se encontraron problemas críticos."
fi
