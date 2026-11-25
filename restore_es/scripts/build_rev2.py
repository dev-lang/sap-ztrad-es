#!/usr/bin/env python3
"""build_rev2.py - Paso 1, segunda tanda: claves que no estaban en el plan.

Los lotes cargados por el servicio HTTP (carpeta ztrad_rfc_files\\rfcimport)
y los de las fases 1-3 del 23/11 no estaban entre los usados por build_rev.py.
Este script junta sus claves ES <> EN (el ultimo ES cargado gana), informa
cuantas ya estaban en el plan y deja new.json para armar los lotes zrev2_*.

Uso:
  python build_rev2.py --rfcimport DIR_RFCIMPORT --fases DIR_LOTES_FASES \\
         --plan plan.json --salida new.json
"""
import argparse, collections, json, os

TXT = {'T100', 'D021T', 'DD01T', 'DD02T', 'DD07T', 'DD30T', 'IMGACT', 'IMGNODE', 'TSTCT', 'RSMPTEXTS'}
PREFIJOS_RFC = ('zrsx8', 'zt100_tr58_tc', 'zt100_tr58_tchk')
LOTES_FASES = ['zres_txt_t100_f1.txt', 'zres_txt_imgact_f1.txt', 'zres_txt_imgnode_f1.txt',
               'zres_txt_tstct_f1.txt', 'zres_txt_dd30t_f1.txt', 'zres_txt_dd01t_f1.txt',
               'zres_txt_dd02t_f1.txt', 'zres_txt_dd07t_f1.txt', 'zdd04t_f2_es1.txt',
               'zrpt4_f2_es1.txt', 'zdd04t_f3_es1.txt', 'zdd04t_f3_bv.txt']


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--rfcimport', required=True)
    ap.add_argument('--fases', required=True, help='carpeta con los lotes de las fases 1-3')
    ap.add_argument('--plan', required=True)
    ap.add_argument('--salida', required=True)
    a = ap.parse_args()

    # Orden de carga: primero los del servicio HTTP, despues los del 23/11
    files = [os.path.join(a.rfcimport, f) for f in sorted(os.listdir(a.rfcimport))
             if f.startswith(PREFIJOS_RFC)]
    files += [os.path.join(a.fases, f) for f in LOTES_FASES]
    lxe, tx = {}, {}
    for f in files:
        with open(f, encoding='utf-8-sig') as fh:
            L = fh.read().splitlines()
        h = L[0].split('\t')
        for l in L[1:]:
            c = l.split('\t')
            if h[0] == 'OBJTYPE':
                if len(c) < 6 or c[5] == c[4] or not c[5]:
                    continue
                k = (c[0], c[1], c[2])
                if k not in lxe:
                    lxe[k] = [c[3], c[4], c[5], os.path.basename(f)]
                else:
                    lxe[k][2] = c[5]
            else:
                if len(c) < 5 or c[4] == c[3] or not c[4]:
                    continue
                if c[0] not in TXT:
                    raise SystemExit(f'Tabla no esperada {c[0]} en {f}')
                k = (c[0], c[1])
                if k not in tx:
                    tx[k] = [c[2], c[3], c[4], os.path.basename(f)]
                else:
                    tx[k][2] = c[4]
    print('lxe', len(lxe), collections.Counter(k[0] for k in lxe))
    print('tx', len(tx), collections.Counter(k[0] for k in tx))
    with open(a.plan, encoding='utf-8') as fh:
        P = json.load(fh)
    pl = {(r[0], r[1], r[2]) for r in P['lxe']}
    pt = {(r[1], r[2]) for r in P['tx'] if r[0] == 'TXT'}
    print('ya en el plan: lxe', sum(k in pl for k in lxe), 'tx', sum(k in pt for k in tx))
    with open(a.salida, 'w', encoding='utf-8') as fo:
        json.dump({'lxe': [[*k, *v] for k, v in lxe.items()], 'tx': [[*k, *v] for k, v in tx.items()]},
                  fo, ensure_ascii=False)


if __name__ == '__main__':
    main()
