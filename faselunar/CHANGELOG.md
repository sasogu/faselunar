# Changelog

Todas las versiones notables de FaseLunar se documentan en este archivo.

## [1.1.0] - 2026-08-13

### Añadido

- Widget iOS (WidgetKit) con las familias `systemSmall` y `accessoryCircular` (pantalla de inicio y pantalla de bloqueo).
- Cálculo de la fase lunar en Swift para el widget, replicando `MoonPhaseService`.
- App Group `group.com.sasogu.faselunar` para sincronizar la fecha seleccionada entre la app y el widget.
- Canal nativo iOS (`com.sasogu.faselunar/widget`) con los métodos `updateMoonWidget`, `setSelectedDate` y `clearSelectedDate`.
- Deployment target mínimo de iOS 16 para la app y la extensión.

### Cambiado

- La app también refresca el widget al abrir/refrescar en iOS (antes solo en Android).
- README actualizado con las instrucciones de iOS y el widget WidgetKit.

## [1.0.0] - 2026-01-11

### Añadido

- Primera versión: app Flutter con cálculo local/offline de la fase lunar.
- Fase actual y para una fecha seleccionada, iluminación (%), edad lunar, próxima luna llena/nueva y próximo cuarto.
- Soporte web, Android, iOS, Linux, macOS y Windows.
- Internacionalización ca/es/en.
- Widget Android con actualización cada 12 horas.
