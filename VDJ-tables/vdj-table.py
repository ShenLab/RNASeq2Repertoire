#!/usr/bin/env python

from sys import argv

def make_dict(filename):
    d = { }
    for line in open(filename, 'r'):
        words = line.split()
        key = tuple(words[:-1])
        val = float(words[-1])
        d[key] = d.get(key, 0.0) + val
    return d

def emit(filenames, ds, ks):
    labels = map(lambda t: "-".join(t), ks)
    print("#\t{0}".format("\t".join(labels)))
    for d,name in zip(ds, filenames):
        values = [d.get(k,0.0) for k in ks]
        print("{0}\t{1}".format(name, "\t".join(map(str,values))))

def main(filenames):
    ds = map(make_dict, filenames)
    ks = reduce(lambda a,b: a|b,
                map(lambda d: set(d.keys()),
                    ds))
    ks = sorted(list(ks))
    emit(filenames, ds, ks)

if __name__ == "__main__":
    filenames = argv[1:]
    main(sorted(filenames))
