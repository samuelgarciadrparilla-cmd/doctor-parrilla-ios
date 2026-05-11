# Spec: Página AR Dr. Parrilla

**Fecha:** 2026-05-10  
**Estado:** Aprobado

## Objetivo

Crear una landing page para que clientes de Dr. Parrilla puedan visualizar parrillas en realidad aumentada (AR) antes de comprar. La página será compartida por link para pruebas y luego integrada al sitio web principal.

## Archivos Fuente

### Archivos AR a subir a Firebase Storage

| Archivo Local | Nombre en Storage | Producto |
|---------------|-------------------|----------|
| `~/Downloads/Black asn Stainless Steel/USD/ASSET.usdz` | `ar/sin-apliques.usdz` | Revestido Premium Acero Carbono SIN Apliques |
| `~/Downloads/Black asn Stainless Steel/glb/ASSET.glb` | `ar/sin-apliques.glb` | (mismo, para web/Android) |
| `~/Downloads/Black asn Stainless Steel/_01.png` | `ar/sin-apliques-preview.png` | Imagen preview |
| `~/Downloads/Black asn Stainless Steel 3/USD/Untitled.usdz` | `ar/con-apliques.usdz` | Revestido Premium Acero Carbono CON Apliques en Inox |
| `~/Downloads/Black asn Stainless Steel 3/glb/Untitled.glb` | `ar/con-apliques.glb` | (mismo, para web/Android) |
| `~/Downloads/Black asn Stainless Steel 3/_003.png` | `ar/con-apliques-preview.png` | Imagen preview |
| `~/Desktop/logo_drparrilla.png` | `ar/logo.png` | Logo Dr. Parrilla |

## Diseño Visual

### Paleta de Colores

- **Fondo principal:** Negro `#000000`
- **Dorado principal:** `#D4AF37`
- **Dorado hover:** `#F4CF57`
- **Texto secundario:** Gris `#888888`
- **Efecto brasas:** Gradiente radial naranja/rojo sutil en la base

### Estructura de la Página

```
┌─────────────────────────────────────────┐
│         [efecto brasas sutil]           │
│                                         │
│            LOGO DR. PARRILLA            │
│              (sin fondo)                │
│                                         │
│         ── línea dorada ──              │
│                                         │
│   "Una decisión así merece verse        │
│    antes de tomarse.                    │
│    Colocá la parrilla en tu espacio     │
│    y elegí con total confianza."        │
│                                         │
│  ┌─────────────┐   ┌─────────────┐     │
│  │  [preview]  │   │  [preview]  │     │
│  │             │   │             │     │
│  │ REVESTIDO   │   │ REVESTIDO   │     │
│  │ PREMIUM     │   │ PREMIUM     │     │
│  │ Acero       │   │ Acero       │     │
│  │ Carbono     │   │ Carbono     │     │
│  │ SIN APLIQUES│   │ CON APLIQUES│     │
│  │             │   │ EN INOX     │     │
│  │[VER EN TU   │   │[VER EN TU   │     │
│  │  ESPACIO]   │   │  ESPACIO]   │     │
│  └─────────────┘   └─────────────┘     │
│                                         │
│  ─────────────────────────────────────  │
│  © 2026 Dr. Parrilla Paraguay.          │
│  Todos los derechos reservados.         │
│  Los modelos 3D, diseños e imágenes     │
│  son propiedad intelectual exclusiva.   │
│  Prohibida su reproducción o copia      │
│  sin autorización expresa.              │
│  Política de Privacidad                 │
└─────────────────────────────────────────┘
```

### Tipografía

- **Logo:** Imagen PNG
- **Slogan:** Serif elegante (Playfair Display o similar), dorado, centrado
- **Nombres producto:** Sans-serif bold (Montserrat o similar), blanco
- **Descripciones:** Sans-serif light, gris claro
- **Footer:** Sans-serif pequeño, gris tenue

### Componentes

#### Card de Producto
- Fondo: Negro con borde dorado sutil (1px)
- Imagen preview: Aspecto cuadrado, objeto centrado
- Título: Blanco, bold
- Subtítulo: Gris claro
- Botón AR: Dorado con borde, texto "VER EN TU ESPACIO"
- Hover: Brillo dorado, sombra sutil

#### Botón AR
- Detecta dispositivo automáticamente
- iOS (Safari): Usa `<a rel="ar">` con archivo `.usdz` → abre AR Quick Look nativo
- Android/Web: Usa `<model-viewer>` con archivo `.glb` → visor 3D con opción AR

### Efecto Brasas
- Gradiente radial en la parte inferior de la página
- Colores: `rgba(255, 100, 0, 0.1)` a transparente
- Sutil, no distrae del contenido

## Tecnología

### Stack
- **HTML5** estático (una sola página)
- **CSS3** con variables para colores
- **JavaScript** vanilla para detección de dispositivo
- **Google Fonts:** Playfair Display + Montserrat
- **model-viewer:** Librería de Google para visor 3D en web

### Hosting
- **Firebase Hosting** (proyecto existente de Dr. Parrilla)
- URL: `https://[proyecto].web.app/ar` o dominio personalizado

### Detección de Dispositivo
```javascript
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
// iOS: mostrar link directo a .usdz
// Otros: mostrar model-viewer con .glb
```

## Flujo de Usuario

1. Usuario recibe link por WhatsApp/email
2. Abre la página en el navegador
3. Ve el logo, slogan y las 2 parrillas
4. Toca "VER EN TU ESPACIO" en el producto deseado
5. **iOS:** Se abre AR Quick Look, puede colocar la parrilla en su espacio
6. **Android/Web:** Se abre visor 3D, puede rotar y ver en AR si el dispositivo soporta
7. Usuario comparte experiencia o contacta para comprar

## Archivos a Crear

```
/ar
├── index.html      # Página principal
├── styles.css      # Estilos
├── app.js          # Detección de dispositivo y lógica AR
└── assets/         # (imágenes servidas desde Firebase Storage)
```

## Pasos de Implementación

1. Subir archivos AR a Firebase Storage (manual via consola)
2. Obtener URLs públicas de cada archivo
3. Crear estructura HTML/CSS/JS
4. Configurar Firebase Hosting
5. Deploy y probar en iOS y Android
6. Compartir link para pruebas con clientes

## Escalabilidad

- Diseño preparado para agregar tercer producto (Acero Inox Completo)
- Grid responsive: 1 columna en móvil, 2-3 en desktop
- Fácil agregar más productos editando el HTML

## Consideraciones Legales

Footer incluye:
- Copyright 2026 Dr. Parrilla Paraguay
- Aviso de propiedad intelectual sobre modelos 3D
- Prohibición de reproducción sin autorización
- Link a Política de Privacidad
