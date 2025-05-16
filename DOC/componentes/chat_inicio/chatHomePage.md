
# `ChatHomePage`

Este archivo contiene la implementación de la pantalla principal de chat de la aplicación **GoyoLingua**, donde los usuarios pueden buscar otros usuarios (estudiantes o maestros) y acceder a chats individuales. Se adapta dinámicamente al rol del usuario (estudiante o maestro) y ofrece funcionalidades de búsqueda y navegación a perfiles.

---

## 🧩 Clase Principal: `ChatHomePage`

### 🌱 `StatefulWidget`
Este widget mantiene el estado para la pantalla de inicio del chat.

---

## 🧠 Estado: `_ChatHomePageState`

### 🔐 Variables

- **Streams**:  
  - `chatTeacherStream`, `chatStudentStream`: Flujo de datos de usuarios tanto de estudiantes como de maestros
- **Datos de usuario**:  
  - `myUsername`, `myName`, `myEmail`, `myPicture`, `amITeacher`: Datos recuperados de las preferencias.
- **Controladores y búsqueda**:  
  - `searchcontroller`: Controlador de texto.
  - `search`: Estado actual de búsqueda.
  - `queryResultSet`, `tempSearchStore`: Datos de resultados de búsqueda.

---

## 🔄 Ciclo de vida

### `initState()`

1. Recupera datos del usuario usando `SharedpreferenceHelper`.
2. Obtiene los streams de estudiantes y maestros desde Firestore.
3. Llama a `setState()` para actualizar la UI.

---

## 🔍 Búsqueda

### `initiateSearch(String value)`

- Si el campo de búsqueda está vacío:
  - Se desactiva la búsqueda y se limpia el estado.
- Si se ingresa una letra:
  - Se realiza una consulta a la base de datos.
- Si ya hay resultados:
  - Se filtran los resultados en tiempo real usando `startsWith`.

---

## 🧱 Interfaz de Usuario (`build`)

### 🎨 Diseño General

- Fondo oscuro con diseño adaptativo.
- Contiene:
  - **Zona superior**: Logo, saludo, botón de perfil y nombre del usuario.
  - **Zona inferior**: Caja de búsqueda, resultados de búsqueda o listas condicionales.

---

### 📚 Widgets principales

#### 🔼 Header

- Imagen de Goyo.
- Mensaje de bienvenida.
- Nombre del usuario.
- Icono para acceder al perfil (`ProfilePage`).

#### 🔍 Barra de búsqueda

- Caja de texto con estilo personalizado.
- `onChanged`: Llama a `initiateSearch`.

#### 🔽 Contenido dinámico

- Si `search` es `true`: muestra una lista de resultados usando `PersonalCard`.
- Si es maestro (`amITeacher == true`): muestra lista de estudiantes (`StudentsList`).
- Si no: muestra lista de maestros (`TeachersList`).

---

## 📌 Comportamiento Condicional

```dart
amITeacher!
  ? StudentsList(...)
  : TeachersList(...)
```

La pantalla adapta el contenido mostrado en función del rol del usuario:
- Si es maestro, se listan estudiantes.
- Si es estudiante, se listan maestros.

---

## 🧪 Utilidades Clave

- `SharedpreferenceHelper`: Abstracción para obtener los datos locales del usuario.
- `DatabaseMethods`: Capa de acceso a la base de datos para obtener streams de Firestore.
- `ChatUtils.getChatRoomIdByUsername`: Función que retorna el `chatRoomId` entre dos usuarios.
