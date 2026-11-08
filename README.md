# ZTRAD: traducción EN → ES de un SAP ECC sin paquete de idioma

Programas ABAP para traducir al español (idioma `S`) un sistema SAP ECC 6.0 que solo tiene el inglés como idioma completo. No hace falta tener el language pack oficial.

La idea es siempre la misma:

1. **Export:** cada programa vuelca a un archivo TSV (UTF-8) los textos que faltan traducir, es decir, los que en ES están vacíos o son iguales al EN.
2. **Traducción offline:** el archivo se traduce fuera de SAP, completando la columna `ES`.
3. **Import:** el mismo programa lee el archivo traducido y graba los textos en ES. Siempre se corre primero en **modo test** (`P_TEST = X`) y después la real.
4. **Invalidar cargas:** se borran las cargas de pantallas y de GUI en ES para que SAP las regenere con los textos nuevos.

Todos los programas se pueden usar de tres formas:

| Modo | Cómo | Para qué |
|---|---|---|
| **SAP GUI** | Pantalla de selección normal, archivo `P_FILE` en la PC (`GUI_UPLOAD`/`GUI_DOWNLOAD`) | Uso manual desde SE38 |
| **Servicio HTTP + `P_MEM`** | El servicio `ZCL_ZTRAD_HTTP` recibe el TSV en el cuerpo del POST, lo guarda en `INDX(ZT)` y corre el programa en fondo | Automatizar sin SAP GUI, lotes chicos |
| **Archivo en el servidor (`P_SRV`)** | El programa lee y escribe con `OPEN DATASET` debajo de una carpeta base (`c_base`) | Lotes grandes en fondo; lo más usado |

`P_MEM` y `P_SRV` son parámetros **ocultos** (`NO-DISPLAY`): no aparecen en la pantalla de selección y solo se usan desde el servicio o con `SUBMIT`. Si los dos están vacíos, el programa se comporta como siempre, con `P_FILE`.

Probado en **SAP ECC 6.0 EHP6** (SAP_BASIS 731, kernel 722, Unicode) sobre **Sybase ASE 15.7** y Windows. La sintaxis es compatible con 7.31: no usa expresiones de 7.40+.

---

## Contenido

| Archivo | Objeto en SAP | Qué hace |
|---|---|---|
| [`ztrad_lxe_final.abap`](#ztrad_lxe) | Report `ZTRAD_LXE` | Textos de objetos de repositorio vía la API de SE63 (LXE): transacciones, elementos de datos, mensajes, textos de programas, etc. |
| [`ztrad_txttab_final.abap`](#ztrad_txttab) | Report `ZTRAD_TXTTAB` | Tablas de texto: T100, IMG (`CUS_IMGACT`, `TNODEIMGT`), `TSTCT` y cualquier tabla genérica (D021T, DD01T, DD02T, DD07T, DD30T, RSMPTEXTS…) |
| [`ztrad_multi_final.abap`](#ztrad_multi) | Report `ZTRAD_MULTI` | Varias tablas de texto a la vez (todas las columnas de texto de cada tabla) |
| [`ztrad_tpool_final.abap`](#ztrad_tpool) | Report `ZTRAD_TPOOL` | Pools de textos de programas con `READ/INSERT TEXTPOOL`, para lo que LXE no cubre |
| [`ztrad_findtxt_final.abap`](#ztrad_findtxt) | Report `ZTRAD_FINDTXT` | Busca en qué objeto está guardado un texto que se ve en pantalla |
| [`ztrad_tabdump_final.abap`](#ztrad_tabdump) | Report `ZTRAD_TABDUMP` | Vuelca cualquier tabla a un TSV |
| [`ztrad_dynp_del_final.abap`](#ztrad_dynp_del) | Report `ZTRAD_DYNP_DEL` | Borra las cargas de textos de pantalla (`DYNPTXTLD`) de un idioma |
| [`ztrad_cua_del_final.abap`](#ztrad_cua_del) | Report `ZTRAD_CUA_DEL` | Borra las cargas de textos de GUI (menús, botones, títulos) |
| [`zcl_ztrad_http_final.abap`](#zcl_ztrad_http) | Clase `ZCL_ZTRAD_HTTP` + nodo SICF | Servicio HTTP para correr los `ZTRAD_*` en fondo sin SAP GUI |

---

## Instalación

1. **Reports:** en SE38 crear cada programa (tipo *1, programa ejecutable*, paquete `$TMP` o el que corresponda) y cargar el fuente con *Utilidades → Otras utilidades → Carga/descarga → Cargar*, o pegarlo. Activar.
2. **Clase:** en SE24 crear `ZCL_ZTRAD_HTTP` (pública, final) con la interfaz `IF_HTTP_EXTENSION` y pegar el fuente en el editor basado en código fuente. Activar.
3. **Servicio (opcional):** ver [ZCL_ZTRAD_HTTP](#zcl_ztrad_http).
4. **Carpeta base para `P_SRV`:** la constante `c_base` está fija en
   `C:\Users\user\Documents\ztrad_rfc_files\`. Hay que cambiarla en `ZTRAD_LXE`, `ZTRAD_TXTTAB`, `ZTRAD_MULTI`, `ZTRAD_TPOOL` y `ZTRAD_TABDUMP` si la carpeta es otra. Dentro conviene tener `rfcimport\` y `rfcexport\`. La cuenta de Windows con la que corre SAP necesita permiso de **modificar** en esa carpeta. `P_SRV` es una ruta **relativa** a `c_base` (máx. 45 caracteres); se rechazan `..`, `:` y rutas que empiezan con `\` o `/`.

> Los textos de selección (nombres de los parámetros en pantalla) no vienen en el fuente: se pueden cargar en SE38 → *Pasar a → Elementos de texto* si se quieren.

---

## Formato de archivo

TSV en **UTF-8 con BOM** y fin de línea **CRLF**. La primera línea es el encabezado y se ignora en el import.

**Formato A (LXE):**

```
OBJTYPE  OBJNAME   TEXTKEY          MAXLEN  EN                 ES
DTEL     SAPRL     SCRTEXT_S 00001  10      Release            Release
```

**Formato B (TXTTAB, MULTI, TPOOL):**

```
SRC    KEY                          MAXLEN  EN         ES
T100   F5|001                       73      Document   Documento
D021T  SAPLSHSY|0700|SHTEXT-AUS4    13      Database data   Datos BD
```

- En el export, la columna `ES` sale igual a `EN`: se reemplaza por la traducción.
- `MAXLEN` es el largo máximo del campo. El import rechaza (y cuenta como error) los textos más largos.
- Las filas con `ES` vacío o igual a `EN` se descartan en el import (salvo `ZTRAD_LXE` con `P_SAME`, y `ZTRAD_MULTI`, que las graba para crear la fila ES si falta).
- Hay que conservar los marcadores: `&`, `&1`…`&4`, `@..@` (iconos), espacios iniciales de columnas alineadas.

---

<a id="ztrad_lxe"></a>
## ZTRAD_LXE: objetos de repositorio vía SE63 (LXE)

Usa la API de traducción de SAP (`LXE_OBJ_TEXT_PAIR_READ` / `LXE_OBJ_TEXT_PAIR_WRITE`), la misma que usa SE63, con idioma origen `enUS` y destino `esES`.

**Tipos de objeto probados:** `TRAN` (transacciones), `DTEL` (elementos de datos: labels corto/medio/largo/encabezado y descripción), `MESS` (mensajes), `RPT4`, `SRT4`, `CA4`, `CA1`, `RPT1`, `SRT1` (textos de programas, pantallas, títulos).

**Parámetros:**

| Parámetro | Descripción |
|---|---|
| `P_TYPE` | Tipo de objeto LXE (obligatorio) |
| `S_NAME` | Objetos a procesar (rango, admite `*`) |
| `S_TAB` | Solo `DTEL`: toma los elementos de datos usados por estas tablas/estructuras |
| `P_MAX` | Máximo de objetos a leer (por defecto 500) |
| `P_PEND` | Exportar solo lo pendiente (ES vacío o igual a EN) |
| `R_EXP` / `R_IMP` | Export o import |
| `P_TEST` | Import en modo test (no graba) |
| `P_SAME` | Acepta filas con ES = EN (para restaurar o forzar textos iguales, p. ej. "Release") |
| `P_FILE` | Archivo en la PC (modo SAP GUI) |
| `P_MEM` / `P_SRV` | Ocultos, ver arriba |

**Detalles:**

- Graba el **registro completo** que leyó de LXE con los textos del archivo reemplazados. Las versiones anteriores a la v9 vaciaban en ES los textos que no venían en el archivo.
- Después del import invalida las cargas en ES: `DELETE FROM DYNPTXTLD WHERE LANGUAGE = 'S'` y `RS_CUA_DELETE_TEXT_LOAD`.
- Tiempos de referencia: lote de 20.000 filas `DTEL`, unos 35 s en test y 2,5 a 3 min en real.

**Historial:** v8 base; v9 graba el objeto completo y agrega `P_SAME`; v10 agrega `P_MEM`; v11 agrega `P_SRV` (versión `_final`).

---

<a id="ztrad_txttab"></a>
## ZTRAD_TXTTAB: tablas de texto

Exporta e importa tablas que SAP lee en tiempo de ejecución. Formato B.

**Fuente (radio):**

| Radio | Tabla | Clave en `KEY` |
|---|---|---|
| `R_T100` | `T100` (mensajes); filtro `S_CLS` (clase) | `ARBGB\|MSGNR` |
| `R_ACT` | `CUS_IMGACT` (actividades IMG) | clave de la tabla |
| `R_NODE` | `TNODEIMGT` (nodos IMG) | clave de la tabla |
| `R_TSTC` | `TSTCT` (textos de transacciones); filtro `S_TCD` | `TCODE` |
| `R_GEN` | **Cualquier tabla de texto**: `P_GTAB` tabla, `P_GFLD` campo de texto, `P_GLNG` campo de idioma (por defecto `SPRAS`) | campos clave (sin mandante ni idioma) separados por `\|` |

Ejemplos de `R_GEN` usados:

| Tabla | `P_GFLD` | `P_GLNG` | Qué es |
|---|---|---|---|
| `D021T` | `DTXT` | `LANG` | Textos de pantalla (dynpros) |
| `RSMPTEXTS` | `TEXT` | `SPRSL` | Textos de status GUI (menús, botones, títulos) |
| `DD01T` | `DDTEXT` | `DDLANGUAGE` | Descripciones de dominios |
| `DD02T` | `DDTEXT` | `DDLANGUAGE` | Descripciones de tablas y estructuras |
| `DD07T` | `DDTEXT` | `DDLANGUAGE` | Valores fijos de dominios |
| `DD30T` | `DDTEXT` | `DDLANGUAGE` | Ayudas para búsqueda |

**Import:** lee la fila EN por clave, toma la fila ES si ya existe (para no pisar otros campos), cambia el idioma y el texto y hace `MODIFY`. Descarta las filas con ES vacío o igual a EN (si hace falta forzar un texto igual al inglés, se pone en la columna `EN` el valor que tiene hoy en ES).

**Cuidado:** en `RSMPTEXTS` hay códigos de función que contienen `|` y rompen la clave; esas filas hay que sacarlas del lote.

**Historial:** v5 base con `R_GEN`; v6 agrega `P_MEM`; v7 agrega `P_SRV` (versión `_final`).

---

<a id="ztrad_multi"></a>
## ZTRAD_MULTI: varias tablas de texto a la vez

Para cada tabla de `S_TAB` (transparente, con un campo clave de tipo `LANG`) exporta **todas** las columnas `CHAR` no clave de largo ≥ `P_MINL` cuya fila ES falta, está vacía o es igual a la EN. Formato B con `SRC = TABLA-CAMPO`.

| Parámetro | Descripción |
|---|---|
| `S_TAB` | Tablas a procesar |
| `P_MINL` | Largo mínimo de columna para considerarla texto (por defecto 10) |
| `R_EXP` / `R_IMP`, `P_TEST`, `P_FILE` | Como siempre |
| `P_MEM` / `P_SRV` | Ocultos (agregados en `_final`) |

El import parte de la fila ES si existe y graba con `MODIFY` dinámico. A diferencia de TXTTAB, graba también las filas con ES = EN (sirve para crear la fila ES que falta).

---

<a id="ztrad_tpool"></a>
## ZTRAD_TPOOL: pools de textos de programas

Lee y escribe directamente con `READ TEXTPOOL` / `INSERT TEXTPOOL` (títulos, textos de selección, símbolos de texto). Sirve para lo que LXE no cubre: bases de datos lógicas `SAPDB*`, programas generados como `/1SDBF12L/*`, etc. Formato B con `SRC = programa` y `KEY = ID|clave`.

| Parámetro | Descripción |
|---|---|
| `S_PROG` | Programas |
| `S_TCOD` | Transacciones: agrega su programa (y el `REPORT=` de transacciones de parámetros) |
| `R_EXP` / `R_IMP`, `P_TEST`, `P_FILE` | Como siempre |
| `P_MEM` / `P_SRV` | Ocultos (agregados en `_final`) |

**Detalles:**

- En los textos de selección (`ID = S`) se saltean los 8 primeros caracteres de relleno, y los referenciados al diccionario (`D` en la primera posición) no se exportan.
- En el import completa el pool ES con las entradas EN que falten antes de grabar, para que el programa no quede con textos vacíos.

---

<a id="ztrad_findtxt"></a>
## ZTRAD_FINDTXT: dónde está guardado un texto

Busca un texto (con comodines a ambos lados) para saber qué objeto hay que traducir. Solo lectura; el resultado sale en la lista.

| Parámetro | Descripción |
|---|---|
| `P_TEXT` | Texto a buscar |
| `P_LANG` | Idioma en que se busca (por defecto `E`) |
| `S_PROG` | Programas para la búsqueda en pools (por defecto `SAPDB*`, `RSDB*`, `SAPLSSEL*`) |
| `P_POOL`, `P_DYNP`, `P_DTEL`, `P_MSG`, `P_GUI` | Dónde buscar: pools de textos, D021T, DD04T, T100, RSMPTEXTS |
| `P_MAX` | Máximo de resultados |

---

<a id="ztrad_tabdump"></a>
## ZTRAD_TABDUMP: volcado de una tabla a TSV

Vuelca cualquier tabla (`P_TAB`) con un `WHERE` opcional (`P_WHERE`, SQL abierto dinámico) a un TSV UTF-8 con encabezado de columnas. Útil para medir qué falta traducir o verificar un import (por ejemplo, `DD04T` con `DDLANGUAGE = 'S'`).

`P_MEM` / `P_SRV` agregados en `_final`.

---

<a id="ztrad_dynp_del"></a>
## ZTRAD_DYNP_DEL: borrar cargas de textos de pantalla

Después de importar textos de pantalla (D021T) o labels de elementos de datos, SAP sigue mostrando la carga vieja hasta que se regenera. Este programa borra las cargas de `DYNPTXTLD` de un idioma.

| Parámetro | Descripción |
|---|---|
| `P_PROG` | Programa (si no se marca `P_ALL`) |
| `P_LANG` | Idioma (por defecto `S`) |
| `P_ALL` | Todas las cargas del idioma |
| `P_TEST` | Solo cuenta |

`DB_DROP_DYNP_TEXT_LOADS` no funciona en Sybase, por eso usa SQL nativo (`EXEC SQL DELETE FROM DYNPTXTLD`).

---

<a id="ztrad_cua_del"></a>
## ZTRAD_CUA_DEL: borrar cargas de textos de GUI

Borra con `RS_CUA_DELETE_TEXT_LOAD` las cargas de textos de status GUI de los programas de `S_PROG` en el idioma `P_LANG` (por defecto `S`). Después, en las sesiones abiertas, `/$SYNC`.

> No conviene correrlo con `S_PROG = *` por el servicio: escribe una línea por programa y el spool resultante es enorme.

---

<a id="zcl_ztrad_http"></a>
## ZCL_ZTRAD_HTTP: servicio HTTP

Handler de ICF para correr los `ZTRAD_*` como **job de fondo** (`ZTRAD_HTTP`) sin SAP GUI.

**Endpoints:**

| Método y ruta | Qué hace |
|---|---|
| `GET /zztrad/ping` | Prueba de vida |
| `POST /zztrad/run?prog=ZTRAD_...&p_x=...&s_y=...` | Programa el job. `P_*` y `R_*` van como parámetros; `S_*` como select-options (con `*` o `+` usa `CP`, si no `EQ`; se pueden repetir). El cuerpo opcional (TSV UTF-8) se guarda en `INDX(ZT)` y se pasa como `P_MEM`. Devuelve `job`, `count`, `id` y `lines`. |
| `GET /zztrad/status?job=ZTRAD_HTTP&count=N` | Estado del job (`S`, `Y`, `R`, `F`, `A`…) y, al terminar, la lista del spool |
| `GET /zztrad/result?id=ZT...` | TSV exportado (cuando el programa escribió en `INDX(ZT)`) |
| `GET /zztrad/delete?id=ZT...` | Borra los datos de `INDX(ZT)` |

**Ejemplos:**

```text
# import de prueba de un lote que ya está en la carpeta base
/zztrad/run?prog=ZTRAD_LXE&p_type=DTEL&r_exp=&r_imp=X&p_test=X&p_srv=rfcimport\lote1.txt

# import genérico de DD02T (test)
/zztrad/run?prog=ZTRAD_TXTTAB&r_t100=&r_gen=X&p_gtab=DD02T&p_gfld=DDTEXT&p_glng=DDLANGUAGE&r_exp=&r_imp=X&p_test=X&p_srv=rfcimport\zdd02t_es1.txt

# export de lo pendiente en D021T
/zztrad/run?prog=ZTRAD_TXTTAB&r_t100=&r_gen=X&p_gtab=D021T&p_gfld=DTXT&p_glng=LANG&r_exp=X&r_imp=&p_srv=rfcexport\d021t_ex.txt

# borrar todas las cargas de pantalla en ES
/zztrad/run?prog=ZTRAD_DYNP_DEL&p_lang=S&p_all=X&p_test=
```

En los radiobuttons hay que mandar **los dos** del grupo (uno con `X` y el otro vacío) para que el valor por defecto no gane.

**Configuración:**

1. SICF: crear el servicio `/default_host/zztrad` con el handler `ZCL_ZTRAD_HTTP` y un usuario de servicio en *Datos de inicio de sesión* (necesita autorización para programar jobs y para lo que hagan los programas).
2. SMICM: puerto HTTP activo (en el sistema original, 8000) y un timeout acorde (600 s).
3. Activar el servicio.

**Seguridad:** solo acepta pedidos desde la misma máquina (`127.0.0.1` / `::1`) y solo programas que empiecen con `ZTRAD_` y existan en `TRDIR`. Pensado para un **sistema de laboratorio**: el usuario de servicio queda guardado en SICF, así que no conviene usarlo tal cual en sistemas productivos ni exponer el puerto.

---

## Flujo recomendado

1. **Medir** lo pendiente: export con `P_PEND` / `R_EXP` (o `ZTRAD_TABDUMP`).
2. **Traducir** el TSV offline respetando `MAXLEN` y los marcadores (`&`, `@..@`).
3. **Partir en lotes** de unas 20.000 filas.
4. Por cada lote: **import con `P_TEST = X`**, revisar errores, y recién ahí **import real**.
5. **Invalidar cargas:** `ZTRAD_DYNP_DEL` con `P_ALL` y, si se tocaron menús, `ZTRAD_CUA_DEL`.
6. **Verificar:** export de control (lo que queda pendiente debería ser solo lo que es igual en EN y ES), SE16N con idioma `ES`, y entrar en ES a una transacción representativa.

## Problemas conocidos

| Problema | Solución |
|---|---|
| `LXE_OBJ_TEXT_PAIR_WRITE` borra los textos que no se pasan | Desde la v9, ZTRAD_LXE escribe el objeto completo |
| `DB_DROP_DYNP_TEXT_LOADS` no funciona en Sybase | SQL nativo en ZTRAD_DYNP_DEL |
| Los textos nuevos no se ven | Invalidar `DYNPTXTLD` y las cargas CUA; `/$SYNC` |
| Popup "Seguridad SAP GUI" en cada lectura/escritura de archivo con `P_FILE` | Permitir, o usar `P_SRV` |
| `STRING_LENGTH_TOO_LARGE` al importar RSMPTEXTS | Filas con `\|` dentro del código de función: sacarlas del lote |
| En SE16N no aparece nada con idioma `S` | En SE16N el idioma va en formato externo: `ES` |
