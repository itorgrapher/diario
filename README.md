# Ánima

Rediseño visual y de navegación siguiendo el estilo editorial de la referencia que me pasaste: título en tipografía serif, calendario con círculos de ánimo por icono, tarjetas de "Hoy" en fila, y navegación híbrida (barra inferior para contenido, menú lateral para ajustes).

**Navegación:**
- Barra inferior: Calendario, Seguimiento, Sueños (solo si lo activaste), Desahogo.
- Menú lateral (☰, desde el Calendario): Configurar campos, Perfil — y, si los tienes activados, Mis lecturas y Ciclo — y Cerrar sesión.

## Antes de compilar
Los mismos dos pasos de Firebase de la vez anterior (reglas de Firestore + Authentication activado) siguen siendo necesarios. Si ya los hiciste, no hace falta repetirlos.

## Cómo compilar
Igual que siempre: sustituye tus archivos por estos (esta vez cambia prácticamente todo `lib/`, más `pubspec.yaml` por la fuente nueva) y sube con GitHub Desktop. La pestaña Actions compilará el APK.

## Qué probar
1. La pantalla de calendario: título "ÁNIMA" en serif, navegación de mes con flechas, círculos de ánimo por día, las tres tarjetas de hoy, y el botón de lápiz abajo.
2. Toca la barra inferior — cambia entre Calendario, Seguimiento, Sueños (si está activo) y Desahogo sin perder tu sitio en cada uno.
3. Abre el menú (☰) desde el calendario — deberías ver Configurar campos y Perfil siempre, y Mis lecturas/Ciclo solo si los activaste en Configurar campos.
4. Activa o desactiva "Diario de sueños" en Configurar campos y comprueba que la pestaña aparece o desaparece de la barra inferior.


