# Documentación de dependencias
## Dependencias principales

### Servicios de Firebase
- **firebase_core (^3.13.0):** Biblioteca base para todos los servicios de Firebase, necesaria para la inicialización.
- **cloud_firestore (^5.6.7):** Base de datos NoSQL en la nube para almacenar y sincronizar datos en tiempo real.
- **firebase_storage (^12.4.5):** Almacenamiento de archivos en la nube para guardar imágenes, audio y otros archivos.
- **firebase_auth (^5.5.3):** Servicio de autenticación para gestionar usuarios, login y registro.

### Autenticación y cuenta de usuario
- **google_sign_in (^6.3.0):** Permite la autenticación de usuarios con cuentas de Google.

### Gestión de archivos y medios
- **image_picker (^1.1.2):** Selección de imágenes de la galería o cámara del dispositivo.
- **permission_handler (^12.0.0):** Manejo de permisos del dispositivo (cámara, micrófono, etc.).
- **path_provider (^2.1.5):** Acceso a ubicaciones de archivos en el sistema.
- **flutter_sound (^9.28.0):** Grabación y reproducción de audio.
- **audioplayers (^6.4.0):** Reproducción de archivos de audio.
- **just_audio (^0.10.2):** API de audio avanzada con mejor rendimiento.
- **video_player (^2.9.5):** Reproducción de archivos de video.

### Almacenamiento local
- **shared_preferences (^2.5.3):** Almacenamiento persistente de datos simples en el dispositivo.

### Utilidades
- **random_string (^2.3.1):** Generación de cadenas aleatorias (posiblemente para IDs).
- **intl (^0.20.2):** Internacionalización y localización (traducciones, formatos de fecha, etc.).
- **markdown_widget (^2.3.2):** Renderizado de contenido en formato Markdown. `Este se nos olvido quitarlo ya que no lo usamos`
- **http (^1.4.0):** Cliente HTTP para realizar peticiones a APIs y servicios web.

### Configuración de la aplicación
- **flutter_launcher_icons (^0.14.3):** Generación de iconos de lanzamiento para diferentes plataformas.

## Dependencias de desarrollo
- **flutter_test:** Framework de pruebas para Flutter.
- **flutter_lints (^5.0.0):** Reglas de análisis estático para mantener un código limpio.

## Configuración de diseño
- **uses-material-design:** true (Habilita el uso de Material Design)

## Fuentes personalizadas
- **Raleway:** Familia de fuentes con varios pesos (100-900) desde Thin hasta Black.
- [Fuente oficial](https://fonts.google.com/specimen/Raleway)

## Recursos (assets)
- **Imágenes:** 
  - assets/img/GoyoLingua.png
  - assets/img/GoyoSaludo.png
- **Iconos:**
  - assets/icon/iconGoyito.png (Utilizado como icono de la aplicación)
