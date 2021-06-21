#Draft Schedule (idea: Starting in September 2021)
(Sep 3, 2021) First get together and planning session
What is PCA? Menozzi, Piazza, and Cavalli-Sforza, “Synthetic Maps of Human Gene Frequencies in Europeans”; Novembre et al., “Genes Mirror Geography within Europe.”
How to use PCA? Practical: HGDP, perhaps thinned down, world-wide… PCA, F2-matrices, MDS, connection between PCA+MDS
What about missingness and projection? (Agrawal et al. 2020; Meisner et al. 2021) (something about missing data and projection for PCA. Possibly also Nick’s least-sq thing (https://github.com/DReichLab/EIG/blob/master/POPGEN/lsqproject.pdf))
How to deal with missingness and projection? Dealing with missing data: 
“Standard projection”: Using SNP loadings to project samples into pre-computed PCs
“Standard missingness”: Filling in missing data with mean freqs.
“Standard” way to deal with projection in MDS?
Smartpca:
https://cran.r-project.org/web/packages/softImpute/index.html
What is Structure/Admixture? Structure / Admixture… entweder als Review oder die Original-Paper




How to run Admixture?
Run admixture
Run admixture in supervised mode
Comparison with PCA (auch PCA on ADMIXTURE components?)
Foundational principles behind PCA/Admixture:
Engelhardt and Stephens, “Analysis of Population Structure.” + (McVean 2009)
Simulations:
Simulations using msPrime under given sample sizes and coalecence rates
How does it look on PCA? See McVean 2009
Further topics:
tSNE
UMAP
PCA based on other matrices such as Fine-Structure
Detailed discussion of MDS vs PCA

