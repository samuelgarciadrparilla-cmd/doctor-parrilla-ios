# AR Landing Page - Plan de Implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Crear landing page AR para Dr. Parrilla con visualización de parrillas en realidad aumentada

**Architecture:** Página HTML estática servida desde Firebase Hosting. Archivos 3D (.usdz/.glb) en Firebase Storage. Detección de dispositivo para iOS (AR Quick Look) vs Android/Web (model-viewer).

**Tech Stack:** HTML5, CSS3, JavaScript vanilla, Google Fonts (Playfair Display + Montserrat), model-viewer library, Firebase Hosting + Storage

---

## File Structure

```
doctor-parrilla-ios/
├── ar/                          # Nueva carpeta para AR landing
│   ├── index.html               # Página principal
│   ├── styles.css               # Estilos (negro/dorado, brasas)
│   └── app.js                   # Detección dispositivo + AR logic
├── firebase.json                # Config Firebase Hosting (nuevo)
└── .firebaserc                  # Proyecto Firebase (nuevo)
```

**Firebase Storage (subida manual):**
```
ar/
├── sin-apliques.usdz
├── sin-apliques.glb
├── sin-apliques-preview.png
├── con-apliques.usdz
├── con-apliques.glb
├── con-apliques-preview.png
└── logo.png
```

---

## Task 1: Subir archivos a Firebase Storage

**Acción:** Manual en Firebase Console

- [ ] **Step 1: Abrir Firebase Console**

Ir a: https://console.firebase.google.com
Seleccionar proyecto de Dr. Parrilla

- [ ] **Step 2: Navegar a Storage**

En el menú lateral, click en "Storage"
Si no está habilitado, habilitarlo con reglas de producción

- [ ] **Step 3: Crear carpeta ar/**

Click en "Create folder" → nombrar "ar"

- [ ] **Step 4: Subir archivos**

Subir estos 7 archivos (renombrar al subir):

| Archivo local | Nombre en Storage |
|---------------|-------------------|
| `~/Downloads/Black asn Stainless Steel/USD/ASSET.usdz` | `sin-apliques.usdz` |
| `~/Downloads/Black asn Stainless Steel/glb/ASSET.glb` | `sin-apliques.glb` |
| `~/Downloads/Black asn Stainless Steel/_01.png` | `sin-apliques-preview.png` |
| `~/Downloads/Black asn Stainless Steel 3/USD/Untitled.usdz` | `con-apliques.usdz` |
| `~/Downloads/Black asn Stainless Steel 3/glb/Untitled.glb` | `con-apliques.glb` |
| `~/Downloads/Black asn Stainless Steel 3/_003.png` | `con-apliques-preview.png` |
| `~/Desktop/logo_drparrilla.png` | `logo.png` |

- [ ] **Step 5: Obtener URLs de descarga**

Para cada archivo:
1. Click en el archivo
2. En panel derecho, buscar "Token de acceso" o "Access token"
3. Copiar la URL completa (formato: `https://firebasestorage.googleapis.com/...`)

Guardar las 7 URLs en un archivo temporal:

```bash
cat > ~/doctor-parrilla-ios/ar/urls.txt << 'EOF'
# Pegar aquí las URLs obtenidas de Firebase Console
LOGO_URL=https://firebasestorage.googleapis.com/...
SIN_APLIQUES_USDZ=https://firebasestorage.googleapis.com/...
SIN_APLIQUES_GLB=https://firebasestorage.googleapis.com/...
SIN_APLIQUES_PREVIEW=https://firebasestorage.googleapis.com/...
CON_APLIQUES_USDZ=https://firebasestorage.googleapis.com/...
CON_APLIQUES_GLB=https://firebasestorage.googleapis.com/...
CON_APLIQUES_PREVIEW=https://firebasestorage.googleapis.com/...
EOF
```

---

## Task 2: Crear estructura de carpetas

**Files:**
- Create: `ar/` directory

- [ ] **Step 1: Crear carpeta ar/**

```bash
mkdir -p ~/doctor-parrilla-ios/ar
```

- [ ] **Step 2: Verificar estructura**

```bash
ls -la ~/doctor-parrilla-ios/ar/
```

Expected: carpeta vacía creada

---

## Task 3: Crear styles.css

**Files:**
- Create: `ar/styles.css`

- [ ] **Step 1: Crear archivo de estilos**

```css
:root {
  --color-black: #000000;
  --color-gold: #D4AF37;
  --color-gold-hover: #F4CF57;
  --color-gray: #888888;
  --color-gray-light: #AAAAAA;
  --color-ember: rgba(255, 100, 0, 0.08);
  --font-serif: 'Playfair Display', Georgia, serif;
  --font-sans: 'Montserrat', Arial, sans-serif;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  min-height: 100vh;
  background: var(--color-black);
  color: #fff;
  font-family: var(--font-sans);
}

body {
  background: 
    radial-gradient(ellipse at 50% 100%, var(--color-ember) 0%, transparent 60%),
    var(--color-black);
}

.container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 40px 20px;
  text-align: center;
}

.logo {
  max-width: 200px;
  height: auto;
  margin-bottom: 20px;
}

.divider {
  width: 60%;
  max-width: 300px;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--color-gold), transparent);
  margin: 20px auto;
}

.slogan {
  font-family: var(--font-serif);
  font-size: 1.4rem;
  font-weight: 400;
  color: var(--color-gold);
  line-height: 1.6;
  max-width: 500px;
  margin: 0 auto 40px;
  font-style: italic;
}

.products {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 30px;
  margin-bottom: 60px;
}

.product-card {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(212, 175, 55, 0.3);
  border-radius: 8px;
  padding: 20px;
  transition: border-color 0.3s, box-shadow 0.3s;
}

.product-card:hover {
  border-color: var(--color-gold);
  box-shadow: 0 0 20px rgba(212, 175, 55, 0.2);
}

.product-image {
  width: 100%;
  aspect-ratio: 1;
  object-fit: contain;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 4px;
  margin-bottom: 15px;
}

.product-title {
  font-size: 0.85rem;
  font-weight: 600;
  letter-spacing: 2px;
  color: var(--color-gray-light);
  margin-bottom: 5px;
}

.product-name {
  font-size: 1.1rem;
  font-weight: 700;
  color: #fff;
  margin-bottom: 5px;
}

.product-subtitle {
  font-size: 0.9rem;
  color: var(--color-gray);
  margin-bottom: 20px;
}

.ar-button {
  display: inline-block;
  padding: 12px 24px;
  background: transparent;
  border: 2px solid var(--color-gold);
  color: var(--color-gold);
  font-family: var(--font-sans);
  font-size: 0.85rem;
  font-weight: 600;
  letter-spacing: 1px;
  text-decoration: none;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
}

.ar-button:hover {
  background: var(--color-gold);
  color: var(--color-black);
  box-shadow: 0 0 15px rgba(212, 175, 55, 0.4);
}

model-viewer {
  display: none;
  width: 100%;
  height: 400px;
  background: var(--color-black);
  margin-top: 15px;
  border-radius: 4px;
}

model-viewer.active {
  display: block;
}

.footer {
  border-top: 1px solid rgba(212, 175, 55, 0.2);
  padding-top: 30px;
  font-size: 0.75rem;
  color: var(--color-gray);
  line-height: 1.8;
}

.footer a {
  color: var(--color-gold);
  text-decoration: none;
}

.footer a:hover {
  text-decoration: underline;
}

@media (max-width: 600px) {
  .slogan {
    font-size: 1.1rem;
  }
  
  .products {
    grid-template-columns: 1fr;
  }
  
  .logo {
    max-width: 150px;
  }
}
```

- [ ] **Step 2: Verificar archivo creado**

```bash
ls -la ~/doctor-parrilla-ios/ar/styles.css
```

Expected: archivo existe, ~2.5KB

---

## Task 4: Crear app.js

**Files:**
- Create: `ar/app.js`

- [ ] **Step 1: Crear archivo JavaScript**

```javascript
(function() {
  'use strict';

  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

  function initARButtons() {
    const buttons = document.querySelectorAll('.ar-button');
    
    buttons.forEach(function(button) {
      const usdzUrl = button.dataset.usdz;
      const glbUrl = button.dataset.glb;
      const productId = button.dataset.product;

      if (isIOS) {
        button.href = usdzUrl;
        button.setAttribute('rel', 'ar');
        button.addEventListener('click', function(e) {
          // iOS handles AR Quick Look natively via the link
        });
      } else {
        button.href = '#';
        button.addEventListener('click', function(e) {
          e.preventDefault();
          toggleModelViewer(productId, glbUrl);
        });
      }
    });
  }

  function toggleModelViewer(productId, glbUrl) {
    const viewer = document.getElementById('viewer-' + productId);
    
    if (viewer) {
      if (viewer.classList.contains('active')) {
        viewer.classList.remove('active');
      } else {
        document.querySelectorAll('model-viewer.active').forEach(function(v) {
          v.classList.remove('active');
        });
        viewer.src = glbUrl;
        viewer.classList.add('active');
      }
    }
  }

  document.addEventListener('DOMContentLoaded', initARButtons);
})();
```

- [ ] **Step 2: Verificar archivo creado**

```bash
ls -la ~/doctor-parrilla-ios/ar/app.js
```

Expected: archivo existe, ~1KB

---

## Task 5: Crear index.html

**Files:**
- Create: `ar/index.html`

**Nota:** Reemplazar `{{URL_*}}` con las URLs reales de Firebase Storage obtenidas en Task 1.

- [ ] **Step 1: Crear archivo HTML**

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dr. Parrilla - Visualizá en tu espacio</title>
  <meta name="description" content="Visualizá las parrillas Dr. Parrilla en realidad aumentada antes de comprar.">
  
  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700&family=Playfair+Display:ital,wght@0,400;1,400&display=swap" rel="stylesheet">
  
  <!-- model-viewer for Android/Web -->
  <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.4.0/model-viewer.min.js"></script>
  
  <!-- Styles -->
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="container">
    <!-- Logo -->
    <img src="{{URL_LOGO}}" alt="Dr. Parrilla" class="logo">
    
    <div class="divider"></div>
    
    <!-- Slogan -->
    <p class="slogan">
      Una decisión así merece verse antes de tomarse.<br>
      Colocá la parrilla en tu espacio y elegí con total confianza.
    </p>
    
    <!-- Products -->
    <div class="products">
      <!-- Product 1: Sin Apliques -->
      <div class="product-card">
        <img src="{{URL_SIN_APLIQUES_PREVIEW}}" alt="Revestido Premium Sin Apliques" class="product-image">
        <p class="product-title">REVESTIDO PREMIUM</p>
        <p class="product-name">Acero Carbono</p>
        <p class="product-subtitle">Sin Apliques</p>
        <a href="#" 
           class="ar-button" 
           data-product="sin-apliques"
           data-usdz="{{URL_SIN_APLIQUES_USDZ}}"
           data-glb="{{URL_SIN_APLIQUES_GLB}}">
          VER EN TU ESPACIO
        </a>
        <model-viewer 
          id="viewer-sin-apliques"
          ar 
          ar-modes="webxr scene-viewer quick-look"
          camera-controls 
          touch-action="pan-y"
          alt="Parrilla Revestido Premium Sin Apliques">
        </model-viewer>
      </div>
      
      <!-- Product 2: Con Apliques -->
      <div class="product-card">
        <img src="{{URL_CON_APLIQUES_PREVIEW}}" alt="Revestido Premium Con Apliques" class="product-image">
        <p class="product-title">REVESTIDO PREMIUM</p>
        <p class="product-name">Acero Carbono</p>
        <p class="product-subtitle">Con Apliques en Inox</p>
        <a href="#" 
           class="ar-button" 
           data-product="con-apliques"
           data-usdz="{{URL_CON_APLIQUES_USDZ}}"
           data-glb="{{URL_CON_APLIQUES_GLB}}">
          VER EN TU ESPACIO
        </a>
        <model-viewer 
          id="viewer-con-apliques"
          ar 
          ar-modes="webxr scene-viewer quick-look"
          camera-controls 
          touch-action="pan-y"
          alt="Parrilla Revestido Premium Con Apliques en Inox">
        </model-viewer>
      </div>
    </div>
    
    <!-- Footer -->
    <footer class="footer">
      <p>© 2026 Dr. Parrilla Paraguay. Todos los derechos reservados.</p>
      <p>Los modelos 3D, diseños e imágenes son propiedad intelectual exclusiva de Dr. Parrilla.</p>
      <p>Prohibida su reproducción, copia o uso sin autorización expresa.</p>
      <p><a href="https://drparrillaparaguay.com/privacidad">Política de Privacidad</a></p>
    </footer>
  </div>
  
  <script src="app.js"></script>
</body>
</html>
```

- [ ] **Step 2: Reemplazar URLs de Firebase Storage**

Abrir `ar/urls.txt` y reemplazar en `index.html`:
- `{{URL_LOGO}}` → URL del logo
- `{{URL_SIN_APLIQUES_PREVIEW}}` → URL preview producto 1
- `{{URL_SIN_APLIQUES_USDZ}}` → URL USDZ producto 1
- `{{URL_SIN_APLIQUES_GLB}}` → URL GLB producto 1
- `{{URL_CON_APLIQUES_PREVIEW}}` → URL preview producto 2
- `{{URL_CON_APLIQUES_USDZ}}` → URL USDZ producto 2
- `{{URL_CON_APLIQUES_GLB}}` → URL GLB producto 2

- [ ] **Step 3: Verificar que no quedan placeholders**

```bash
grep -n "{{URL" ~/doctor-parrilla-ios/ar/index.html
```

Expected: sin resultados (todas las URLs reemplazadas)

---

## Task 6: Configurar Firebase Hosting

**Files:**
- Create: `firebase.json`
- Create: `.firebaserc`

- [ ] **Step 1: Crear firebase.json**

```json
{
  "hosting": {
    "public": "ar",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**",
      "urls.txt"
    ],
    "headers": [
      {
        "source": "**/*.usdz",
        "headers": [
          {
            "key": "Content-Type",
            "value": "model/vnd.usdz+zip"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Inicializar proyecto Firebase**

```bash
cd ~/doctor-parrilla-ios && firebase use --add
```

Seleccionar el proyecto de Dr. Parrilla cuando pregunte.
Alias sugerido: `production`

- [ ] **Step 3: Verificar configuración**

```bash
cat ~/doctor-parrilla-ios/.firebaserc
```

Expected: archivo con el proyecto ID configurado

---

## Task 7: Test local

- [ ] **Step 1: Servir localmente**

```bash
cd ~/doctor-parrilla-ios && firebase serve --only hosting
```

Expected: servidor en http://localhost:5000

- [ ] **Step 2: Verificar en navegador**

Abrir http://localhost:5000 y verificar:
- [ ] Logo carga correctamente
- [ ] Slogan visible con tipografía dorada
- [ ] 2 cards de productos visibles
- [ ] Imágenes preview cargan
- [ ] Hover en botones funciona (cambio de color)
- [ ] Footer con texto legal visible
- [ ] Efecto brasas sutil en la parte inferior

- [ ] **Step 3: Detener servidor**

Presionar `Ctrl+C` para detener

---

## Task 8: Deploy a Firebase Hosting

- [ ] **Step 1: Deploy**

```bash
cd ~/doctor-parrilla-ios && firebase deploy --only hosting
```

Expected: 
```
✔ Deploy complete!
Hosting URL: https://[proyecto].web.app
```

- [ ] **Step 2: Obtener URL**

Copiar la URL del Hosting (ej: `https://drparrilla-xxxxx.web.app`)

- [ ] **Step 3: Probar en dispositivo real**

Enviar URL por WhatsApp a tu teléfono y probar:

**En iPhone:**
- [ ] Página carga correctamente
- [ ] Click en "VER EN TU ESPACIO" abre AR Quick Look
- [ ] Parrilla se puede colocar en el espacio real

**En Android:**
- [ ] Página carga correctamente
- [ ] Click en "VER EN TU ESPACIO" muestra visor 3D
- [ ] Se puede rotar el modelo
- [ ] Botón AR funciona (si el dispositivo soporta ARCore)

---

## Task 9: Commit final

- [ ] **Step 1: Agregar archivos al repo**

```bash
cd ~/doctor-parrilla-ios && git add ar/ firebase.json .firebaserc
```

- [ ] **Step 2: Commit**

```bash
git commit -m "$(cat <<'EOF'
feat: add AR landing page for product visualization

- Landing page with black/gold design and ember effects
- iOS AR Quick Look support via USDZ files
- Android/Web 3D viewer via model-viewer and GLB files
- Device detection for optimal AR experience
- Legal footer with copyright and privacy policy

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 3: Verificar**

```bash
git log --oneline -1
```

Expected: commit con mensaje "feat: add AR landing page..."

---

## Verificación Final

| Requisito | Verificado |
|-----------|------------|
| Logo Dr. Parrilla visible | [ ] |
| Slogan neuromarketing | [ ] |
| 2 productos con preview | [ ] |
| Botón "VER EN TU ESPACIO" | [ ] |
| AR funciona en iOS | [ ] |
| Visor 3D funciona en Android/Web | [ ] |
| Footer legal completo | [ ] |
| Diseño negro/dorado/brasas | [ ] |
| Responsive (móvil/desktop) | [ ] |
