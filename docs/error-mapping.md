# Mapeo de errores HTTP

## Objetivo

Documentar cómo `ApiClient` interpreta las respuestas HTTP del servidor y las convierte en excepciones tipadas de la jerarquía `Failure`.

## Reglas de mapeo

| Respuesta HTTP | Failure generado |
|---|---|
| 404 | `NotFoundFailure` |
| 409 | `ConflictFailure` |
| 422 | `ValidationFailure` |
| 500–599 | `ServerFailure` |
| Cualquier otro código no exitoso | `UnexpectedFailure` |

## Errores de conexión

Las excepciones `http.ClientException` y `TimeoutException` se convierten en `NetworkFailure`.

## Respuestas exitosas

Las respuestas con códigos entre 200 y 300, inclusive, se consideran exitosas y se devuelve su contenido decodificado.

## Detalles de las respuestas

- Para errores HTTP se intenta extraer el mensaje `detail` del cuerpo JSON.
- Para respuestas 422 se extraen los nombres de los campos y sus mensajes de validación.
- Si el cuerpo no contiene JSON válido, el cliente utiliza valores alternativos para evitar errores de decodificación.