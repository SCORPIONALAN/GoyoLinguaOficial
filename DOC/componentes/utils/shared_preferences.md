# SharedpreferenceHelper

Esta clase proporciona métodos para gestionar el almacenamiento local de datos de usuario mediante SharedPreferences en la aplicación Goyolingua.

## Constantes

La clase define varias constantes que actúan como claves para acceder a los datos almacenados:

- `userIdKey`: Clave para el ID del usuario
- `userNameKey`: Clave para el nombre del usuario
- `userEmailKey`: Clave para el email del usuario
- `userImageKey`: Clave para la imagen de perfil del usuario
- `userUserNameKey`: Clave para el nombre de usuario
- `userIdiomaAprender`: Clave para el idioma que el usuario está aprendiendo
- `userIdiomaOrigen`: Clave para el idioma nativo del usuario
- `userEresMaestro`: Clave para indicar si el usuario es maestro
- `userSexo`: Clave para el sexo del usuario

## Métodos Setters

Estos métodos guardan información del usuario en el almacenamiento local.

### `saveUserId(String value)`
- **Descripción**: Guarda el ID del usuario.
- **Parámetros**:
  - `value`: ID del usuario a guardar.
- **Retorno**: Future con un booleano que indica si la operación fue exitosa.

### `saveUserDisplayName(String value)`
- **Descripción**: Guarda el nombre completo del usuario.
- **Parámetros**:
  - `value`: Nombre completo a guardar.
- **Retorno**: Future con un booleano que indica si la operación fue exitosa.

### `saveUserEmail(String value)`
- **Descripción**: Guarda el correo electrónico del usuario.
- **Parámetros**:
  - `value`: Correo electrónico a guardar.
- **Retorno**: Future con un booleano que indica si la operación fue exitosa.

### `saveUserImage(String value)`
- **Descripción**: Guarda la URL de la imagen de perfil del usuario.
- **Parámetros**:
  - `value`: URL de la imagen a guardar.
- **Retorno**: Future con un booleano que indica si la operación fue exitosa.

### `saveUserUserName(String value)`
- **Descripción**: Guarda el nombre de usuario.
- **Parámetros**:
  - `value`: Nombre de usuario a guardar.
- **Retorno**: Future con un booleano que indica si la operación fue exitosa.

### `saveUserIdiomaAprender(String value)`
- **Descripción**: Guarda el idioma que el usuario desea aprender.
- **Parámetros**:
  - `value`: Idioma a aprender.
- **Retorno**: Future con un booleano que indica si la operación fue exitosa.

### `saveUserIdiomaOrigen(String value)`
- **Descripción**: Guarda el idioma nativo del usuario.
- **Parámetros**:
  - `value`: Idioma nativo.
- **Retorno**: Future con un booleano que indica si la operación fue exitosa.

### `saveUserSexo(String value)`
- **Descripción**: Guarda el sexo del usuario.
- **Parámetros**:
  - `value`: Sexo del usuario.
- **Retorno**: Future con un booleano que indica si la operación fue exitosa.

### `saveUserEresMaestro(bool value)`
- **Descripción**: Guarda si el usuario es maestro o no.
- **Parámetros**:
  - `value`: Booleano que indica si el usuario es maestro (true) o estudiante (false).
- **Retorno**: Future con un booleano que indica si la operación fue exitosa.

## Métodos Getters

Estos métodos estáticos recuperan información del usuario desde el almacenamiento local.

### `getUserId()`
- **Descripción**: Obtiene el ID del usuario.
- **Retorno**: Future con el ID del usuario o null si no existe.

### `getUserDisplayName()`
- **Descripción**: Obtiene el nombre completo del usuario.
- **Retorno**: Future con el nombre completo o null si no existe.

### `getUserEmail()`
- **Descripción**: Obtiene el correo electrónico del usuario.
- **Retorno**: Future con el correo electrónico o null si no existe.

### `getUserImage()`
- **Descripción**: Obtiene la URL de la imagen de perfil del usuario.
- **Retorno**: Future con la URL de la imagen o null si no existe.

### `getUserUserName()`
- **Descripción**: Obtiene el nombre de usuario.
- **Retorno**: Future con el nombre de usuario o null si no existe.

### `getUserIdiomaAprender()`
- **Descripción**: Obtiene el idioma que el usuario está aprendiendo.
- **Retorno**: Future con el idioma a aprender o null si no existe.

### `getUserIdiomaOrigen()`
- **Descripción**: Obtiene el idioma nativo del usuario.
- **Retorno**: Future con el idioma nativo o null si no existe.

### `getUserEresMaestro()`
- **Descripción**: Verifica si el usuario es maestro.
- **Retorno**: Future con un booleano que indica si el usuario es maestro o null si no existe.

### `getUserSexo()`
- **Descripción**: Obtiene el sexo del usuario.
- **Retorno**: Future con el sexo del usuario o null si no existe.

## Método para Limpiar Datos

### `clearUserData()`
- **Descripción**: Elimina todos los datos del usuario almacenados localmente cuando se cierra sesión.
- **Retorno**: Future con un booleano que indica si la operación fue exitosa (true) o si hubo un error (false).
