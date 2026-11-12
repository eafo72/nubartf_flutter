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

`android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
```

Dentro de `<application>`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_LLAVE_MAPS_ANDROID" />
```

En `android/app/build.gradle`, dentro de `defaultConfig`:

```gradle
minSdkVersion 23
```

La llave de Google Maps para la app **no** es la del navegador: crea una llave con
restricción de aplicación Android (paquete `com.rtf.rtf_campo` + huella SHA-1) en
Google Cloud Console.

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
