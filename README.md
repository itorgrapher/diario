# Tu diario

Segundo hito: cuentas reales con Firebase, y las entradas (texto, ánimo/sueño/energía/líbido/estrés, gratitud y fotos) se guardan de verdad en la nube — ya no se pierden al cerrar la app. Las tareas, la hidratación y el ejercicio de cada día también se guardan y quedan en el histórico del calendario.

**Lo que queda para el siguiente bloque** (ya decidido, pendiente de montar): dictado y notas de voz, bloqueo biométrico, recordatorio diario, ubicación automática, y compartir una entrada como imagen. Diario de sueños, Mis lecturas y Ciclo siguen siendo de ejemplo por ahora (se conectan a Firebase en un paso posterior).

## Antes de compilar — dos pasos tuyos, imprescindibles

### 1. Reglas de seguridad de Firestore
Sin esto, la app compilará pero nada se guardará (error de "permiso denegado"). Ve a Firebase → **Firestore Database → Reglas**, y pega:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
Pulsa "Publicar".

### 2. Authentication activado
Firebase → **Authentication → Sign-in method** → activa **Correo electrónico/contraseña** (si no lo hiciste ya).

## Cómo compilar
Igual que la vez anterior: sube estos archivos a tu repositorio de GitHub (sustituyendo los que ya había) y la pestaña **Actions** compilará el APK automáticamente. El flujo ya incluye una corrección automática para un problema conocido de compatibilidad entre Firebase y Android (minSdkVersion), así que no tienes que tocar nada de Android tú mismo.

## Qué probar en el móvil
1. Crea una cuenta con email y contraseña.
2. Pasa el asistente de bienvenida.
3. Escribe una entrada, marca ánimo, añade una foto.
4. **Cierra la app del todo y vuelve a abrirla** — todo debería seguir ahí (esa es la prueba de que ya no vivimos solo en memoria).
5. Marca tareas, vasos de agua y ejercicio en el calendario, y comprueba que un día pasado con ese registro se ve correctamente al tocarlo.
6. Cierra sesión desde Perfil y desde el menú lateral — en ambos casos debe llevarte limpiamente a la pantalla de login.

