# Bitacora 2 Chat Page
## Por **Alan Torres**
# Chat App Page

## Descripción General
Esta es una parte indispensable para nuestro código, ya que es la parte del Chat por usuario. Como tal le debemos pasar el username (único pues no existen correos iguales), su nombre para mostrarlo y finalmente su imagen.

Escencialmente la página esta compuesta de 3 partes
- El header que va a traer los datos del sender y un boton de regreso
- El cuerpo el encargado de cargar todas las imagenes de todos los usuarios
- El input la parte encargada de enviar audios, texto e imagenes con su respectivo boton de envio

## Características Principales

### 1. Mensajería en Tiempo Real
- Envío y recepción de mensajes de texto
- Visualización de mensajes ordenados cronológicamente
- Indicador de tiempo para cada mensaje

### 2. Compartir Multimedia
- Envío de imágenes desde la galería
- Grabación y envío de notas de voz
- Reproducción de notas de voz

### 3. Interfaz de Usuario
- Diseño responsivo que se adapta a diferentes tamaños de pantalla
- Burbujas de chat diferenciadas para mensajes enviados y recibidos
- Identificación visual del remitente con foto de perfil

## Estructura del Código


### Estado (_ChatPageState)
Maneja el estado y la lógica de la aplicación, incluyendo:
- Inicialización de variables
- Configuración de permisos
- Gestión de mensajes
- Reproducción y grabación de audio
- Carga de imágenes

## Flujo de Funcionamiento

### Inicialización
Cuando la pantalla se carga:
1. Se obtienen datos del usuario desde SharedPreferences
2. Se configura el chatRoomId basado en los nombres de usuario
3. Se inicializan los componentes de audio
4. Se cargan los mensajes existentes

### Envío de Mensajes de Texto
1. El usuario escribe en el TextField
2. Al presionar "Envia!", el mensaje se formatea y se sube a Firebase
3. El mensaje aparece inmediatamente en la pantalla

### Envío de Imágenes
1. El usuario presiona el icono de adjuntar
2. Se abre un diálogo para seleccionar desde la galería
3. La imagen seleccionada se sube a Firebase Storage
4. Se crea un registro en Firestore con la URL de la imagen

### Notas de Voz
> **Nota**: Para esta parte recurrí a la ayuda de IA ya que me resultaba complejo manejar la reproducción de audio en Flutter.

1. Al presionar el icono del micrófono, se muestra un diálogo de grabación
2. El usuario puede iniciar, detener y enviar la grabación
3. El audio se sube a Firebase Storage
4. En el chat, aparece como un elemento reproducible

## Componentes Técnicos Importantes

### Permisos
La aplicación requiere varios permisos:
- Micrófono (para grabación de audio)
- Almacenamiento (para acceder a la galería)

```dart
Future<void> _requestPermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    await Permission.microphone.request();
  }
  await Permission.storage.request();
}
```

### Base de Datos
Utiliza Firebase Firestore para:
- Almacenar mensajes y sus metadatos
- Crear salas de chat entre usuarios

### Almacenamiento
Firebase Storage para:
- Guardar archivos de audio e imágenes
- Generar URLs para acceder a estos recursos

Pero aqui punto importante, si se trataba del storage era subirlo desde ese código. En cambio si se trataba de afectar a la base de datos se hacia en la parte de los servicios de la base de datos (Crear los chatRooms donde si no existe lo crea y si si carga los mensajes previos para no tener que crear otra sala)

## Retos y Soluciones

### Audio (Con Ayuda de IA)
Me resultó particularmente difícil implementar la funcionalidad de audio, así que utilicé asistencia de IA para ayudarme con:

1. El manejo de la reproducción con `just_audio`
2. La gestión de estados durante grabación y reproducción
3. El manejo de errores y permisos

Esta ayuda es debido a que desconocia la libreria y ya no tenia tiempo para buscar videos, asi que solo esta parte se uso eso (En caso de no ser aceptado borrar)
Por ejemplo, la parte de reproducción de audio fue especialmente compleja:

```dart
Future<void> _playAudio(String audioUrl) async {
  try {
    // Si ya estoy reproduciendo este audio, lo pauso
    if (_currentlyPlayingUrl == audioUrl && _isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    // Si estoy reproduciendo otro audio, lo detengo completamente
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    }

    // Configuramos el audio desde cero
    await _audioPlayer.setUrl(audioUrl);
    _currentlyPlayingUrl = audioUrl;
    await Future.delayed(Duration(milliseconds: 50));
    await _audioPlayer.seek(Duration.zero);
    await _audioPlayer.play();
    setState(() {
      _isPlaying = true;
    });
  } catch (e) {
    // Manejo de errores...
  }
}
```

### Interfaz Responsiva
Otro reto fue crear una interfaz que se adaptara a diferentes tamaños de pantalla. Utilicé `MediaQuery` para obtener las dimensiones de la pantalla y basar los tamaños en proporciones:

```dart
final screenWidth = MediaQuery.of(context).size.width;
// Uso de proporciones para definir tamaños
fontSize: screenWidth * 0.035
```

## Posibles Mejoras

Para futuras versiones, me gustaría:

1. Mejorar la interfaz de usuario
2. Mejorar el manejo de errores durante la carga de archivos
3. Optimizar el rendimiento para chats con muchos mensajes

## Dependencias Principales

- `firebase_storage`: Para almacenamiento de archivos
- `cloud_firestore`: Para la base de datos en tiempo real
- `flutter_sound`: Para grabación de audio
- `just_audio`: Para reproducción de audio
- `image_picker`: Para selección de imágenes
- `permission_handler`: Para gestión de permisos
