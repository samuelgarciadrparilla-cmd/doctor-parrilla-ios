# Doctor Parrilla Paraguay - App iOS/Android

App Flutter WebView de produccion para Doctor Parrilla Paraguay, la mayor fabrica de parrillas premium de acero inoxidable de Paraguay.

---

## Reporte de Auditoria (Fase 0)

| ID | Severidad | Hallazgo | Estado |
|---|---|---|---|
| CRITICAL-01 | Critico | PrivacyInfo.xcprivacy faltante | Resuelto |
| CRITICAL-02 | Critico | Sin manejo de error en WebView | Resuelto |
| CRITICAL-03 | Critico | Sin Push Notifications capability | Resuelto |
| WARNING-01 | Advertencia | URL hardcodeada en codigo | Resuelto (constants.dart) |
| WARNING-02 | Advertencia | Sin pantalla offline de marca | Resuelto |
| WARNING-03 | Advertencia | Sin pull-to-refresh | Resuelto |
| HIG-01 | HIG | Splash screen no respeta Safe Area | Resuelto |
| HIG-02 | HIG | Sin soporte Dark Mode | Resuelto (tema oscuro nativo) |
| HIG-03 | HIG | Sin haptic feedback en botones | Resuelto |
| STORE-01 | Store | Sin ITSAppUsesNonExemptEncryption | Resuelto |
| STORE-02 | Store | Sin NSCameraUsageDescription | Resuelto |
| STORE-03 | Store | Sin UIBackgroundModes para push | Resuelto |

---

## Arquitectura del Proyecto

```
lib/
├── main.dart                              # Entry point
├── app/
│   ├── app.dart                           # MaterialApp + theme
│   └── constants.dart                     # ALL constants
├── core/
│   ├── connectivity/
│   │   └── connectivity_service.dart      # Network monitoring
│   └── notifications/
│       └── firebase_service.dart          # FCM push notifications
├── features/
│   └── webview/
│       ├── webview_screen.dart            # Main WebView screen
│       └── widgets/
│           ├── no_internet_widget.dart    # Offline screen
│           ├── loading_widget.dart        # Skeleton loader
│           └── error_widget.dart          # Error screen
└── shared/
    └── theme/
        └── app_theme.dart                 # Brand theme
```

---

## Requisitos Previos

### 1. Cuenta Apple Developer (USD 99/ano)

1. Ve a https://developer.apple.com/programs/enroll/
2. Registrate como Individual u Organizacion
3. Paga USD 99/ano
4. Acepta el "Paid Applications Agreement" en App Store Connect

### 2. Crear API Key en App Store Connect

1. Ve a https://appstoreconnect.apple.com/access/api
2. Haz clic en "Generate API Key"
3. Nombre: "Codemagic CI/CD", Rol: "App Manager"
4. Descarga el archivo `.p8` (SOLO SE PUEDE DESCARGAR UNA VEZ)
5. Copia el Key ID y el Issuer ID

### 3. Crear la App en App Store Connect

| Campo | Valor |
|---|---|
| Platform | iOS |
| Name | Doctor Parrilla |
| Primary Language | Spanish (Mexico) |
| Bundle ID | com.drparrilla.app |
| SKU | DRPARRILLA001 |

### 4. Configurar Firebase

1. Ve a https://console.firebase.google.com/
2. Crea un proyecto "Doctor Parrilla"
3. Agrega app iOS con Bundle ID: `com.drparrilla.app`
4. Descarga `GoogleService-Info.plist` a `ios/Runner/`
5. Agrega app Android con package: `com.drparrilla.app`
6. Descarga `google-services.json` a `android/app/`

### 5. Configurar Codemagic

1. Ve a https://codemagic.io/ y crea una cuenta
2. Conecta tu repositorio de GitHub
3. En "Settings" > "Environment variables", crea grupo `app_store_credentials`:

| Variable | Valor |
|---|---|
| APP_STORE_CONNECT_ISSUER_ID | Tu Issuer ID |
| APP_STORE_CONNECT_KEY_IDENTIFIER | Tu Key ID |
| APP_STORE_CONNECT_PRIVATE_KEY | Contenido del archivo .p8 |

4. Haz push a `main` y Codemagic compilara automaticamente

---

## Metadata para App Store

**Nombre:** Doctor Parrilla
**Subtitulo:** Parrillas de acero inoxidable
**Categoria primaria:** Shopping
**Categoria secundaria:** Food and Drink
**Clasificacion:** 4+
**Keywords:** parrilla,asador,acero inoxidable,quincho,barbacoa,Paraguay,premium,grill

**Descripcion:**

Doctor Parrilla es la aplicacion oficial de la mayor fabrica de parrillas premium de Paraguay. Explora nuestro catalogo completo, consulta precios, y recibe notificaciones exclusivas de lanzamientos y promociones.

Caracteristicas principales:
- Catalogo completo de parrillas de acero inoxidable
- Consulta de precios y disponibilidad
- Notificaciones push de ofertas exclusivas
- Atencion directa por WhatsApp
- Experiencia optimizada para movil

Doctor Parrilla - Expertos en Parrillas. Exportando CALIDAD de Paraguay al MUNDO.

**URLs:**

| Campo | URL |
|---|---|
| Support URL | https://drparrillaparaguay.com |
| Privacy Policy URL | https://drparrillaparaguay.com/privacidad |
| Marketing URL | https://drparrillaparaguay.com |

**Screenshots requeridos:**

| Dispositivo | Resolucion |
|---|---|
| iPhone 6.9" (15 Pro Max) | 1320 x 2868 |
| iPhone 6.5" (11 Pro Max) | 1242 x 2688 |
| iPad 12.9" (opcional) | 2048 x 2732 |

---

## Comandos Utiles

```bash
flutter pub get                          # Instalar dependencias
dart run flutter_launcher_icons          # Generar iconos
dart run flutter_native_splash:create    # Generar splash screen
flutter build ipa --release              # Build iOS (Mac o Codemagic)
flutter build appbundle --release        # Build Android
```

---

## Redes Sociales

- Web: https://drparrillaparaguay.com
- Instagram: https://instagram.com/drparrillapy
- Facebook: https://facebook.com/drparrillapy
