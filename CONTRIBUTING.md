# Trabajo del equipo

## Antes del primer aporte
Joaquín y Frank deben usar sus propias cuentas GitHub. Joaquín debe agregar a Frank como colaborador y Frank aceptar la invitación. Ambos clonan el repositorio. No compartir cuentas ni configurar la identidad de Git de otra persona.

Comprobar la identidad local:
```bash
git config user.name
git config user.email
```
Si falta o es incorrecta, configurar dentro de este repositorio el nombre propio y un correo verificado en la cuenta GitHub (o el noreply que GitHub proporciona). No copiar el correo de un compañero.

## Un avance concreto por rama
```bash
git switch main
git pull --ff-only
git switch -c feature/analisis-origen
```
Modificar y comprender los archivos. Antes de registrar:
```bash
git status
git diff
git add database/scripts/01_explorar_origen.sql docs/analisis-origen.md
git diff --cached
git commit -m "Documenta tablas y hallazgos de la exploracion de BikeZ"
git push -u origin feature/analisis-origen
```
El nombre de rama es un ejemplo: elegir uno disponible que describa el trabajo actual. Agregar solo archivos revisados. Abrir un Pull Request desde la rama hacia main, explicar el cambio y la validación, y pedir al compañero que lo revise. La aprobación debe reflejar una revisión efectiva.

## Commits que explican el avance
Ejemplos para cambios efectivamente realizados:
- `Agrega conteos y fechas del origen BikeZ`.
- `Justifica indicadores y granularidad de ventas`.
- `Crea DimProducto y su relacion con FactVentas`.
- `Implementa carga SSIS de DimCliente`.
- `Concilia cantidades e importes de la carga`.

No dividir un mismo cambio en commits vacíos para aumentar el contador. No hacer cambios cosméticos como sustituto de participación sustantiva. No cambiar fechas ni autores para simular trabajo. Tampoco atribuir automáticamente a un estudiante archivos que todavía no revisó ni comprende.

## Qué se versiona
SQL, documentación, diagramas, solución/proyecto/paquetes SSIS y sus parámetros necesarios sin secretos. Incorporar después el backup dimensional validado y la presentación. Las capturas complementan a los archivos ejecutables; no los sustituyen.

Excluir `.vs`, `bin`, `obj`, `.user`, archivos temporales y contraseñas. Los paquetes y el proyecto deben usar `DontSaveSensitive`; configurar conexiones locales mediante autenticación integrada o parámetros externos apropiados. Si un archivo ya estaba versionado, agregarlo a .gitignore no lo retira por sí solo.

## Evidencia y comprensión
Después de ejecutar una consulta o paquete, guardar resultados pertinentes y documentar lo aprendido. En `docs/aportes.md` enlazar el commit/PR real y resumir qué puede explicar su autor. Ambos deben poder reconstruir y defender cualquier componente de la fase.
