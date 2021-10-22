import argparse, sys, random
from shutil import copyfile


parser = argparse.ArgumentParser()

## input eigen base (need .ind and .geno)
## pct holes
## eigen output base

parser.add_argument("--eigen", help = "input eigen base name", type = str, required = True)
parser.add_argument("--out", help = "output eigen base name", type = str, required = True)
parser.add_argument("--frac", help = "fraction of sites to set as missing, per individual", type = float, required = True)
parser.add_argument("--pops", nargs = '+', help = "populations/individuals to poke holes in", type = str, default = [], required = True)
parser.add_argument("--debug", action="store_true", help = "Print debug info")

args = parser.parse_args()


## read inds/pops, save columns that need holes
indfile = open(args.eigen + '.ind')
shoot_cols = []
for idx, line in enumerate(indfile):
    ind, _, pop = line.strip().split()

    if ind in args.pops or pop in args.pops:
        shoot_cols += [idx]
        pass

    pass

## read geno, poke holes, write geno
genofile = open(args.eigen + '.geno')

genofile_out = open(args.out + '.geno', 'w')

for idx, line in enumerate(genofile):

    missing_cols = [x for x in shoot_cols if random.random() < args.frac]

    line_split = list(line.rstrip())
    for x in missing_cols:
        line_split[x] = '9'
        pass
    
    if args.debug: print(line.rstrip(), missing_cols, ''.join(line_split))

    genofile_out.write(''.join(line_split) + '\n')

    pass

genofile_out.close()

copyfile(args.eigen + '.snp', args.out + '.snp')
copyfile(args.eigen + '.ind', args.out + '.ind')
