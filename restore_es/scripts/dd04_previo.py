#!/usr/bin/env python3
"""dd04_previo.py - Paso 1, etapa 2 (solo DD04T).

Para los labels de elementos de datos que el proyecto cargo despues de los
primeros lotes, el espanol "previo" no siempre era la copia del ingles: SAP ya
traia espanol propio en algunos campos. Este script compara el volcado S de
DD04T (zdd04t_s.txt, hecho antes de la traduccion) contra el EN del plan y
guarda, por OBJNAME+TEXTKEY, el valor S previo cuando era distinto del EN.
escribir_lotes usa ese valor en lugar del EN para no pisar espanol de SAP.

Uso:
  python dd04_previo.py --export DIR_EXPORT --lotes DIR_LOTES --plan plan.json --salida dd04_pre.json
"""
import argparse, glob, json, os, re

# Lotes de DTEL de la primera etapa (ya partian de la copia del ingles)
EARLY = re.compile(r'^(zbsdtel|zbsfix|zcodtel|zfidtel|ztxdtel|zvimdf|ztrad_.*dtel|ztrad_ad_strhn|ztrad_fidtel)')


def dump(f):
    with open(f, encoding='utf-8-sig') as it:
        h = next(it).rstrip('\r\n').split('\t')
        for l in it:
            yield dict(zip(h, l.rstrip('\r\n').split('\t')))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--export', required=True)
    ap.add_argument('--lotes', required=True)
    ap.add_argument('--plan', required=True)
    ap.add_argument('--salida', required=True)
    a = ap.parse_args()

    S = {c['ROLLNAME']: c for c in dump(os.path.join(a.export, 'zdd04t_s.txt'))}
    early = set()
    for f in glob.glob(os.path.join(a.lotes, 'z*.txt')):
        if not EARLY.match(os.path.basename(f)):
            continue
        with open(f, encoding='utf-8-sig') as fh:
            fh.readline()
            for l in fh:
                c = l.split('\t')
                if len(c) > 2 and c[0] == 'DTEL':
                    early.add((c[1], c[2]))
    with open(a.plan, encoding='utf-8') as fh:
        P = json.load(fh)
    n = diff = 0
    pre = {}
    for typ, obj, tk, ml, en, es in P['lxe']:
        if typ != 'DTEL' or (obj, tk) in early:
            continue
        s = S.get(obj)
        if not s:
            continue
        v = s.get(tk.split()[0], '')
        n += 1
        if v and v != en:
            diff += 1
            pre[obj + '\t' + tk] = v
    print('lotes tempranos', len(early), 'comparadas', n, 'ES previo distinto de EN', diff)
    with open(a.salida, 'w', encoding='utf-8') as fo:
        json.dump(pre, fo, ensure_ascii=False)


if __name__ == '__main__':
    main()
