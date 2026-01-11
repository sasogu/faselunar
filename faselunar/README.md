# FaseLunar

App Flutter para consultar la fase lunar (cálculo local/offline) con:

- Fase actual y para una fecha seleccionada
- Iluminación (%) y edad lunar
- Próxima luna llena, luna nueva y próximo cuarto (precisión tipo “calendario”)
- Web (Firefox/Chrome) y Android
- Widget Android (fase + ilustración) con actualización cada 12 horas

## Requisitos

- Flutter (canal estable)
- Android SDK si quieres generar APK

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

## Generar APK (release)

```bash
cd faselunar
flutter build apk --release
```

Salida:

- `build/app/outputs/flutter-apk/app-release.apk`

## Widget Android

El widget muestra:

- Ilustración de la fase (luna)
- Texto de fase actual
- % de iluminación

Actualiza automáticamente cada 12h y también se intenta refrescar al abrir/refrescar la app.

## Licencia

Este proyecto está licenciado bajo la licencia MIT. Ver el archivo `LICENSE`.
