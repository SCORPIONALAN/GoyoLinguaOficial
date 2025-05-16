
# HomePage Widget

## Descripción General

Este widget que nosotros construimos se encarga de mostrar una lista de clases (lecciones) en forma de tarjetas (`Card`) que son cargadas dinámicamente desde una base de datos mediante el método `obtenerTodasLasLecciones()`.

---

## Imagen de Main

![Main](image.png)

---

## Estructura General

- Se trata de un `StatelessWidget` que construye su UI a partir de datos obtenidos de forma asíncrona.
- Utiliza `FutureBuilder` para manejar diferentes estados de conexión (cargando, error, datos disponibles).

---

## Método `obtenerClasesParaTarjetas`

```dart
Future<List<MapEntry<String, Leccion>>> obtenerClasesParaTarjetas() async
```
- Función asincrónica que invoca a `DatabaseMethods().obtenerTodasLasLecciones()` para recuperar todas las lecciones disponibles desde Firebase.
- Retorna una lista de pares clave-valor (`MapEntry`), donde la clave es el ID del documento y el valor es un objeto `Leccion`.

---


## FutureBuilder

```dart
FutureBuilder<List<MapEntry<String, Leccion>>>
```
- Se encarga de construir el cuerpo de la pantalla dependiendo del estado del `Future`.
- **Estados manejados**:
  - **Cargando**: `CircularProgressIndicator`
  - **Error**: Texto con el mensaje de error.
  - **Datos vacíos**: Mensaje indicando que no hay clases disponibles.
  - **Datos presentes**: Lista de tarjetas construidas con `ListView.builder`.

---

## ListView y Card

- Se itera sobre las lecciones usando `ListView.builder`.
- Cada `Card` muestra:
  - **Título**: `leccion.nombre`
  - **Subtítulo**: Primeros 50 caracteres de `leccion.texto`
  - **Ícono**: `Icons.arrow_forward_ios` para denotar navegabilidad.
  - **onTap**: Navega a `CargaLeccion` pasando el `id` de la lección correspondiente.

---

## Navegación

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => CargaLeccion(claseId: id),
  ),
);
```
- Permite el enrutamiento hacia la vista de detalles de la clase seleccionada (`CargaLeccion`).

---

## Dependencias Importadas

- `database.dart`: Métodos para acceder a la base de datos de lecciones.
- `leccion_model.dart`: Modelo de datos para representar una lección.
- `profile.dart`: Pantalla del perfil de usuario.
- `teoria.dart`: Contiene `CargaLeccion`, widget para cargar lecciones individuales.



## Modelo Leccion
Este modelo es para la representación abstracta de nuestras lecciones, aqui definimos sus propiedades como el titulo, texto, imagen, video. Pero como se trata de cosas que estan dentro de firestore, podemos hacer uso de un factory para cargar datos dentro de la instancia de la clase con la informacion de la base de datos o asignando por default los valores.
