# Medición del acelerómetro para RN-11

Esta medición debe hacerse en cada teléfono físico del equipo. No se deben
reutilizar los valores de otro modelo ni sustituirlos por valores del emulador.

## Procedimiento

1. Abrir la app instalada en el teléfono y colocar la cámara trasera en la
   posición indicada, manteniendo el equipo quieto.
2. Registrar durante al menos 0.5 segundos las lecturas del acelerómetro en
   cada posición.
3. Anotar el promedio mostrado por la app y el modelo del teléfono.
4. Repetir cada posición tres veces para detectar lecturas inestables.

| Teléfono / modelo | Suelo: promedio (x, y, z) | Frente: promedio (x, y, z) | Arriba: promedio (x, y, z) | Ángulo suelo | Ángulo frente | Ángulo arriba | ¿Coincide RN-11? |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| Pendiente de medir | — | — | — | — | — | — | Pendiente |

## Criterio vigente

La inclinación de la cámara trasera se expresa en grados: `+90°` hacia el
suelo, `0°` al frente y `-90°` hacia arriba. RN-11 considera válida la
orientación hacia el suelo con `≥ +45°` y hacia arriba con `≤ -20°`.

Si el signo del eje o los ángulos observados en los teléfonos del equipo no
coinciden, actualizar esta tabla, RN-11 y los valores del servidor antes de
modificar la validación de la app.
