# RTF 2.0 - App de campo (Flutter)

App nativa del visitador. Habla con la misma API que la app web publicada:

- `POST https://rtf-form-flow.base44.app/functions/campoLogin`
- `POST https://rtf-form-flow.base44.app/functions/campoMisiones`
- `POST https://rtf-form-flow.base44.app/functions/campoOperacion`

La sesión se abre con el **usuario móvil** y la **clave móvil** que el administrador
define en la ficha del colaborador. El servidor devuelve un token firmado y todas las
operaciones viajan con ese token; no hay llaves ni secretos dentro de la app.

## Puesta en marcha

1. Copia la carpeta `flutter/rtf_campo` a tu equipo y entra a ella.
2. Genera las carpetas de plataforma (no se versionan aquí):

   ```bash
   flutter create . --project-name rtf_campo --org com.rtf --platforms=android,ios
   flutter pub get
   ```

3. Configura Google Maps y permisos (ver abajo).
4. Conecta un teléfono y corre:

   ```bash
   flutter run
   ```

5. Para el APK de pruebas:

   ```bash
   flutter build apk --release
   ```

## Android

El manifiesto principal ya declara los permisos de Internet, ubicación y cámara
para builds de depuración y de release.

Para que los mapas funcionen, agrega dentro de `<application>` en
`android/local.properties`:

```properties
MAPS_API_KEY=TU_LLAVE_MAPS_ANDROID
```

La llave de Google Maps para la app **no** es la del navegador: crea una llave con
restricción de aplicación Android que coincida con el `applicationId` configurado
(actualmente `com.example.rtf_campo`) y su huella SHA-1 en Google Cloud Console. El
archivo `local.properties` está excluido de Git y no debe versionarse.

## iOS

En `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

GMSServices.provideAPIKey("TU_LLAVE_MAPS_IOS")
```

En `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>RTF usa tu ubicación para el check-in de la visita.</string>
<key>NSCameraUsageDescription</key>
<string>RTF usa la cámara para capturar evidencias de la visita.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>RTF usa tus fotos como evidencia de la visita.</string>
```

## Qué incluye

- Acceso con usuario y clave de campo, sesión persistente y cierre de sesión.
- Misiones del día y todas, con estatus, hora, dirección y alerta SOS.
- Calendario mensual con indicadores por día y filtro de misiones pasadas.
- Mapa de las misiones del día y mapa con pin de cada tienda.
- Detalle de la visita: check-in y check-out con GPS, pausas, reinicios, SOS,
  objetivos por actividad, evidencias fotográficas, firma, comentarios,
  inventario y cierre con resultado.
- Asistencia (entrada / salida con ubicación) y viáticos con comprobante.
- Cola offline con `sqflite`: lo capturado sin señal se guarda en el teléfono y se
  reenvía al recuperar conexión.

## Pendiente para una segunda etapa

- Captura de audio y video desde la app (la API ya acepta `audio` y `video`; falta
  la interfaz de grabación).
