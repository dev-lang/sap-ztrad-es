# restore_es: revertir la traducción al español y quitar el español copiado

Scripts, programas y resultados de la reversión completa de la traducción ES del sistema `BAS`, hecha el 23 y 24/11/2026. Al final, el sistema quedó con el inglés original en todo lo que tocó el proyecto y sin las copias del inglés en idioma `S`. Lo único que sigue en español es español propio de SAP.

Probado en SAP ECC 6.0 EHP6 (SAP_BASIS 731) sobre **Sybase ASE 15.7** en Windows, SID `BAS`, mandante `001`, owner de tablas `SAPSR3`.

## Qué pasó

1. **11/10/2026:** se complementó el idioma `S` desde `E` con SMLT. Eso creó en español una copia exacta del inglés en las tablas de texto y en los text pools de todo el sistema (unas 4,3 M filas y 99.000 pools).
2. **Oct–nov 2026:** el proyecto ZTRAD tradujo parte de esas copias con los programas `ZTRAD_*` (ver el [README principal](../README.md)).
3. **22/11:** se borró la ayuda F1 traducida (ver [restore_doku](../restore_doku/README.md)).
4. **23/11:** se decidió volver atrás toda la traducción. El plan fue:
   - **Paso 1:** pisar con el inglés original todo lo que se cargó en español.
   - **Paso 2:** borrar las filas en español de las tablas tocadas, dejando solo el original.
   - **Paso 3 (manual, pendiente):** decidir con SMLT qué hacer con el idioma `S`.

## Dónde estaba el español

| Dónde | Qué había | Qué se hizo |
|---|---|---|
| 80 tablas de texto (T100, TSTCT, DD0xT, D02xT, RSMPTEXTS, IMG, customizing) | Copias del inglés (SMLT) y traducciones del proyecto | Paso 1 pisó las traducciones; paso 2 borró las copias |
| Text pools (REPOTEXT, comprimidos) | Copias del inglés en ~99.000 programas | Paso 2, grupo 6 |
| Cargas de pantalla y GUI (DYNPTXTLD, CUA) | Cargas generadas en S | `ZTRAD_DYNP_DEL` y `ZTRAD_CUA_DEL` |
| Documentación DOKHL | 7.760 docs en español **de SAP** (HR MX/ES, 2001–2011) | No se tocó |
| Objetos con idioma original español (TADIR `MASTERLANG = 'S'`, TRDIR `RLOAD = 'S'`) | Su texto S es el original | No se tocó |

## Archivos

| Archivo | Qué hace |
|---|---|
| `correr_sql.bat` | Corre un `.sql` con `isql` y deja `<archivo>.log` al lado. `isql` pide la contraseña (no se muestra ni se guarda). Ajustar las variables del principio |
| `comprimir_backups.bat` | Comprime con 7-Zip los dumps viejos sin comprimir de una carpeta del NAS, verifica y copia. No borra nada |
| [`sql/`](sql) | Controles (solo lectura) y dumps, del 01 al 15 |
| [`listas/`](listas) | Listas de entrada de `ZTRAD_LANG_DEL` y `ZTRAD_TPOOL_CHK` |
| [`scripts/`](scripts) | Python offline: lotes de reversión y análisis de los controles |
| [`resultados/`](resultados) | Informes de los programas (test, real y control posterior de cada grupo) y la revisión de Fable |
| [`../ztrad_lang_del_final.abap`](../ztrad_lang_del_final.abap) | Report `ZTRAD_LANG_DEL` (paso 2) |
| [`../ztrad_tpool_chk_final.abap`](../ztrad_tpool_chk_final.abap) | Report `ZTRAD_TPOOL_CHK`: compara text pools S contra E, solo lectura |

### sql/

| Script | Tipo | Qué hace |
|---|---|---|
| `01_inventario_es.sql` | Lectura | Filas S por tabla, comparadas contra `BAS_OLD` (dump del 18/11) |
| `02_doku_s.sql` | Lectura | Documentación DOKHL en español: de quién es y de cuándo |
| `03_jobs_11oct.sql` | Lectura | Jobs del 11/10 (el complemento SMLT) |
| `04_control_s_vs_e.sql` | Lectura | Control del paso 1: por tabla, filas S, S sin E y S distinto de E |
| `05_job_cua.sql` | Lectura | Estado del job de `ZTRAD_CUA_DEL` |
| `06_detalle_s_vs_e.sql` | Lectura | S distinto de E separado por objetos con original español, con ejemplos |
| `07_lista_s_vs_e.sql` | Lectura | Todas las claves S distintas de E, para cruzar offline |
| `08_dd04t_tocados.sql` | Lectura | Valores S y E de los elementos de datos tocados que siguen distintos |
| `09_textos_s_vs_e.sql` | Lectura | Texto S, E y D de cada fila distinta, para medir el idioma |
| `10_control_multi.sql` | Lectura | Igual que el 04 para las 68 tablas de customizing (claves desde DD03L) |
| `11_bases.sql` | Lectura | Qué bases hay en el servidor y cuál usa SAP |
| `12_dump_bas.sql` | Dump | Dump después del paso 1 |
| `13_dump_bas_paso2.sql` | Dump | Dump comprimido después de las 80 tablas |
| `14_opcionales.sql` | Lectura | `MENUJ4G2` (menú que quedó manual) y `DDFTX` |
| `15_dump_bas_final.sql` | Dump | Dump comprimido con el paso 2 completo |

Uso, desde la carpeta `restore_es`:

```
correr_sql.bat sql\04_control_s_vs_e.sql
```

## Paso 1: pisar con el inglés original

Los programas `ZTRAD_*` saben cargar textos, así que la reversión se hizo cargando **lotes con el inglés en la columna ES**, con los mismos programas (no por SQL directo).

1. `scripts/build_rev.py` recorre todos los lotes importados en español (las dos carpetas: `traduccion_SAP\import` y `ztrad_rfc_files\rfcimport`) y arma un plan con cada clave que se cargó con ES ≠ EN y su EN original.
2. `scripts/dd04_previo.py` detecta, en DD04T, campos donde el español previo a la traducción ya era de SAP, para no pisarlos.
3. `scripts/write_lots.py` escribe los lotes `zrev_*` (hasta 20.000 filas cada uno).
4. `scripts/build_rev2.py` junta lo que faltaba (lotes cargados por el servicio HTTP y las fases del 23/11) para la segunda tanda, `zrev2_*`.

**Truco de `ZTRAD_TXTTAB`:** descarta las filas con ES = EN. Por eso, en sus lotes, la columna EN lleva el **español actual** y la ES el inglés original.

| | Lotes | Filas en los lotes |
|---|---|---|
| `zrev_*` | 285 | 5.420.995 |
| `zrev2_*` | 11 | 24.750 |
| **Total** | **296** | **5.445.745** |

Se escribieron **5.445.196** filas. No se escribieron 549: 517 DTEL rechazados por LXE (375 clave no encontrada, 142 texto demasiado largo), 29 TPOOL sin fila ES, 2 RPT4 y la clave de `MENUJ4G2`, que tiene un `|` y quedó manual.

Los lotes no están en el repo (427 MB). Se regeneran con los scripts; `resultados/paso1_manifest_*.json` tiene la lista.

## Controles del paso 1

| Control | Resultado |
|---|---|
| `04` | Quedaban 36.943 filas S distintas de E en 11 de las 12 tablas de texto |
| `06` | ~20.400 de esas son de objetos con original español |
| `07` + `scripts/clasificar_s_vs_e.py` | Ninguna clave de T100, TSTCT, IMG, DD01T, DD02T, DD07T, DD30T, D020T, D021T ni RSMPTEXTS es del proyecto. En DD04T, 198 campos nuestros no se pudieron pisar (rechazos de LXE) |
| `08` | 429 campos de DD04T quedaron **en blanco** en S por nuestra importación |
| `09` + `scripts/medir_idioma.py` | De 49.562 campos distintos: ~44.000 español de SAP, ~2.350 alemán o inglés que SAP dejó marcado como S, ~2.150 siglas o textos truncados, 1.066 vacíos |
| `10` | Customizing: ninguna diferencia del mandante 001 es nuestra; las mismas filas aparecen en el 000 |
| `ZTRAD_TPOOL_CHK` | Text pools de los 37.819 programas tocados: 948.908 entradas iguales al inglés; de las 12.152 distintas, solo 11 son nuestras |

Conclusión: todo lo que sigue distinto entre S y E es de SAP, salvo 627 campos de DD04T (429 en blanco + 198 rechazados) y 718 entradas de text pools.

## Paso 2: borrar el español copiado

`ZTRAD_LANG_DEL` tiene tres grupos (uno por corrida) y corre en modo test por defecto.

| Grupo (`r_*`) | Qué borra | Qué no toca |
|---|---|---|
| `R_TAB` + `S_TAB` | Filas S **idénticas** a su fila E (todos los campos salvo el idioma) | Filas S distintas de E; filas S sin E; objetos con original español (TADIR `MASTERLANG`, TRDIR `RLOAD`); otros mandantes |
| `R_DTEL` + `P_DFILE` | La fila S entera de DD04T de los elementos de la lista | Elementos con original español |
| `R_TPL` + `P_PFILE` + `P_OFILE` | Pools S que son copia entera del inglés (`DELETE TEXTPOOL ... LANGUAGE 'S'`) y las entradas de la lista del proyecto | Con `P_TMODE = B`: en pools mixtos (con alguna entrada de SAP) solo quita las de la lista |

Controles que hace solo:
- cuenta filas E y D antes y después de cada tabla, y marca `*** ATENCION` si cambian;
- en real, verifica S después = S antes − borradas;
- trabaja por bloques de 200 valores del primer campo clave con `COMMIT` por bloque;
- en tablas pool o cluster no usa `SELECT DISTINCT`.

Orden seguido: dump, piloto real en DD30T, revisión de [Fable 5.2](resultados/revision_fable.md), y después cada grupo con test, real, test de nuevo (tiene que dar 0) y chequeo en SAP GUI con logon EN y `/$SYNC`.

| Grupo | S antes | Borradas | S después |
|---|---|---|---|
| 0 Piloto DD30T | 17.688 | 17.574 | 114 |
| 1 Customizing (68 tablas) | 23.913 | 19.780 | 4.133 |
| 2 DD01T / DD02T / DD07T | 622.385 | 617.978 | 4.407 |
| 2 DD04T + 483 elementos (`R_DTEL`) | 398.932 | 395.182 + 483 | 3.267 |
| 3 T100 / TSTCT | 648.990 | 645.544 | 3.446 |
| 4 D020T / D021T / RSMPTEXTS | 2.370.568 | 2.339.467 | 31.101 |
| 5 CUS_IMGACT / TNODEIMGT | 79.886 | 78.637 | 1.249 |
| 6 Text pools (opción B) | 98.998 pools | 95.669 pools, 1.421.694 entradas | 3.329 pools |

E y D no cambiaron en ninguna tabla. ST22 sin dumps de las corridas reales.

## Qué quedó en español y por qué

- **Español de SAP distinto del inglés:** unas 21.700 filas (localizaciones HR MX/ES/AR, IMG, customizing de ejemplo).
- **Objetos con idioma original español:** unas 27.000 filas y 1.728 text pools.
- **Filas S sin fila E:** unas 440.
- **Pools mixtos de SAP:** 1.597 (opción B: solo se quitaron las entradas del proyecto).
- **Mandante 000 y tablas fuera de alcance** (DD03T, DD08T, DDFTX, etc.): copias del complemento del 11/10, para el paso 3.

## Backups

| Dump | Estado |
|---|---|
| `BAS_20261118_211256.dmp` | 18/11, a mitad de la traducción (también cargado como base `BAS_OLD`) |
| `BAS_20261124_final.dmp` | Paso 2 completo (comprimido, 19,9 GB) |

Los intermedios (`BAS_20261123_190644`, `paso1`, `paso2`) se descartaron: todo lo borrado eran copias del inglés y se puede regenerar con un complemento SMLT, y la traducción está en los lotes de las carpetas `traduccion_SAP` y `ztrad_rfc_files`.

## Lecciones

- **Piloto antes de cada grupo** y test de nuevo después: con el mismo programa, el segundo test tiene que dar 0.
- **Logon en EN para revisar:** al borrar las copias, en logon ES las pantallas quedan vacías (es lo esperado).
- **Tablas pool o cluster:** `SELECT DISTINCT` da `SAPSQL_ILLEGAL_DISTINCT`.
- **Comparar contra los controles** cada número que da el programa antes de pasar a real.
- **Una segunda revisión independiente** (Fable) encontró dos huecos reales: la protección de programas con original español y la lista de text pools.

## Pendiente

- **Paso 3:** decidir con SMLT qué hacer con el idioma `S` (lo hace el administrador a mano).
