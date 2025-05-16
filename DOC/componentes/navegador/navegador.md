# Documentación del Navegador - GoyoLingua

Este archivo documenta el funcionamiento del widget `Navegador`, el cual gestiona la navegación entre las distintas pantallas principales de la aplicación GoyoLingua. Cosa que siempre estara en todo momento con nosotros


## 📚 Descripción:
El `Navegador` es un widget de tipo `StatefulWidget` que maneja un `BottomNavigationBar` para permitir cambiar entre distintas pantallas: 
- Página de ejercicios
- Página de chats
- Página de interacción con la IA (GoyoSeek)

---

### 📌 Propósito:
Proveer un contenedor de navegación persistente con múltiples pantallas dentro de la aplicación.

### 🔧 Métodos:

#### ✅ `createState()`
Crea una instancia del estado asociado `_NavegadorState`.

---

## 🔧 Clase interna: `_NavegadorState`

### 🔢 Variables:
- `int _indexActual`: Índice actual del `BottomNavigationBar`.
- `List<Widget> _pantallas`: Lista de widgets que representan las pantallas de navegación:
  - `HomePage()`: Página principal de ejercicios.
  - `ChatHomePage()`: Página para interactuar con otros usuarios.
  - `ChatIAPage(...)`: Página que inicia una conversación con GoyitoIA (asistente conversacional).

### 🔁 Método: `_cambiarPantalla(int index)`
Cambia el valor de `_indexActual`, lo que actualiza la pantalla mostrada.

### 🏗️ Método: `build(BuildContext context)`
Construye la interfaz del navegador:
- Muestra la pantalla correspondiente al índice actual.
- Muestra un `BottomNavigationBar` con tres ítems:
  - 🏠 Inicio
  - 💬 Chat
  - 🤖 GoyoSeek (IA)

---

## 💬 Comentarios adicionales:
- El ítem "GoyoSeek" es una implementación personalizada del asistente virtual de la app.
- El código fue adaptado desde un recurso anterior llamado "Frankie".

---
