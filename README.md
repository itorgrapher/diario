# Tu diario

Proyecto Flutter con la app completa (sin backend todavía — los datos viven en memoria y se pierden al cerrar la app). Es el primer hito: conseguir una APK real instalada en tu móvil. La sincronización en la nube (Firebase) se añade en un segundo paso.

## Qué contiene

- `lib/` — todo el código de la app (14 pantallas).
- `pubspec.yaml` — dependencias (`provider` para el estado compartido).
- `.github/workflows/build_apk.yml` — hace que GitHub compile el APK automáticamente.

## Pasos para conseguir tu APK

### 1. Crea el repositorio en GitHub
1. Entra en https://github.com/new
2. Nombra el repositorio, por ejemplo `tu-diario-app`.
3. Déjalo público o privado, como prefieras. No marques ninguna casilla de inicialización (README, .gitignore, licencia) — vamos a subir estos archivos directamente.

### 2. Sube este proyecto
Desde una terminal, dentro de esta carpeta:

```bash
git init
git add .
git commit -m "Primera versión de Tu diario"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/tu-diario-app.git
git push -u origin main
```

(Sustituye `TU_USUARIO` y `tu-diario-app` por los tuyos.)

### 3. Espera a que GitHub compile
1. Ve a la pestaña **Actions** de tu repositorio en GitHub.
2. Verás un flujo llamado "Build APK" ejecutándose (tarda unos 5-8 minutos la primera vez).
3. Cuando termine con una marca verde, entra en esa ejecución y baja hasta **Artifacts**.
4. Descarga `tu-diario-apk` (es un .zip que contiene el `.apk` dentro).

### 4. Instala el APK en tu móvil
1. Descomprime el .zip y pásate el archivo `app-release.apk` al móvil (por USB, Google Drive, email... lo que te resulte más cómodo).
2. Ábrelo desde el móvil. Android avisará de que es de "origen desconocido" — es normal porque no viene de Google Play. Acepta permitirlo para esta instalación.
3. Listo, ya tienes la app en tu móvil.

## Qué esperar de esta primera versión

- Todo lo que hemos diseñado funciona de verdad: login (sin verificación real todavía), asistente de 12 preguntas, calendario con filtro y las tres tarjetas del día, nueva entrada, detalle de entrada, Seguimiento, Configurar campos, Perfil (con sus subpantallas), Diario de sueños, Mis lecturas, Ciclo y Desahogo.
- **No hay conexión a internet ni cuenta real todavía** — todo son datos de ejemplo en memoria. Si cierras la app del todo, se reinicia.
- Los interruptores de "Configurar campos" son visuales por ahora; no ocultan aún los campos correspondientes en "nueva entrada" (eso lo conectamos en el siguiente paso, junto con Firebase).

## Siguiente paso

Cuando confirmes que el APK se instala y se navega bien, añadimos Firebase (cuenta real, guardado en la nube, fotos, notificaciones) para que nada se pierda al desinstalar — que era el requisito original.
