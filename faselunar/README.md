# FaseLunar

App Flutter para consultar la fase lunar (cálculo local/offline) con:

- Fase actual y para una fecha seleccionada
- Iluminación (%) y edad lunar
- Próxima luna llena, luna nueva y próximo cuarto (precisión tipo “calendario”)
- Web (Firefox/Chrome), Android e iOS
- Widget Android (fase + ilustración) con actualización cada 12 horas
- Widget iOS (WidgetKit) con actualización cada 6 horas

## Requisitos

- Flutter (canal estable)
- Android SDK si quieres generar APK
- Xcode (macOS) si quieres compilar para iOS

## Ejecutar en web

En este repo se usa el dispositivo `web-server` (no requiere Chrome instalado):

```bash
cd faselunar
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 52123
```

Abre `http://127.0.0.1:52123` en tu navegador.

## Ejecutar en Android

Con dispositivo conectado o emulador:

```bash
cd faselunar
flutter run -d android
```

## Ejecutar en iOS

En macOS, con un simulador o dispositivo conectado:

```bash
cd faselunar
flutter run -d ios
```

## Generar APK (release)

```bash
cd faselunar
flutter build apk --release
```

Salida:

- `build/app/outputs/flutter-apk/app-release.apk`

## Generar app iOS (release)

```bash
cd faselunar
flutter build ios --release
```

> Nota: requiere macOS con Xcode. El widget iOS usa WidgetKit, por lo que el
> deployment target es iOS 16 o superior.

## Widget Android

El widget muestra:

- Ilustración de la fase (luna)
- Texto de fase actual
- % de iluminación

Actualiza automáticamente cada 12h y también se intenta refrescar al abrir/refrescar la app.

## Widget iOS (WidgetKit)

El widget de la pantalla de inicio y el de pantalla de bloqueo (`accessoryCircular`)
muestran la misma información que la app:

- Ilustración de la fase (luna)
- Nombre de la fase
- % de iluminación

Actualiza automáticamente cada 6h. Si en la app seleccionas una fecha concreta,
el widget muestra la fase de esa fecha hasta que vuelvas a abrir la app con la
fecha actual. La sincronización usa el App Group `group.com.sasogu.faselunar`.

> Para instalar en un dispositivo físico hay que activar la capability
> "App Groups" con `group.com.sasogu.faselunar` en el target de la app y de la
> extensión del widget (Xcode).

## Licencia

Este proyecto está licenciado bajo la licencia MIT. Ver el archivo `LICENSE`.
