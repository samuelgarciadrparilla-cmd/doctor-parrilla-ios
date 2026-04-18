# Checklist Pre-Submission - Doctor Parrilla iOS

## BUILD
- [x] Proyecto Flutter creado con estructura limpia
- [x] Todas las dependencias declaradas en pubspec.yaml
- [x] Minimum iOS 16.0 en Podfile y project settings
- [x] Bundle ID: com.drparrilla.app
- [ ] flutter build ipa --release produce zero errors (requiere Mac/Codemagic)
- [ ] IPA size under 50MB

## APPLE COMPLIANCE
- [x] PrivacyInfo.xcprivacy presente y valido
- [x] Info.plist con todas las usage descriptions
- [x] ITSAppUsesNonExemptEncryption declarado como false
- [x] UIBackgroundModes con remote-notification
- [x] Runner.entitlements con aps-environment
- [ ] App icon 1024x1024 sin canal alpha (generar con flutter_launcher_icons)

## FUNCTIONALITY
- [x] WebView carga drparrillaparaguay.com
- [x] Sin internet -> pantalla offline con retry (no crash)
- [x] Error de carga -> pantalla de error con retry
- [x] Back navigation funciona (PopScope)
- [x] Push notifications: foreground, background, terminated
- [x] Pull to refresh implementado
- [x] Links externos abren en Safari (no dentro del WebView)
- [x] User agent personalizado

## UI/UX
- [x] Splash screen con fondo negro y logo de marca
- [x] Safe areas respetadas
- [x] Dark Mode: tema oscuro nativo
- [x] Loading state con skeleton y progress bar
- [x] Error state con boton de retry y haptic feedback
- [x] Orientacion bloqueada a portrait

## STORE LISTING
- [x] Nombre: Doctor Parrilla
- [x] Descripcion preparada
- [x] Keywords preparados
- [x] Privacy Policy URL: drparrillaparaguay.com/privacidad
- [x] Support URL: drparrillaparaguay.com
- [x] Clasificacion de edad: 4+
- [ ] Screenshots para todos los tamanos requeridos

## CI/CD
- [x] codemagic.yaml configurado para iOS y Android
- [ ] Cuenta Codemagic creada y conectada a GitHub
- [ ] API Key de App Store Connect configurada en Codemagic
- [ ] Primer build exitoso en Codemagic

## PENDIENTE DEL USUARIO
- [ ] Crear cuenta Apple Developer (USD 99/ano)
- [ ] Crear app en App Store Connect
- [ ] Configurar Firebase y descargar GoogleService-Info.plist
- [ ] Crear cuenta en Codemagic y conectar repo
- [ ] Subir screenshots a App Store Connect
- [ ] Enviar a revision de Apple
