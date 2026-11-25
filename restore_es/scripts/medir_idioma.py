#!/usr/bin/env python3
"""medir_idioma.py - Que hay en las filas S distintas de E.

Lee el log de sql\\09_textos_s_vs_e.sql (lineas #tabla#clave#campo#idioma#texto,
con idioma S, E o D) y clasifica cada texto S en:
  S_vacio            el campo S esta vacio
  igual_salvo_mayus  S y E solo difieren en mayusculas
  S_es / S_en / S_de el texto parece espanol / ingles / aleman
  S_?                sin palabras suficientes para decidir (siglas, codigos)

El vocabulario espanol sale de la columna ES de los lotes importados, el
ingles de la columna EN y de los textos E del log, y el aleman de los textos D.
Imprime totales y por tabla; con --salida guarda todos los ejemplos.

Uso:
  python medir_idioma.py --log9 09_textos_s_vs_e.log --importados DIR [DIR ...] [--salida ej.json]
"""
import argparse, collections, glob, json, os, re

NO_IMPORT = r'z(rev2?|res|doku)_'
ESX = set('para con del los las por sin una que como desde hasta entre según tratar grabar '
          'visualizar modificar crear borrar continuar'.split())


def W(x):
    return [a for a in re.findall(r"[a-záéíóúüñäöß]+", x.lower()) if len(a) >= 3]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--log9', required=True)
    ap.add_argument('--importados', nargs='+', required=True)
    ap.add_argument('--salida')
    a = ap.parse_args()

    rows = collections.defaultdict(dict)
    with open(a.log9, encoding='latin-1') as fh:
        for l in fh:
            l = l.strip()
            p = l.split('#', 5)
            if not l.startswith('#') or len(p) < 6:
                continue
            _, t, k, f, lg, tx = p
            rows[(t, k, f)][lg] = tx

    es, en, de = collections.Counter(), collections.Counter(), collections.Counter()
    for d in a.importados:
        for f in glob.glob(os.path.join(d, 'z*.txt')):
            if re.match(NO_IMPORT, os.path.basename(f)):
                continue
            with open(f, encoding='utf-8-sig', errors='replace') as fh:
                fh.readline()
                for l in fh:
                    p = l.rstrip('\r\n').split('\t')
                    if len(p) >= 5:
                        en.update(W(p[-2]))
                        es.update(W(p[-1]))
    for v in rows.values():
        en.update(W(v.get('E', '')))
        d = v.get('D', '~')
        if d != '~' and d != v.get('S'):
            de.update(W(d))

    def lang(x):
        w = W(x)
        if re.search(r'[áéíóúñ¿¡]', x.lower()):
            return 'es'
        if re.search(r'[äöüß]', x.lower()):
            return 'de'
        if not w:
            return '?'
        s = sum((a in es and es[a] >= 3) + (a in ESX) * 2 for a in w)
        e = sum(a in en and en[a] >= 3 and a not in es for a in w)
        g = sum(a in de and a not in es and a not in en for a in w)
        m = max(s, e, g)
        if m == 0:
            return '?'
        return 'es' if s == m else ('en' if e == m else 'de')

    c, bt, ex = collections.Counter(), collections.defaultdict(collections.Counter), collections.defaultdict(list)
    for (t, k, f), v in rows.items():
        s, e = v.get('S', ''), v.get('E', '')
        if s == '':
            x = 'S_vacio'
        elif s.lower() == e.lower():
            x = 'igual_salvo_mayus'
        else:
            x = 'S_' + lang(s)
        c[x] += 1
        bt[t][x] += 1
        ex[x].append(f'{t} {k} {f}: S[{s}] E[{e}]')
    print('campos', len(rows))
    for k, v in sorted(c.items()):
        print(k, v)
    for t, cc in bt.items():
        print(' ', t, dict(sorted(cc.items())))
    if a.salida:
        with open(a.salida, 'w', encoding='utf-8') as fo:
            json.dump(ex, fo, ensure_ascii=False)


if __name__ == '__main__':
    main()
