---
name: spec-lit-skill
description: Ejecuta la CLI specify de GitHub Spec Kit dentro de Docker desde Codex en el host para inicializar proyectos, consultar su estado y gestionar sus integraciones y extensiones.
---

# Spec Kit en Docker

Usa `scripts/specify` relativo a esta skill como sustituto del comando `specify`.
El script conserva los argumentos y el código de salida, monta el directorio
actual en `/workspace` y ejecuta con el UID/GID del usuario. Usa la ruta absoluta
al script cuando trabajes en otro directorio; `SPECIFY_WORKSPACE` permite elegir
otra carpeta existente. Las rutas que recibe specify son relativas a esa carpeta
o rutas internas del contenedor, no rutas absolutas del host.

La imagen se construye desde la raíz del proyecto que contiene esta skill:

```bash
docker compose build --pull --no-cache
```

Consulta primero la ayuda de la versión instalada:

```bash
<skill-dir>/scripts/specify --help
<skill-dir>/scripts/specify init --help
```

Para inicializar un proyecto para Codex, ejecuta desde la carpeta destino:

```bash
<skill-dir>/scripts/specify init --here --integration codex --ignore-agent-tools --non-interactive
```

Codex corre en el host: omite su detección dentro del contenedor con
`--ignore-agent-tools`. Gestiona Git desde el host y no instales la extensión `git` para operar sobre
un worktree cuyo `.git` apunta fuera del montaje. La versión 1.0.7 no ofrece
`--no-git`; la inicialización básica no necesita la extensión Git. No añadas `--force` automáticamente al encontrar archivos existentes;
comprueba primero qué archivos se van a reemplazar y el alcance solicitado.

`specify check` inspecciona herramientas del contenedor, no las del host.
Los comandos o skills `speckit-*` generados son instrucciones para el agente:
léelos y ejecútalos en Codex según lo que solicite el usuario; no los pases como
subcomandos de la CLI. No ejecutes fases posteriores sin que formen parte de la
tarea solicitada.

La CLI puede usarse sin arrancar el servicio permanente. Para mantenerlo activo,
ejecuta `docker compose up -d` en la raíz y usa
`docker compose exec -T specify specify --help`. Para actualizar, reconstruye
con `--pull --no-cache` y recrea el servicio con `docker compose up -d`.
