# Spec Kit en Docker

Worktree: `ai-dev-playground-speckit`, rama `speckit`.
Requisitos del host: Docker Engine, Docker Compose v2 y Bash.

## Construir y levantar

```bash
cd /home/pixeliko/w/lab/ai-dev-playground-speckit
export LOCAL_UID="$(id -u)" LOCAL_GID="$(id -g)"
docker compose build --pull --no-cache
docker compose up -d
docker compose exec -T specify specify --help
```

El Dockerfile instala `specify-cli` desde PyPI, el canal de instalación del
[proyecto oficial](https://github.com/github/spec-kit). Por defecto resuelve la
última versión estable durante el build. `--no-cache` es necesario al actualizar
para que Docker no reutilice la instalación anterior. Para fijar una versión:

```bash
SPECIFY_VERSION=1.0.7 docker compose build --no-cache
docker compose up -d
```

La imagen expone `specify` como entrypoint (`docker run --rm
speckit-specify:local --help`). Compose mantiene un contenedor activo mediante
`sleep infinity` y monta esta carpeta en `/workspace`. La CLI no necesita puertos.
Para detenerlo: `docker compose down`.

### Docker Desktop / WSL: gestor de credenciales incompatible

Si el build falla con `docker-credential-desktop.exe: exec format error` o con
`docker-credential-secretservice`, puedes construir esta imagen pública usando
una configuración temporal y un PATH de Linux:

```bash
mkdir -p /tmp/speckit-docker-config
printf '%s\n' '{}' > /tmp/speckit-docker-config/config.json
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  DOCKER_CONFIG=/tmp/speckit-docker-config docker compose build --pull --no-cache
```

## Usar desde el host y Codex

```bash
./.agents/skills/spec-lit-skill/scripts/specify --help
./.agents/skills/spec-lit-skill/scripts/specify init --help
```

El wrapper crea un contenedor temporal con la misma imagen, monta la carpeta
actual y conserva tu UID/GID. Funciona aunque el servicio permanente esté parado.
Para otra carpeta, ejecuta el script por su ruta absoluta desde allí, o establece
`SPECIFY_WORKSPACE=/ruta/al/proyecto`. Los archivos persisten en el host.

Para inicializar la carpeta destino con integración de Codex:

```bash
/home/pixeliko/w/lab/ai-dev-playground-speckit/.agents/skills/spec-lit-skill/scripts/specify init --here --integration codex --ignore-agent-tools --non-interactive
```

Se omite la detección de Codex porque se ejecuta en el host. Gestiona Git en el
host: los metadatos externos de los worktrees no se montan en el contenedor.
`specify check` solo comprueba las herramientas instaladas dentro de la imagen.

La skill se versiona en `.agents/skills/spec-lit-skill`, una ubicación de
[descubrimiento de skills de Codex](https://learn.chatgpt.com/docs/build-skills).
Abre Codex en este worktree e invócala con:

```text
$spec-lit-skill consulta la ayuda de specify
```

Si no aparece, reinicia la sesión en este directorio. La skill funciona desde
Codex en el host; no requiere instalar Python ni specify en el host.

## Wizard para la constitución

Abre [docs/constitution-wizard.html](docs/constitution-wizard.html) directamente
en tu navegador. Es un único HTML autocontenido que funciona sin conexión y guía
las preguntas de la [plantilla SMART + TCREI](docs/prompts/speckit-constitution.md).
Incluye progreso, guardado local, exportación e importación de respuestas,
descarga del prompt para `$speckit-constitution` y un borrador de `constitution.md`.
