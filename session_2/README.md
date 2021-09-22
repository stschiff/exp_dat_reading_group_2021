# PCA and Friends Session 2

This is the second session, planned for September 24, 2021. We're going to create our Principal Components for real genomic data and get our feed wet with some of the standard tools.

## Prequisites (ignore if you are viewing this on mybinder.org)

In order to follow this session, we recommend that you first install miniconda (https://docs.conda.io/en/latest/miniconda.html). Once installed, you can use our environment file to easily install all the tools you need for this session.

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

## Make sure trident is up to date

For this session, we'll make use of `trident`, a tool to fetch and work with archaeogenetic data packages. At the point of writing this tutorial, the version of trident on conda was v0.18.1. We would like to use the much faster version v0.21.0, which can be installed with the following commands:

On a Mac:
```{bash}
conda install -c https://169038-42372094-gh.circle-artifacts.com/0/tmp/artifacts/packages poseidon-trident
```

or on Linux:
```{bash}
conda install -c https://169039-42372094-gh.circle-artifacts.com/0/tmp/artifacts/packages poseidon-trident
```

_Note for mybinder.org_: If you're on mybinder, you can open a terminal and update trident from there.