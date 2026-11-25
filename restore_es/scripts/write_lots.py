#!/usr/bin/env python3
"""write_lots.py - Paso 1, etapa 3: escribe los lotes de reversion zrev_*.

Toma el plan (build_rev.py) y el ES previo de DD04T (dd04_previo.py) y arma
lotes de hasta 20.000 filas para cada programa ZTRAD_*:

  zrev_lxe_<tipo>_N.txt    ZTRAD_LXE    (EN = texto actual, ES = EN original)
  zrev_txt_<tabla>_N.txt   ZTRAD_TXTTAB (EN = ES actual, ES = EN original:
                                         TXTTAB descarta filas con ES = EN)
  zrev_multi_x_N.txt       ZTRAD_MULTI  (incluye T003T/T004G/TCURT/TAMLAY*
                                         con todos sus campos desde el volcado E)
  zrev_tpool_x_N.txt       ZTRAD_TPOOL

Necesita en DIR_EXPORT: zdd04t_e.txt; en DIR_RFCEXPORT: t100_ex.txt y
zrev_dd_<tabla>.txt para las tablas chicas (volcados E con ZTRAD_TABDUMP).

Uso:
  python write_lots.py --plan plan.json --dd04-previo dd04_pre.json \\
         --export DIR_EXPORT --rfcexport DIR_RFCEXPORT --salida DIR_LOTES_REV
"""
import argparse, collections, json, os

MAX = 20000
SMALL = {'T003T': ['LTEXT'], 'T004G': ['FSTTX'], 'TCURT': ['KTEXT', 'LTEXT'],
         'TAMLAY1T': ['TEXT'], 'TAMLAYBT': ['TEXT']}
HEAD = {'LXE': 'OBJTYPE\tOBJNAME\tTEXTKEY\tMAXLEN\tEN\tES', 'TXT': 'SRC\tKEY\tMAXLEN\tEN\tES',
        'MULTI': 'SRC\tKEY\tMAXLEN\tEN\tES', 'TPOOL': 'SRC\tKEY\tMAXLEN\tEN\tES'}


def dump(f):
    with open(f, encoding='utf-8-sig') as it:
        h = next(it).rstrip('\r\n').split('\t')
        for l in it:
            yield dict(zip(h, l.rstrip('\r\n').split('\t')))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--plan', required=True)
    ap.add_argument('--dd04-previo', required=True)
    ap.add_argument('--export', required=True)
    ap.add_argument('--rfcexport', required=True)
    ap.add_argument('--salida', required=True)
    a = ap.parse_args()

    with open(a.plan, encoding='utf-8') as fh:
        P = json.load(fh)
    with open(a.dd04_previo, encoding='utf-8') as fh:
        PRE = json.load(fh)
    os.makedirs(a.salida, exist_ok=True)
    if os.listdir(a.salida):
        raise SystemExit('La carpeta de salida no esta vacia: ' + a.salida)

    dd04 = {c['ROLLNAME']: c for c in dump(os.path.join(a.export, 'zdd04t_e.txt'))}
    t100x = {c['KEY']: c['EN'] for c in dump(os.path.join(a.rfcexport, 't100_ex.txt'))}
    lots = collections.defaultdict(list)
    bad = []

    for typ, obj, tk, ml, en, es in P['lxe']:
        if not en and typ == 'DTEL' and obj in dd04:
            en = dd04[obj].get(tk.split()[0], '')
        if not en:
            bad.append(('LXE', typ, obj, tk))
            continue
        val = PRE.get(obj + '\t' + tk, en) if typ == 'DTEL' else en
        lots[('LXE', typ)].append(f'{typ}\t{obj}\t{tk}\t{ml}\t{en}\t{val}')

    small = {}
    for t in SMALL:
        for c in dump(os.path.join(a.rfcexport, f'zrev_dd_{t.lower()}.txt')):
            ks = [v for k, v in c.items()
                  if k not in ('MANDT', 'SPRAS') and k not in ('LTEXT', 'KTEXT', 'TEXT', 'FSTTX')]
            small[(t, '|'.join(ks))] = c
    done_small = set()
    for tool, src, key, ml, en, es in P['tx']:
        if tool == 'TXT' and src in SMALL:
            if (src, key) in done_small:
                continue
            done_small.add((src, key))
            c = small.get((src, key))
            if not c:
                bad.append(('SMALL', src, key))
                continue
            for fl in SMALL[src]:
                lots[('MULTI', '')].append(f'{src}-{fl}\t{key}\t{len(c[fl]) or 1}\t{c[fl]}\t{c[fl]}')
            continue
        if not en and tool == 'TXT' and src == 'T100':
            en = t100x.get(key, '')
        if not en and tool == 'TPOOL' and src == 'RSDBRUNT' and key == 'I|216':
            en = 'to'
        if not en:
            bad.append((tool, src, key))
            continue
        if tool == 'MULTI':
            lots[('MULTI', '')].append(f'{src}\t{key}\t{ml}\t{en}\t{en}')
        else:
            cur = es if es != en else es + ' '
            lots[(tool, src if tool == 'TXT' else '')].append(f'{src}\t{key}\t{ml}\t{cur}\t{en}')

    manifest = []
    for (tool, sub), L in sorted(lots.items(), key=lambda x: len(x[1])):
        L.sort()
        for i in range(0, len(L), MAX):
            n = i // MAX + 1
            name = f'zrev_{tool.lower()}_{sub.lower() or "x"}_{n}.txt'
            with open(os.path.join(a.salida, name), 'w', encoding='utf-8-sig', newline='') as fo:
                fo.write(HEAD[tool] + '\r\n')
                fo.write('\r\n'.join(L[i:i + MAX]) + '\r\n')
            manifest.append([name, tool, sub, len(L[i:i + MAX])])
    with open(os.path.join(a.salida, 'manifest.json'), 'w') as fo:
        json.dump(manifest, fo)
    print('lotes', len(manifest), 'filas', sum(m[3] for m in manifest), 'sin EN', len(bad), bad[:10])


if __name__ == '__main__':
    main()
