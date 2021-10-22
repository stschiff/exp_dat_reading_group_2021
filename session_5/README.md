## Session 5

Today we are supposed to just mess around with PCAs and downsampling. I added a simple python script to "shoot holes" in a given eigenstrat format dataset, and save it under a new name.

Example usage:
```
python shoot_holes_in_eigen.py --eigen tmp/test_eigen --out tmp/out_eigen --frac .1 --pops ind1 pop2
```

This command would take the eigenstrat data found in `tmp/test_eigen`, set 10% of the sites to be missing for any individual that matched `ind1` or `pop2`, and save the new dataset to `tmp/out_eigen`.

The `--pops` argument selects individuals that match either in the "ind" column *or* the "population" column, so be careful.

***

To run the emu software discussed two sessions ago (Meisner et al. 2021), you can install the software from [here](https://github.com/rosemeis/emu) and run it on input PLINK data.

