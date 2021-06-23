# Draft Schedule (idea: Starting in September 2021)

### Session 0: First get-together and planning session
- Date: Sep 3, 2021 

### Session 1: What is Principal Component analysis?
- Date: Sep 10, 2021
- Presenters:
- Reading: Menozzi, Piazza, and Cavalli-Sforza, “Synthetic Maps of Human Gene Frequencies in Europeans” [@menozzi1994]
- Reading: Novembre et al., “Genes Mirror Geography within Europe.” [@Novembre2008]

### Session 2: (Practical): How to use PCA?
- Date: Sep 17, 2021
- Presenters:
- Tools: smartpca,
- Data: HGDP, thinned down (?)
- Topics: PCA, F2, MDS, connections between them

### Session 3: Missing data and projection
- Date: Sep 24, 2021
- Presenters:
- Reading: Meisner et al. 2021
- Reading: Agrawal et al. 2020

### Session 4 (Practical): How to deal with missing data
- Date: Oct 1, 2021
- Presenters:
- Tools:[https://cran.r-project.org/web/packages/softImpute/index.html](softImpute)
- Tool: [https://github.com/DReichLab/EIG/blob/master/POPGEN/lsqproject.pdf](least square projection)
- Approaches
  - mean imputation
  - projection
  - EM-imputation
  - MDS-projection?

### Session 5: Structure / Admixture
- Date: Oct 8, 2021
- Presenters:
- Reading: 
  - Pritchard et al. 2000
  - Alexander et al. 2009 (Admixture)
  - maybe some review
    
### Session 6 (Practical): How to run Admixture?
- Date: Oct 15, 2021
- Presenters:
- Tool: [https://dalexander.github.io/admixture/download.html](ADMIXTURE)
- Tasks: Run admixture
    - Run admixture in supervised mode
    - Comparison with PCA
    - PCA on Admixture components (?)

### Session 7: Foundational principles behind PCA/Admixture
- Date: Oct 22, 2021
- Presenters:
- Reading: Engelhardt and Stephens, “Analysis of Population Structure.”
- Reading: McVean 2009

### Session 8 (Practical): Simulations / predictions
- Date: Oct 29, 2021
- Presenters:
- Tool: [https://tskit.dev/msprime/docs/stable/intro.html](msprime)
- Tasks 
    - Simulation with sample sizes / coalescence rates
    - Task: Predicted PCA vs Simulations

### Session 9: Topic TBD
- Date: Nov 5, 2021
- Presenters:

### Session 10: Topic TBD
- Date: Nov 12, 2021
- Presenters:

### Session 11: Topic TBD
- Date: Nov 19, 2021
- Presenters:

### Session 12: Topic TBD
- Date: Nov 26, 2021
- Presenters:

### Session 13: Topic TBD
- Date: Dec 3, 2021
- Presenters:

### Session 13: Topic TBD
- Date: Dec 10, 2021
- Presenters:

## Further topics:
- non-linear projections
    - tSNE
    - UMAP
    - Diffusion maps
- other linear projections
    - Trees
    - Admixture Graphs
    - Treelets
- Comparison of tools
    - Detailed discussion of MDS vs PCA
    - F-statistics and PCA
    - qpADM and PCA
- Selection and SNP outliers
- PCA based on other matrices such as Fine-Structure
- Interpretation of PCA-plots
