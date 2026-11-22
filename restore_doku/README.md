# restore_doku: recuperar documentación DOKU borrada, desde un dump de Sybase

Scripts para volver a copiar la documentación SE61/DOKU (ayuda F1) desde un dump viejo de la base, sin restaurar la base entera. Es lo que se usó el 22/11/2026 para recuperar 26.613 documentos borrados por `ZTRAD_DOKU_DEL` v1.

Con la misma base `BAS_OLD` cargada, también hay un [control de idiomas](#control-de-idiomas-en-y-de-contra-el-dump): verifica que los textos en inglés y alemán de todas las tablas que tocan los `ZTRAD_*` sigan iguales que en el dump.

Probado en SAP ECC 6.0 EHP6 (SAP_BASIS 731) sobre **Sybase ASE 15.7** en Windows, con SID `BAS` y owner de tablas `SAPSR3`.

## Qué pasó

- `ZTRAD_DOKU_DEL` v1 usaba el módulo de funciones `DOCU_DEL` con `LANGU = 'S'` para borrar solo la versión ES de la ayuda F1 traducida.
- `DOCU_DEL` **borra el documento en todos los idiomas**, sin importar el idioma que se le pase.
- El job 10163300 (22/11/2026 10:16) corrió sobre 26.613 documentos `DE` (elementos de datos) y borró E, D y S de todos.
- Se detectó en el export de control: los objetos ya ni figuraban como pendientes, y `ZTRAD_TABDUMP` sobre DOKHL/DOKIL daba 0 filas.
- Lo que lo permitió: se supuso sin verificar que `DOCU_DEL` respetaba el idioma, no hubo piloto con un documento solo, y la verificación del borrado miraba solo el idioma S.
- Se corrigió en `ZTRAD_DOKU_DEL` v2 (ver [README principal](../README.md#ztrad_doku_del)): borra solo las filas S de DOKHL/DOKIL/DOKTL y controla que los demás idiomas no cambien.

## Dónde está la documentación en la base

| Tabla | Qué guarda | Cómo se restaura |
|---|---|---|
| `DOKHL` | Cabecera por idioma/versión | Insert directo (paso 2) |
| `DOKIL` | Índice (líneas, estado, idioma maestro) | Insert directo (paso 2) |
| `DOKTL` | Líneas de texto | **Es una tabla cluster**: no existe en la base. Las filas físicas están en `DOKCLU` |
| `DOKCLU` | Cluster físico de DOKTL (clave `ID, OBJECT, LANGU, TYP, DOKVERSION, PAGENO`; texto comprimido en `VARDATA`, tipo IMAGE) | Insert directo (paso 3) |
| `DOKCL` | Otro cluster de documentación | No tenía filas para estos objetos |

## Archivos

| Archivo | Qué hace |
|---|---|
| `correr_sql.bat` | Corre un .sql con `isql` y deja `<archivo>.log` al lado. `isql` pide la contraseña (no se muestra ni se guarda). Ajustar las variables del principio |
| `0_headeronly.sql` | Solo lectura: qué contiene el dump y qué tamaño de data/log necesita |
| `1_cargar_dump.sql` | Crea dos devices y la base `BAS_OLD`, carga el dump ahí y la pone online. Al final, comentado, cómo borrarla |
| `2_restore_doku.sql` | Plantilla: copia DOKHL y DOKIL (solo `LANGU <> 'S'`, solo filas que falten) |
| `3_restore_dokclu.sql` | Plantilla: copia DOKCLU (las líneas de texto) y compara los totales de las tres tablas contra el dump |
| `4_auditoria.sql` | Plantilla, solo lectura: compara BAS contra el dump tabla por tabla y fila por fila |
| `objetos.txt` | Los 26.613 objetos `DE` restaurados (TSV `ID<TAB>OBJECT`, el mismo formato que usa `ZTRAD_DOKU_DEL`) |
| `generar_sql.py` | Completa las plantillas 2, 3 y 4 con la lista y deja los .sql listos en `generado\`. Con `--idiomas` arma el control de idiomas |
| `5_control_idiomas.sql` | Plantilla, solo lectura: control de idiomas EN y DE contra el dump |
| `tablas_idiomas.txt` | Las 84 tablas del control de idiomas (TSV `TABLA<TAB>ORIGEN`) |
| `reiniciar_sap_ase.bat` | Baja SAP, reinicia ASE y sube SAP. Si ASE no baja en 2 minutos, ofrece `shutdown with nowait`. Correr como administrador |
| `forzar_shutdown_ase.bat` | `shutdown with nowait` aparte (solo con SAP abajo) |

Las plantillas llevan la marca `/* @@LISTA_OBJETOS@@ */` donde va la carga de la lista en `tempdb..zdoku_list`. Los `.sql` generados (≈1,4 MB cada uno) y los `.log` no se suben (`.gitignore`).

## Requisitos

- Un dump de la base de **antes** del borrado. Acá: `C:\backup-SYB\BAS_20261118_211256.dmp` (18/11/2026), páginas de 16 KB.
- Espacio libre para una segunda base del tamaño del dump: data 90.112 MB + log 10.240 MB (≈100 GB) para este caso.
- `isql` de Sybase OCS. Necesita `%SYBASE%\OCS-15_0\dll` en el PATH (si no, falta `libsybcs.dll`); el bat lo agrega.
- Usuario `sapsa` (o uno con `sa_role`).
- Python 3 en cualquier PC, solo para `generar_sql.py`. Los .sql generados se pueden copiar al server.

## Procedimiento

Todo se corre con `correr_sql.bat <archivo.sql>` y después se revisa el log.

1. **Ver el dump:** `0_headeronly.sql`. Anotar el tamaño de data y log, y ajustar los tamaños y rutas de `1_cargar_dump.sql` si es otro dump.
2. **Cargar el dump en BAS_OLD:** `mkdir C:\backup-SYB\BAS_OLD` y correr `1_cargar_dump.sql`. **Nunca** hacer `load` sobre `BAS`.
3. **Generar los .sql:** `python generar_sql.py` (o `python generar_sql.py otra_lista.txt`).
4. **Cabeceras:** `generado\2_restore_doku.sql`.
5. **Líneas de texto:** `generado\3_restore_dokclu.sql`. Al final los totales `BAS ... no-S` tienen que ser iguales a los `DUMP ... no-S`.
6. **Auditoría:** `generado\4_auditoria.sql`. Todo lo de "distintas" y "de más en BAS" debe dar 0.
7. **Verificar desde SAP:** exportar la documentación con `ZTRAD_DOKU` y comparar contra un export anterior; mirar algunos documentos en SE61 en EN y DE. Ver también que no haya órdenes de transporte, versiones (VRSD) ni entradas TADIR nuevas desde antes del borrado.
8. **Limpiar:** borrar `BAS_OLD` con los comandos comentados al final de `1_cargar_dump.sql` y después los `.dat` a mano.

## Resultado del 22/11/2026

Restore (pasos 4 y 5):

| Tabla | Filas insertadas | Total no-S en BAS al final | Total no-S en el dump |
|---|---:|---:|---:|
| DOKHL | 68.923 | 68.929 | 68.929 |
| DOKIL | 53.173 | 53.179 | 53.179 |
| DOKCLU | 67.607 | 67.612 | 67.612 |

Idioma S en BAS para esos objetos: 0.

Auditoría (paso 6):
- DOKCL: 0 filas en BAS y en el dump.
- DOKHL y DOKIL: 0 filas distintas, 0 filas de más en BAS.
- DOKCLU: 0 filas distintas (clave + PAGELG + largo de VARDATA), 0 filas de más en BAS.
- La única diferencia con el dump son las 242 versiones ES de FD03, borradas a propósito.

Desde SAP (paso 7):
- Export `ZTRAD_DOKU` (job 12390700): 191.874 documentos. Los 26.613 restaurados coinciden línea por línea con los exports EN anteriores; los otros 165.261 no cambiaron.
- Sin órdenes de transporte, VRSD ni TADIR nuevos desde el 14/11.

## Control de idiomas EN y DE contra el dump

Compara, en cada tabla de `tablas_idiomas.txt`, las filas en inglés (E) y alemán (D) de BAS contra las de `BAS_OLD`. Las tablas son las 76 de texto que tocan `ZTRAD_TXTTAB` y `ZTRAD_MULTI`, más las que escriben LXE y `ZTRAD_TPOOL` (DD04T, D020T, REPOTEXT, CUS_IMGACT, TNODEIMGT) y la documentación entera (DOKHL, DOKIL, DOKCLU). Es solo lectura sobre BAS y BAS_OLD.

```
python generar_sql.py --idiomas
correr_sql.bat generado\5_control_idiomas.sql
```

Por tabla e idioma informa:

| Columna | Qué cuenta |
|---|---|
| `borradas` | Filas del dump cuya clave ya no está en BAS |
| `modificadas` | Misma clave en las dos bases, pero la fila no es idéntica |
| `nuevas` | Filas de BAS cuya clave no estaba en el dump |

Al final muestra hasta 20 claves de cada categoría. Lo importante es que `borradas` y `modificadas` den 0. Las `nuevas` aparecen por todo lo que se instaló después del dump.

- **Clave:** los campos clave de DD03L. DOKCLU no los tiene ahí y va con clave fija (`ID, OBJECT, LANGU, TYP, DOKVERSION, PAGENO`).
- **Columna de idioma:** se detecta sola.
- **No compara:**
  - El contenido de las columnas IMAGE/TEXT (ver las notas de Sybase); el largo se controla igual con `PAGELG` en DOKCLU y `DATALG` en REPOTEXT.
  - Las tablas pool (T003T y T004G no existen en la base).
  - Cambios en EN/DE anteriores a la fecha del dump.

### Resultado del 22/11/2026

Corrido contra el dump del 18/11, en dos partes (13:47 y 17:52–18:11) por el corte que se cuenta abajo. En total tardó unos 10 minutos.

- **Alemán:** 0 modificadas en las 84 tablas. 1 borrada: la cabecera de la pantalla 1000 de RDDPROTQ en D020T, que SAP vuelve a generar sola. 1 nueva: `/1BCDWB/DB/SSF/BTAB` en REPOTEXT, que es generada.
- **Inglés:** 0 borradas y 0 modificadas atribuibles a la traducción. Las diferencias:
  - **RTCCTOOL** en REPOTEXT, 1 modificada: la herramienta de ST-A/PI se actualiza sola.
  - Pantallas de selección regeneradas de programas de importación (RADBAT01, RDDGENBB, RDDMASGL, SAPRUPGM, ENH_*, RENHACTIVATION, RDDDISTY): 8 modificadas en D020T y 8 borradas en D021T (textos con clave `%_17…`, que se arma al generar la pantalla). Casi seguro se regeneraron al importar ST-A/PI.
  - **Nuevas:** todo ST-A/PI (`/SSA/*`, `/SSF/*`, `/1BCDWB/*`, transacciones ST12/ST13). Son RSMPTEXTS +6.070, D021T +3.064, D020T +399, REPOTEXT +190, DD07T +22, DD02T +8, TSTCT +4, DD01T +2, DD04T +2 y DOKHL/DOKIL/DOKCLU +1.

## Notas de Sybase que costaron errores

- `DECLARE CURSOR` tiene que estar solo en su batch. En la auditoría se reemplazó por un `while` sobre una tabla temporal.
- Las columnas IMAGE (como `DOKCLU.VARDATA`) no se pueden comparar en un `WHERE`. En `4_auditoria.sql` se compara `datalength()`, que con la lista de 26.613 objetos anduvo bien.
- **`datalength()` sobre IMAGE en una subconsulta correlacionada puede tirar abajo el proceso.** Pasó en REPOTEXT entera: excepción `0xc0000005` en `textsize`, con el stack trace en el errorlog de ASE. Por eso el control de idiomas no compara IMAGE.
- **Un proceso que cae así queda colgado.** Sigue en `sysprocesses` como `runnable` con sus locks, y `kill` no lo saca. Además el apagado normal de ASE lo espera para siempre: el errorlog repite "found active spid N". La salida es bajar SAP y hacer `shutdown with nowait` (`reiniciar_sap_ase.bat` lo ofrece; si no, `forzar_shutdown_ase.bat`). Al arrancar, ASE hace la recuperación normal.
- `net stop` del servicio de ASE espera sin límite si ASE no puede bajar. `reiniciar_sap_ase.bat` usa `sc stop` y controla el estado.
- `sc` muestra `NOMBRE_SERVICIO:` en Windows en español, en vez de `SERVICE_NAME:`.
- `DD03L.POSITION` es NUMC: en la base es texto. Asignarlo a un `int` da `Msg 257` y corta el batch entero.
- `convert(varchar, fecha, 120)` no existe en ASE 15.7 (`Msg 281`).
- tempdb mide 1 GB: no copiar tablas grandes ahí con `select into` + `create index`.
- `dump` es palabra reservada: no usarla como alias.
- Un `insert` en `DOKTL` falla porque no es una tabla física (es cluster). Se copia `DOKCLU`.
- Si `isql` da `Msg 4002 ... Login failed`, revisar usuario/servidor y que la contraseña se escriba en el prompt de `isql`, no en el bat.
