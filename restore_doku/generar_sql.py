"""Arma los .sql listos para correr a partir de las plantillas y objetos.txt.

Uso (desde esta carpeta, en cualquier PC con Python 3):
    python generar_sql.py                 # usa objetos.txt
    python generar_sql.py otra_lista.txt  # otra lista, mismo formato

objetos.txt: TSV con fila de títulos "ID<TAB>OBJECT" (el mismo formato que
usa ZTRAD_DOKU_DEL). Deja 2_restore_doku.sql, 3_restore_dokclu.sql y
4_auditoria.sql en generado\\, con la lista cargada en tempdb..zdoku_list
(insert de a 500 filas por batch).
"""
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
PLANTILLAS = ["2_restore_doku.sql", "3_restore_dokclu.sql", "4_auditoria.sql"]
MARCA = "/* @@LISTA_OBJETOS@@ */"
LOTE = 500


def leer_lista(ruta):
    filas, vistos = [], set()
    with open(ruta, encoding="utf-8-sig") as f:
        for n, linea in enumerate(f, 1):
            linea = linea.rstrip("\r\n")
            if not linea.strip():
                continue
            partes = linea.split("\t")
            if len(partes) < 2:
                sys.exit(f"{ruta}:{n}: se esperaba ID<TAB>OBJECT")
            id_, obj = partes[0].strip(), partes[1].strip()
            if id_.upper() == "ID" and obj.upper() == "OBJECT":
                continue  # fila de títulos
            if len(id_) > 2 or len(obj) > 60:
                sys.exit(f"{ruta}:{n}: ID o OBJECT demasiado largo")
            if (id_, obj) in vistos:
                continue
            vistos.add((id_, obj))
            filas.append((id_, obj))
    if not filas:
        sys.exit(f"{ruta}: la lista está vacía")
    return filas


def bloque_inserts(filas):
    lineas = []
    for i, (id_, obj) in enumerate(filas, 1):
        id_q, obj_q = id_.replace("'", "''"), obj.replace("'", "''")
        lineas.append(f"insert tempdb..zdoku_list values ('{id_q}','{obj_q}')")
        if i % LOTE == 0 or i == len(filas):
            lineas.append("go")
    return "\r\n".join(lineas)


def main():
    lista = sys.argv[1] if len(sys.argv) > 1 else os.path.join(AQUI, "objetos.txt")
    filas = leer_lista(lista)
    salida = os.path.join(AQUI, "generado")
    os.makedirs(salida, exist_ok=True)
    inserts = bloque_inserts(filas)
    for nombre in PLANTILLAS:
        with open(os.path.join(AQUI, nombre), encoding="utf-8") as f:
            texto = f.read()
        if texto.count(MARCA) != 1:
            sys.exit(f"{nombre}: falta la marca {MARCA}")
        texto = texto.replace("\r\n", "\n").replace("\n", "\r\n")
        texto = texto.replace(MARCA, f"/* {len(filas)} objetos de {os.path.basename(lista)} */\r\n" + inserts)
        with open(os.path.join(salida, nombre), "w", encoding="utf-8", newline="") as f:
            f.write(texto)
        print(f"generado\\{nombre}")
    print(f"{len(filas)} objetos")


if __name__ == "__main__":
    main()
