
# Widgets de GoyoLingua

Este documento contiene la documentación detallada de los siguientes widgets:
- PersonalCard
- TeachersList
- StudentsList

---

## 📦 `PersonalCard`

Este widget representa una tarjeta individual que muestra información básica de un usuario y permite iniciar un chat con él. Mostrando nombre, imagen y su username ya sea del maestro o del alumno

### Propiedades:
- `userData`: `Map<String, dynamic>` – Contiene la información del usuario a mostrar (nombre, imagen, username).
- `myUsername`: `String?` – Nombre de usuario del usuario actual.
- `getChatRoomIdbyUsername`: `Function(String, String)` – Callback que genera un ID de sala de chat entre dos usuarios.

### Comportamiento:
- Muestra imagen, nombre y username del usuario.
- Si se hace tap en la tarjeta:
  1. Se obtiene el ID del chatroom entre los dos usuarios.
  2. Se crea (o asegura existencia) del chatroom en Firestore.
  3. Navega hacia la página `ChatPage` con los datos del usuario seleccionado.

---

## 📦 `TeachersList`

Este widget representa una lista en tiempo real de todos los maestros disponibles. Esto mediante el concepto importante del stream que viene reemplazando a los sockets, ya que estos permiten una interaccion de tiempo real, en este caso para la base de datos de firebase

### Propiedades:
- `teachersStream`: `Stream<QuerySnapshot>?` – Stream de documentos de Firestore con los maestros.
- `myUsername`: `String?` – Nombre de usuario del usuario actual.
- `getChatRoomIdbyUsername`: `Function(String, String)` – Callback para obtener el ID del chat.

### Comportamiento:
- Mientras `teachersStream` no esté disponible, muestra un loader.
- Si hay error o no hay datos, se muestra un mensaje.
- Si hay datos, renderiza una lista de `PersonalCard` con cada maestro.

---

## 📦 `StudentsList`

Este widget es casi idéntico a `TeachersList`, pero en vez de mostrar maestros, muestra estudiantes. De igual forma con el uso de streams para mostrar en tiempo real a los profesores

### Propiedades:
- `StudentsStream`: `Stream<QuerySnapshot>?` – Stream de documentos con los estudiantes.
- `myUsername`: `String?` – Nombre de usuario actual.
- `getChatRoomIdbyUsername`: `Function(String, String)` – Callback para obtener el ID del chat.

### Comportamiento:
- Mismo flujo de carga/error/datos que `TeachersList`.
- Renderiza cada estudiante en una tarjeta `PersonalCard`.

