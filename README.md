# exp_dat_reading_group_2021

A repository with data, articles and practical sessions to explore PCA, MDS, Structure and many other methods, in the context of Population Genetics.

# Repo Organization

* `README.md`: This document
* `Agenda.md`: A document listing the (planned) schedule of sessions starting with Sep 3, 2021
* `papers/`: A folder with PDFs of discussed papers
* `data/`: A folder which contains the raw data to start analyses from, such as PLINK datasets or other datasets required for the analyses. The large files in this folder (such as `.bim` and `.bed` files) are tracked via `git lfs`, which is available for up to dozens of GB on the MPCDF gitlab instance
* `notebooks/`: A folder with Jupyter notebooks for the practical sessions.

# Run the practical sessions interactively

In order to run the notebooks interactively, there are two options.

## Option 1: Run locally
we recommend that you first install miniconda (https://docs.conda.io/en/latest/miniconda.html). Once installed, you can use our environment file to easily install all the tools you need for this session.

First, clone the github repository if you haven't done so already:

```{bash}
git clone https://github.com/stschiff/exp_dat_reading_group_2021.git
cd exp_dat_reading_group_2021
```

If you have already cloned the repository you can make sure you have the latest update by running git pull inside of it.

Once miniconda has been installed, you can install the environment via:

```{bash}
conda env create -f environment.yml
conda activate PCA_and_friends
```
That's it. Now you should have all the tools ready.

In order start the notebook server, run `jupyter lab` from your command line inside your clone of this repository.

## Option 2: Use practicals interactively on mybinder.org:

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/stschiff/exp_dat_reading_group_2021/HEAD)



