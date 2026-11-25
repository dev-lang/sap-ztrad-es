# Revisión de Fable 5.2 antes del paso 2

Antes de borrar en real, se le pasó a Fable 5.2 (revisión independiente, sin acceso al SAP) el código de `ZTRAD_LANG_DEL`, los informes de test de los tres grupos, el piloto en DD30T y el resumen de los controles 4 a 10. Este archivo resume qué encontró y cómo se resolvió.

## Lo que verificó

- **Filas E y D:** el `DELETE (tab) FROM TABLE` usa las filas S originales con su clave completa. La copia con idioma `E` es solo para comparar. No puede borrar inglés ni alemán.
- **Mandante:** todo es Open SQL sin `CLIENT SPECIFIED`, así que solo toca el mandante de logon.
- **Comparación:** estructura completa contra E. Si dos claves colisionaran al concatenarse con `|`, la fila queda como "S distinto de E" y se conserva.
- **Re-ejecución:** es idempotente y deja un estado consistente si se corta a mitad.
- **Números:** en las 80 tablas se cumple S antes = borradas + S≠E + S sin E + original S (4.162.362 = 4.114.293 + 20.816 + 877 + 26.376). Coinciden con los controles 4 y 6 en todas, salvo RSMPTEXTS, que deja 295 filas más como S≠E (se conservan igual).
- **DD04T, 483 elementos:** ninguna fila es íntegramente español. 386 son inglés con campos en blanco y 97 son mezcla inglés/español, que es la firma del proyecto.

## Bloqueantes y cómo se resolvieron

| # | Hallazgo | Resolución |
|---|---|---|
| B1 | La protección de objetos con idioma original español solo miraba TADIR `PROG` y `SAPL` + `FUGR`. Quedaban afuera class pools, bases lógicas, programas generados sin TADIR y grupos de funciones con namespace (`/NS/SAPLX`) | `load_ml` ahora agrega todos los `TRDIR-NAME` con `RLOAD = 'S'` y arma bien el nombre con namespace. En el grupo 4 se borraron unas 130 filas menos que en el primer test |
| B2 | La lista de text pools nuestros tiene 717 claves, pero el test quitó 721 | El informe ahora escribe cada entrada quitada (`QUITA_LISTA`). La conciliación dio 717 de 717: la diferencia son 4 claves que aparecen dos veces en su pool (`ASTBKF01` R, `MW01VTOP` R, `MW03AI00` I 021 e I 022) |

## Menores aplicados

- En modo real verifica S después = S antes − borradas (`*** ATENCION` si no cierra).
- Registra errores de `INSERT TEXTPOOL` y `DELETE TEXTPOOL`.
- Escribe la lista de pools borrados enteros (`BORRA_POOL`) y muestras de lo que se conserva (`MUESTRA_QUEDA_DIF`).

## Veredicto por grupo y lo que pasó

| Grupo | Veredicto de Fable | Resultado |
|---|---|---|
| 1 Customizing | Seguir, aclarando 68 tablas | 19.780 borradas, quedan 4.133 (lo esperado) |
| 2 Diccionario + DTEL | Seguir | DD01T 536, DD02T 2.040, DD07T 1.831, DD04T 3.267 (lo esperado) |
| 3 T100 / TSTCT | Seguir | T100 1.577, TSTCT 1.869 (lo esperado) |
| 4 Pantallas y menús | Seguir con B1 resuelto | D020T 949, D021T 5.750, RSMPTEXTS 24.402 |
| 5 IMG | Seguir | CUS_IMGACT 1.249, TNODEIMGT 0 (lo esperado) |
| 6 Text pools | No seguir hasta B1, B2, decisión sobre pools mixtos, piloto y dump nuevo | Se cumplió todo: opción B, piloto de 29 programas, dump `BAS_20261124_paso2` antes |

Sugerencia de Fable para los pools mixtos (adoptada como opción B): en pools con al menos una entrada de SAP, quitar solo las entradas de la lista del proyecto.
