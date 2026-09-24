# Plantilla de prompt para `speckit-constitution`

Investigación: 2026-09-17. Adaptada a la skill instalada de Spec Kit 1.0.7.

## Fundamento y fuentes

TCREI organiza la petición en **Task, Context, References, Evaluate, Iterate**:
definir tarea y formato, aportar contexto y referencias, evaluar la respuesta y
refinarla. Véase la [guía de Google, página 2](https://storage.googleapis.com/grow-with-goog-publish-prod-media/documents/EN_Demo_guide_-_Practical_AI_for_your_Business.pdf).

SMART permite describir objetivos **específicos, medibles, alcanzables, relevantes
y acotados en el tiempo**. La [guía del CDC](https://www.cdc.gov/training-development/php/about/design-training-learning-objectives.html)
recomienda resultados observables y verificables acordes con los recursos disponibles.

Spec Kit utiliza la constitución para establecer o actualizar principios del
proyecto dentro de su [flujo de trabajo](https://github.github.com/spec-kit/reference/agentic-sdd.html).
La implementación local está descrita en
[speckit-constitution](../../.agents/skills/speckit-constitution/SKILL.md): exige
principios comprobables, gobernanza, versionado, fechas y un informe de impacto;
su alcance se limita a la constitución.

**Adaptación propuesta:** usar TCREI para organizar el prompt y SMART para comprobar
la concreción de sus reglas. Los principios son duraderos: el componente temporal
puede indicar cuándo se verifica una regla (por ejemplo, antes de integrar un cambio).
Las fechas de entrega y objetivos temporales de funcionalidades pertenecen a sus
especificaciones. Esta combinación es una propuesta práctica, no un framework
oficial de Spec Kit ni una garantía de calidad.

## Cómo reutilizarla

1. Copia el bloque siguiente y sustituye los campos `{{...}}`.
2. Repite la ficha de principio para cada regla que quieras adoptar. Elimina campos
   opcionales innecesarios; escribe «desconocido» cuando falte información.
3. Pégalo en el agente desde la raíz del proyecto. `$speckit-constitution` invoca
   una skill; no es un subcomando de la CLI `specify`.
4. Revisa las reglas y sus costes reales. Usa el prompt de iteración al final para
   corregir el resultado con criterios concretos.

## Prompt rellenable

```text
$speckit-constitution

T — TAREA Y RESULTADO

Crea o actualiza la constitución de {{NOMBRE_DEL_PROYECTO}} en
.specify/memory/constitution.md. Actúa como responsable de ingeniería que
transforma decisiones del equipo en reglas claras y verificables.

Operación: {{CREAR / ACTUALIZAR}}.
Idioma del contenido: {{IDIOMA}}; conserva la jerarquía de encabezados de la
plantilla activa que resuelva la skill.
Número de principios: {{NÚMERO / LOS NECESARIOS SIN DUPLICIDADES}}.

Limita el trabajo al flujo de constitución indicado por la skill instalada.
No implementes funcionalidades ni ejecutes fases posteriores. Si encuentras
peticiones de producto, recógelas como intenciones pendientes y sugiere la
skill apropiada sin ejecutarla.

C — CONTEXTO Y DECISIONES

- Propósito del proyecto: {{QUÉ PROBLEMA RESUELVE Y PARA QUIÉN}}.
- Alcance: {{QUÉ SISTEMAS O PARTES QUEDAN SUJETOS A ESTAS REGLAS}}.
- Etapa: {{EXPERIMENTO / MVP / PRODUCCIÓN / OTRA}}.
- Equipo y recursos: {{PERSONAS, TIEMPO, PRESUPUESTO Y CAPACIDAD DE MANTENIMIENTO}}.
- Restricciones acordadas: {{ENTORNO, TECNOLOGÍAS, DATOS, COMPATIBILIDAD, ETC.}}.
- Riesgos prioritarios: {{RIESGOS CONCRETOS QUE JUSTIFICAN LAS REGLAS}}.
- Prioridad ante conflictos: {{ORDEN DE PRIORIDADES Y QUIÉN RESUELVE CONFLICTOS}}.
- Prácticas actuales verificadas: {{PRÁCTICAS Y EVIDENCIA / DESCONOCIDO}}.
- Cambios que queremos adoptar: {{DECISIONES EXPLÍCITAS DEL EQUIPO}}.
- Fuera del alcance de esta constitución: {{EXCLUSIONES}}.

No conviertas ejemplos de la plantilla en obligaciones por defecto. No deduzcas
la arquitectura del producto a partir de la infraestructura de herramientas.
No inventes umbrales, herramientas, fechas ni decisiones del equipo.

PRINCIPIOS PROPUESTOS — REPETIR ESTA FICHA

- Nombre: {{NOMBRE BREVE}}.
- Regla específica: {{QUIÉN DEBE HACER QUÉ Y EN QUÉ SITUACIÓN}}.
- Nivel: {{DEBE / NO DEBE / DEBERÍA CON JUSTIFICACIÓN}}.
- Verificación: {{PRUEBA, COMANDO, REVISIÓN O EVIDENCIA OBSERVABLE}}.
- Criterio de cumplimiento: {{RESULTADO ESPERADO O UMBRAL JUSTIFICADO}}.
- Viabilidad: {{RECURSOS DISPONIBLES Y COSTE ACEPTABLE}}.
- Relevancia: {{RIESGO O NECESIDAD QUE RESUELVE}}.
- Momento de control: {{ANTES DE INTEGRAR / ANTES DE PUBLICAR / OTRO}}.
- Responsable de comprobarlo: {{ROL O PERSONA}}.
- Excepciones: {{NINGUNA / CONDICIONES, RESPONSABLE Y VIGENCIA}}.

GOBERNANZA Y FLUJO DE TRABAJO

- Controles obligatorios y cuándo se aplican: {{CONTROLES PROPORCIONADOS AL RIESGO}}.
- Quién puede proponer y aprobar enmiendas: {{RESPONSABLES}}.
- Procedimiento de enmienda: {{PROPUESTA, JUSTIFICACIÓN, REVISIÓN Y APROBACIÓN}}.
- Gestión de excepciones: {{REGISTRO, AUTORIZACIÓN Y REVISIÓN O CADUCIDAD}}.
- Revisión de cumplimiento: {{MOMENTO, RESPONSABLE Y EVIDENCIA}}.
- Revisión periódica de la constitución, si aplica: {{CADENCIA / NO APLICA}}.
- Fecha de ratificación original: {{YYYY-MM-DD / DESCONOCIDA}}.
- Versión actual, si existe: {{VERSIÓN / TODAVÍA NO RATIFICADA}}.

Aplica el versionado semántico de la skill y justifica la versión resultante.
No cambies la fecha de ratificación original al enmendar; usa la fecha actual
para la última enmienda si hay cambios. Si falta un dato crítico que no puedas
derivar con fiabilidad, pregunta o registra un TODO explícito según la skill.

R — REFERENCIAS Y EVIDENCIA

Consulta la skill instalada, resuelve la plantilla activa y lee la constitución
existente. Conserva las decisiones anteriores que sigan siendo aplicables.
Usa además:

- {{RUTA AL README O DOCUMENTO DE CONTEXTO}}.
- {{RUTA A DECISIONES DE ARQUITECTURA O ACUERDOS, SI EXISTEN}}.
- {{OTRAS RUTAS O ENLACES PERTINENTES / NINGUNO}}.

Distingue evidencia del repositorio, decisiones proporcionadas y propuestas.
Si los acuerdos aportados contradicen la constitución vigente, identifica la
enmienda necesaria. Si las referencias discrepan y no hay una decisión explícita,
pregunta antes de elegir una regla de gobierno.

E — EVALUACIÓN ANTES DE TERMINAR

Comprueba y corrige el documento con estos criterios:

1. Cada principio define una obligación concreta y su ámbito de aplicación.
2. Cada obligación puede verificarse con evidencia y un criterio de cumplimiento.
3. Su coste es compatible con los recursos declarados; no incorpora porcentajes
   o métricas arbitrarias ni controles que nadie puede ejecutar.
4. Cada regla tiene una razón vinculada al propósito o a un riesgo del proyecto.
5. Está claro cuándo se comprueba y quién responde por ella.
6. No hay reglas contradictorias, duplicadas ni frases como «alta calidad»
   sin una definición operativa.
7. La gobernanza explica enmiendas, excepciones, versión y revisión de cumplimiento.
8. No quedan marcadores sin explicar; cualquier dato pendiente tiene un TODO
   visible y aparece en el informe de impacto. Las fechas usan YYYY-MM-DD.
9. La versión coincide con el informe de impacto y los cambios realizados.
10. El contenido es gobierno del proyecto; no sustituye una especificación de feature.

I — ITERACIÓN Y ENTREGA

Si falta información que cambiaría una obligación o su viabilidad, formula solo
las preguntas necesarias antes de decidirla. Para datos no críticos, conserva
lo conocido y registra pendientes explícitos; no rellenes huecos inventando acuerdos.

Antes de finalizar, corrige los incumplimientos detectados en la evaluación.
Guarda la constitución siguiendo la skill, con su Sync Impact Report en un
comentario HTML. Indica que ese informe es temporal y debe retirarse antes del commit.

Entrega un resumen breve con ruta, versión y justificación, cambios principales,
TODOs o decisiones pendientes, y mensaje de commit sugerido. No crees el commit.
Incluye Next Actions únicamente si existen intenciones ajenas a la constitución.
```

## Ejemplo de ficha concreta

Ejemplo ilustrativo; úsalo solo si refleja una decisión real del equipo:

```text
- Nombre: Compatibilidad de contratos públicos.
- Regla específica: Todo cambio de una interfaz pública DEBE documentar su
  impacto en los consumidores; los cambios incompatibles DEBEN incluir una
  guía de migración antes de publicarse.
- Nivel: DEBE.
- Verificación: Revisión del diff de la interfaz y de la documentación de cambios.
- Criterio de cumplimiento: El impacto está descrito; si hay incompatibilidad,
  la guía explica los cambios necesarios para consumidores afectados.
- Viabilidad: El autor documenta el impacto y el mantenedor lo revisa.
- Relevancia: Evita que los consumidores descubran incompatibilidades sin aviso.
- Momento de control: Antes de publicar la versión afectada.
- Responsable de comprobarlo: Mantenedor que publica la versión.
- Excepciones: Ninguna para interfaces declaradas públicas.
```

## Prompt para una segunda iteración

```text
$speckit-constitution

Actualiza únicamente los puntos siguientes de la constitución existente:
{{CAMBIOS CONCRETOS Y SU JUSTIFICACIÓN}}.

La evaluación anterior detectó: {{REGLAS AMBIGUAS, COSTES O CONTRADICCIONES}}.
Las decisiones acordadas para resolverlo son: {{DECISIONES Y EVIDENCIA}}.

Conserva las demás reglas aplicables, repite la validación de la skill y ajusta
la versión según el impacto real. Resume qué cambió y qué sigue pendiente.
```
