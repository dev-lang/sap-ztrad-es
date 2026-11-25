#!/usr/bin/env python3
"""clasificar_s_vs_e.py - Control del paso 1.

Cruza la lista de claves S distintas de E (log de sql\\07_lista_s_vs_e.sql)
contra:
  - los lotes de importacion en espanol (lo que cargo el proyecto, solo filas
    con ES <> EN), y
  - los lotes de reversion zrev_* / zrev2_* (lo que el paso 1 intento pisar).

Clasifica cada clave como:
  sap                       no la cargo el proyecto (espanol de SAP)
  en_lote_rev_no_aplicado   la cargo el proyecto, estaba en la reversion y
                            sigue distinta (rechazos de LXE, etc.)
  NUESTRO_SIN_REVERTIR      la cargo el proyecto y la reversion no la incluia
  objeto_con_otras_claves_nuestras
                            el proyecto cargo otras claves del mismo objeto,
                            pero no esta (en el control resulto espanol de SAP)

Uso:
  python clasificar_s_vs_e.py --log7 07_lista_s_vs_e.log \\
         --importados DIR1 [DIR2 ...] --reversion DIR_REV1 [DIR_REV2 ...] \\
         [--salida clasif.json]
"""
import argparse, collections, glob, json, os, re

NO_IMPORT = r'z(rev2?|res|doku)_'


def norm(src, key):
    m = {'D021T-DTXT': 'D021T', 'DD30T-DDTEXT': 'DD30T', 'IMGACT': 'CUS_IMGACT'}
    return m.get(src, src), key.strip()


def load(files, solo_cambios):
    exact, dtel, objs = set(), set(), collections.defaultdict(set)
    for f in files:
        b = os.path.basename(f)
        if solo_cambios and re.match(NO_IMPORT, b):
            continue
        if b.endswith('_ex.txt'):
            continue
        with open(f, encoding='utf-8-sig', errors='replace') as h:
            hdr = h.readline()
            if not hdr.startswith(('SRC', 'OBJTYPE')):
                continue
            lxe = hdr.startswith('OBJTYPE')
            for l in h:
                p = l.rstrip('\r\n').split('\t')
                if len(p) < 3:
                    continue
                if solo_cambios and lxe and (len(p) < 6 or not p[5] or p[5] == p[4]):
                    continue
                if solo_cambios and not lxe and (len(p) < 5 or not p[4] or p[4] == p[3]):
                    continue
                if lxe:
                    t, o, k = p[0], p[1].strip(), p[2].split()
                    if t == 'DTEL' and k:
                        dtel.add((o, k[0]))
                    elif t == 'TRAN':
                        exact.add(('TSTCT', o))
                    elif t == 'MESS':
                        a = o.split()
                        exact.add(('T100', a[0] + '|' + (a[1] if len(a) > 1 else '')))
                    elif t in ('CA1', 'CA4'):
                        objs['RSMPTEXTS'].add(o)
                    elif t in ('SRT1', 'SRT4'):
                        objs['D02xT'].add(o.split()[0])
                else:
                    s, k = norm(p[0], p[1])
                    exact.add((s, k))
                    objs[s].add(k.split('|')[0])
    return exact, dtel, objs


def txt_files(dirs):
    out = []
    for d in dirs:
        out += glob.glob(os.path.join(d, 'z*.txt'))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--log7', required=True)
    ap.add_argument('--importados', nargs='+', required=True)
    ap.add_argument('--reversion', nargs='+', required=True)
    ap.add_argument('--salida')
    a = ap.parse_args()

    IE, ID, IO = load(txt_files(a.importados), solo_cambios=True)
    RE, RD, _ = load(txt_files(a.reversion), solo_cambios=False)

    res, ej = collections.Counter(), collections.defaultdict(list)
    with open(a.log7, encoding='latin-1') as fh:
        for l in fh:
            l = l.strip()
            if not l.startswith('#'):
                continue
            _, t, k, fl = l.split('#')[:4]
            fl = [x.strip() for x in fl.split(',') if x.strip()]
            if t == 'DD04T':
                r = k.split('|')[0]
                ours = [f for f in fl if (r, f) in ID]
                rev = [f for f in ours if (r, f) in RD]
                c = 'sap' if not ours else ('NUESTRO_SIN_REVERTIR' if len(rev) < len(ours)
                                            else 'en_lote_rev_no_aplicado')
            elif (t, k) in IE:
                c = 'en_lote_rev_no_aplicado' if (t, k) in RE else 'NUESTRO_SIN_REVERTIR'
            elif t == 'RSMPTEXTS' and k.split('|')[0] in IO['RSMPTEXTS']:
                c = 'objeto_con_otras_claves_nuestras'
            elif t in ('D020T', 'D021T') and k.split('|')[0] in IO['D02xT']:
                c = 'objeto_con_otras_claves_nuestras'
            else:
                c = 'sap'
            res[(t, c)] += 1
            ej[(t, c)].append(k + ' ' + ','.join(fl))
    for k, v in sorted(res.items()):
        print(k, v, ej[k][:3])
    if a.salida:
        with open(a.salida, 'w', encoding='utf-8') as fo:
            json.dump({f'{t}|{c}': v for (t, c), v in ej.items()}, fo, ensure_ascii=False)


if __name__ == '__main__':
    main()
