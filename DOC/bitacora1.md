# Bitácora 1
### Avance de **Alan Torres**

Este proyecto representa una versión inicial de una idea con gran potencial de escalabilidad. Sin embargo, decidimos mantenernos enfocados exclusivamente en la plataforma móvil por ahora, ya que no tiene sentido expandir a otros entornos si la prioridad actual es el desarrollo para dispositivos móviles.

## Base de datos y configuraciones

Contamos con un proyecto previo en Firebase bajo el nombre *ScorpLingua*, donde ya teníamos definidos los ejercicios en formato JSON. Aprovechando esta estructura preexistente, desarrollamos un script para automatizar la carga de teoría y ejercicios dentro de la base de datos.

## Estructura principal

Estamos utilizando una paleta de colores basada en tonos escolares, principalmente naranjas y blancos, con algunos acentos morados para reflejar una estética moderna. Esta paleta está implementada mediante un tema personalizado.

- [Ver tema personalizado](../goyolingua/lib/core/theme/theme.dart)

Los recursos internos se encuentran en la carpeta `assets`, donde almacenamos:
- La fuente tipográfica **Raleway** descargada de Google Fonts ([ver fuente](https://fonts.google.com/specimen/Raleway))
- Las imágenes necesarias para la construcción de la aplicación, evitando así una dependencia total de Firestore.

## Estructura del código

El proyecto está modularizado en las siguientes secciones:

- **Core**: Contiene la lógica visual, los widgets reutilizables, el consumo de servicios externos (como APIs REST), y la integración con herramientas como OpenAI para procesar ciertos ejercicios. Aquí se cuida especialmente la protección de claves API y datos sensibles.

- **Pages**: Incluye todas las páginas navegables de la aplicación, es decir, las diferentes vistas que el usuario puede recorrer.


## Primeros pasos en la app

Con una visión general clara del proyecto, decidimos comenzar por uno de los componentes más desafiantes: el chat en tiempo real.

Optamos por descartar el uso de sockets y en su lugar aprovecharemos Firebase Cloud para manejar la lógica del chat en tiempo real, dado que ya tenemos definida la estructura necesaria del backend.

Durante esta primera jornada nos concentramos en implementar el inicio de sesión y construir la interfaz gráfica (frontend) del chat. Este fue nuestro enfoque principal durante el día.
