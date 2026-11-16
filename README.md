# Revisión de publicaciones

App móvil interna para Metricser que reemplaza la revisión informal de publicaciones con una checklist compartida. Cada pieza se revisa en cinco puntos (ortografía, logo y marca, horario, aprobación del cliente y formato de la plataforma) y solo queda **"Lista para publicar"** cuando los cinco están marcados.

Proyecto integrador, etapa 3: *Soluciones de Programación Móvil*, Universidad del Valle de México.

## Descargar

**[Descargar APK (v1.0.1)](https://github.com/JavierAuG2504/revision_publicaciones/releases/latest/download/revision_publicaciones_v1.0.1.apk)**

Requiere Android 10 o superior y conexión a internet.

## Funciones

| Operación | Dónde se hace en la app |
|---|---|
| **Crear** | Botón "Nueva publicación" en la lista |
| **Leer** | Lista de publicaciones y pantalla de detalle, actualizadas en tiempo real |
| **Actualizar** | Marcar los puntos de la checklist y el botón de editar (lápiz) en el detalle |
| **Borrar** | Botón de bote de basura en el detalle (solo quien creó la publicación) |
| **IA** | Botón "Revisar ortografía con IA" en el detalle (Gemini) |
| **Aviso** | Notificación cuando una publicación propia pasa a "Lista para publicar" |

## Tecnologías

- **Flutter / Dart** para la app
- **Firebase Authentication** para el inicio de sesión
- **Cloud Firestore** como base de datos en la nube
- **Firebase AI Logic con Gemini** (`gemini-3.8-flash`, con respaldo `gemini-3.5-flash-lite`) para la revisión de ortografía
- **Firebase App Check** para proteger el acceso a Gemini
- **flutter_local_notifications** para el aviso en el dispositivo

Todo funciona en el plan gratuito de Firebase (Spark).

## Guía para verificar el funcionamiento

### 1. Instalar el APK

1. Descarga el APK desde el enlace de arriba en un teléfono Android.
2. Ábrelo. Si Android lo bloquea, permite **"Instalar apps desconocidas"** para tu navegador o administrador de archivos.
3. Al abrir la app por primera vez, acepta el permiso de **notificaciones**.

### 2. Iniciar sesión

Usa una de las cuentas de prueba incluidas en el **documento de entrega del proyecto**. Las credenciales no se publican en este repositorio porque es público.

### 3. Probar el CRUD y la IA

1. **Crear:** toca "Nueva publicación", llena el formulario y escribe un texto con algún error de ortografía (por ejemplo, *"Ven a provar nuestro cafe"*). Guarda.
2. **Leer:** la publicación aparece en la lista con el estado "Pendiente" y "0 de 5 puntos revisados".
3. **IA:** abre la publicación y toca "Revisar ortografía con IA". Gemini muestra las correcciones.
4. **Actualizar:** marca los puntos de la checklist. Debajo de cada uno aparece quién lo marcó.
5. **Aviso:** al marcar el quinto punto, el estado cambia a "Listo para publicar" y llega una notificación.
6. **Editar:** toca el lápiz, cambia el título y guarda.
7. **Borrar:** toca el bote de basura y confirma. La publicación desaparece de la lista.

### 4. Probar la seguridad (opcional)

Inicia sesión con la segunda cuenta de prueba e intenta borrar una publicación creada por la primera. La app lo impide, y las reglas de Firestore también lo rechazan en el servidor.

## Compilar desde el código

```bash
flutter pub get
flutterfire configure --project=<tu-proyecto> --platforms=android
flutter run
```

El proyecto necesita su propio proyecto de Firebase con Authentication (correo y contraseña), Firestore con las reglas de `firestore.rules`, AI Logic (Gemini Developer API) y App Check con un token de depuración registrado.

El APK de entrega se compiló pasando un token de App Check con `--dart-define=APP_CHECK_DEBUG_TOKEN=…`. Ese token **no está en el repositorio**.
