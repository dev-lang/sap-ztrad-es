#!/usr/bin/env python3
"""build_rev.py - Paso 1, etapa 1: arma el plan de reversion (ES -> EN original).

Lee todos los lotes de importacion en espanol (los que se cargaron con los
programas ZTRAD_*) y, para cada clave que se cargo con un ES distinto del EN,
guarda el EN original. El EN sale de la columna EN de los propios lotes; para
D021T se toma del volcado completo en ingles (zd021t_e.txt) porque es exacto.

Formatos de lote reconocidos (TSV con BOM, primera linea = cabecera):
  OBJTYPE OBJNAME TEXTKEY MAXLEN EN ES   -> ZTRAD_LXE
  SRC KEY MAXLEN EN ES                    -> ZTRAD_TXTTAB / ZTRAD_MULTI / ZTRAD_TPOOL

Uso:
  python build_rev.py --lotes DIR_LOTES --export DIR_EXPORT --plan plan.json

  DIR_LOTES   carpeta con los z*.txt importados (en orden de carga por fecha)
  DIR_EXPORT  carpeta export de traduccion_SAP (necesita zd021t_e.txt)
"""
import argparse, collections, glob, json, os, re

TXT = {'T100', 'D021T', 'DD01T', 'DD02T', 'DD07T', 'DD30T', 'IMGACT', 'IMGNODE', 'TSTCT', 'RSMPTEXTS',
       'T003T', 'T004G', 'TCURT', 'TAMLAY1T', 'TAMLAYBT'}
# Lotes de correccion: su EN solo se usa si no hay otro
FIX = re.compile(r'fix|corr|term|_rev_|release|schedule|obsolete|fb03b|_to_es|test|_ex\.txt$')
# Archivos que no son lotes de importacion en espanol
SKIPF = re.compile(r'^z(rev_|doku|test_srv|trad_progs|trad_tabs|trad_tcodes)')


def rows(f):
    with open(f, encoding='utf-8-sig', errors='strict') as fh:
        for i, l in enumerate(fh):
            if i == 0:
                continue
            c = l.rstrip('\r\n').split('\t')
            if len(c) >= 5:
                yield c


def dump(f):
    with open(f, encoding='utf-8-sig') as it:
        h = next(it).rstrip('\r\n').split('\t')
        for l in it:
            yield dict(zip(h, l.rstrip('\r\n').split('\t')))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--lotes', required=True)
    ap.add_argument('--export', required=True)
    ap.add_argument('--plan', required=True, help='plan.json de salida')
    a = ap.parse_args()

    files = sorted(glob.glob(os.path.join(a.lotes, 'z*.txt')), key=os.path.getmtime)
    lxe_en, lxe_keys, lxe_es, lxe_fb = {}, {}, {}, {}
    tx_en, tx_keys, tx_es = {}, {}, {}
    stat = collections.Counter()
    for f in files:
        b = os.path.basename(f)
        if SKIPF.match(b):
            continue
        isfix = bool(FIX.search(b))
        with open(f, encoding='utf-8-sig') as fh:
            head = fh.readline().strip().split('\t')
        if head[:2] == ['OBJTYPE', 'OBJNAME']:
            for c in rows(f):
                if len(c) < 6:
                    continue
                k = (c[0], c[1], c[2])
                if c[5] and c[5] != c[4] and not b.endswith('_ex.txt'):
                    lxe_keys[k] = c[3]
                    lxe_es[k] = c[5]
                if c[4] and 'fb03b' not in b:
                    (lxe_fb if isfix else lxe_en).setdefault(k, c[4])
        elif head[:2] == ['SRC', 'KEY']:
            for c in rows(f):
                src, key, ml, en = c[0], c[1], c[2], c[3]
                es = c[4] if len(c) > 4 else ''
                if src in TXT:
                    tool = 'TXT'
                elif '-' in src:
                    tool = 'MULTI'
                elif re.match(r'^[IRSH]\|', key):
                    tool = 'TPOOL'
                else:
                    stat['?' + b] += 1
                    continue
                k = (tool, src, key)
                if es and es != en and not b.endswith('_ex.txt'):
                    tx_keys[k] = ml
                    tx_es[k] = es
                if not isfix:
                    tx_en.setdefault(k, en)

    # EN exacto de D021T desde el volcado completo
    d021 = {'|'.join((c['PROG'], c['DYNR'], c['FLDN'])): c['DTXT']
            for c in dump(os.path.join(a.export, 'zd021t_e.txt'))}
    for k in list(tx_keys):
        if k[0] == 'TXT' and k[1] == 'D021T' and k[2] in d021:
            tx_en[k] = d021[k[2]]
        if k[0] == 'MULTI' and k[1] == 'D021T-DTXT' and k[2] in d021:
            tx_en[k] = d021[k[2]]
    for k in lxe_keys:
        if k not in lxe_en and k in lxe_fb:
            lxe_en[k] = lxe_fb[k]

    miss_l = [k for k in lxe_keys if k not in lxe_en]
    miss_t = [k for k in tx_keys if k not in tx_en]
    print('LXE claves', len(lxe_keys), 'sin EN', len(miss_l), miss_l[:5])
    print('TXT/MULTI/TPOOL claves', len(tx_keys), 'sin EN', len(miss_t), miss_t[:8])
    if stat:
        print('filas sin herramienta reconocida:', dict(stat))
    with open(a.plan, 'w', encoding='utf-8') as fo:
        json.dump({'lxe': [[*k, lxe_keys[k], lxe_en.get(k, ''), lxe_es[k]] for k in lxe_keys],
                   'tx': [[*k, tx_keys[k], tx_en.get(k, ''), tx_es[k]] for k in tx_keys]},
                  fo, ensure_ascii=False)
    print(collections.Counter(k[0] for k in lxe_keys))
    print(collections.Counter((k[0], k[1] if k[0] == 'TXT' else '') for k in tx_keys))


if __name__ == '__main__':
    main()
