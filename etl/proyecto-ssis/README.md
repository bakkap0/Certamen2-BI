# Proyecto inicial SSIS

Abrir `BikeZ_ETL.sln` en Visual Studio Community 2019 con SQL Server Integration Services Projects. La copia se preparó desde el proyecto local creado por Joaquín.

## Configuración preparada
- TargetServerVersion: SQLServer2019.
- ProtectionLevel del proyecto y paquete: DontSaveSensitive.
- Paquete de entrada: Package.dtsx.
- Sin conexiones, tareas, flujos ni parámetros sensibles.

Se excluyeron `.vs`, archivos `.user`, compilados y el verificador cifrado que dependía del usuario local. Se conservaron los identificadores del proyecto y del paquete.

## Estado y siguiente paso
El paquete está vacío: no extrae, transforma ni carga datos. La revisión realizada aquí fue de estructura XML y configuración; falta abrir y compilar esta copia en Visual Studio 2019.

Tras verificar el esquema y crear el DW, se incorporarán conexiones, tareas y flujos con sus reglas y validaciones. Cada integrante debe ajustar su servidor local; no asumir que el nombre de instancia de Joaquín existe en el otro equipo.
