# Seguridad del proyecto

Este documento resume qué controles de seguridad están **automatizados** (vía CI)
y cuáles son **prácticas de gestión** (CIS Controls, NIST CSF, ISO 27001/27002)
que el equipo aplica manualmente y documenta como evidencia del desarrollo.

## 1. Controles automatizados (OWASP)

| Control | Herramienta | Workflow |
|---|---|---|
| Detección de secretos commiteados | Gitleaks | `security.yml` |
| Dependencias con vulnerabilidades conocidas | `npm audit` + Dependabot | `security.yml` / `dependabot.yml` |
| Análisis estático de JS (OWASP Top 10) | Semgrep (`p/owasp-top-ten`) | `security.yml` |
| Content-Security-Policy y patrones inseguros en HTML/JS (eval, innerHTML, tabnabbing) | Script propio (`scripts/check-security-headers.sh`) | `security.yml` |
| Buenas prácticas generales del sitio (HTTPS, accesibilidad) | Lighthouse CI | `lighthouse.yml` |
| Calidad y consistencia de código | ESLint / stylelint / HTMLHint | `lint.yml` |

## 2. Controles de gestión (aplicados manualmente)

Estos no se pueden "verificar" con un linter porque son procesos organizacionales,
pero se documentan acá como evidencia de que el equipo los tuvo en cuenta
(mapeo orientativo, no una certificación formal):

| Framework | Control aplicado | Cómo lo hacemos |
|---|---|---|
| CIS Controls v8 – Control 3 (Protección de datos) | No subir datos sensibles/reales del "cliente" al repo | Revisión en PR + Gitleaks |
| CIS Controls v8 – Control 4 (Configuración segura) | Cabeceras/CSP recomendadas en el sitio | Script de verificación + revisión manual en el deploy |
| CIS Controls v8 – Control 5 (Gestión de cuentas) | Acceso al repo solo para integrantes del equipo | Configuración de colaboradores en GitHub |
| CIS Controls v8 – Control 16 (Seguridad del software) | Revisión de dependencias y código antes de mergear | CI (lint + security) + revisión de PR obligatoria (CODEOWNERS) |
| NIST CSF – función "Identify" | Inventario de activos (páginas, dependencias, integraciones) | Documentado en el README del repo |
| NIST CSF – función "Protect" | Control de acceso y gestión de cambios | Branch protection rules + CODEOWNERS |
| NIST CSF – función "Detect" | Monitoreo continuo de vulnerabilidades | Dependabot + Semgrep programado semanalmente |
| ISO 27001 – A.8 (Gestión de activos) | Control de versiones y trazabilidad de cambios | Historial de Git + Conventional Commits |
| ISO 27001 – A.12 (Seguridad de las operaciones) | Registro de logs de despliegue | Logs de GitHub Actions (deploy.yml) |
| ISO 27001 – A.14 (Adquisición, desarrollo y mantenimiento) | Ciclo de desarrollo seguro (SDLC) | Este mismo pipeline de CI/CD |

> Nota para el informe: este mapeo es orientativo y pensado
> para mostrar el criterio aplicado, no reemplaza una auditoría formal de
> cumplimiento (que requeriría alcance, evidencia documental completa y
> revisión por un auditor certificado).

## 3. Branch protection recomendado (configurar manualmente en GitHub)

En **Settings → Branches → Branch protection rules** para `main`:
- Requerir Pull Request antes de mergear
- Requerir que pasen los checks de CI (`lint`, `security`, `lighthouse`)
- Requerir al menos 1 aprobación (CODEOWNERS)
- No permitir force-push ni borrado de la rama
