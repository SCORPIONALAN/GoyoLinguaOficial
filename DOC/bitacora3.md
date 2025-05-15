# Bitácora 3
### Avance de **Valeria**

Mi avance es correspondiente a la corrección del cerrado de sesión, al estar investigando un poco más sobre los metodos de google
```dart
await GoogleSignIn()
          .disconnect();
```
con este pedazo de código se encargaba de la liberación de todo. De igual forma me encargue de refactorizar los códigos de **OnBroading**, **Auth**, **Profile** con el fin de tenerlos mejor entendidos y con comentarios ya no habra inconvenientes futuros de saber sobre que es lo que hace tal o cual función.
Todo esta documentación la agrege a estos documentos
- [Todo el proceso de autenticación desde inicio a fin](./componentes/onBoarding/autenticacion.md)

- [Pantalla para complementar la información](./componentes/onBoarding/completar.md)