# Draft Schedule (idea: Starting in September 2021)

### Session 0: First get-together and planning session
- Date: Sep 10, 2021 

### Session 1: What is Principal Component analysis?
- Date: Sep 17, 2021
- Presenters: Yilei, Divyaratan
- Reading: PCA chapter of History and geography of human genes (mattermost)
- Reading: https://liorpachter.wordpress.com/2014/05/26/what-is-principal-component-analysis/
- Reading: Novembre et al., “Genes Mirror Geography within Europe.” [@Novembre2008]

### Session 2: (Practical): How to use PCA?
- Date: Sep 24, 2021
- Presenters: Stephan, Thiseas
- Tools: smartpca,
- Data: HGDP, thinned down (?)
- Topics: PCA, F2, MDS, connections between them

### Session 3: Missing data and projection
- Date: Oct 8, 2021
- Presenters: Luca, Thiseas
- Reading: Meisner, Jonas, Siyang Liu, Mingxi Huang, and Anders Albrechtsen. 2021. “Large-Scale Inference of Population Structure in Presence of Missingness Using PCA.” Bioinformatics , January. https://doi.org/10.1093/bioinformatics/btab027.
- Reading: Agrawal, Aman, Alec M. Chiu, Minh Le, Eran Halperin, and Sriram Sankararaman. 2020. “Scalable Probabilistic PCA for Large-Scale Genetic Variation Data.” PLoS Genetics 16 (5): e1008773.

### Session 4 (Practical): How to deal with missing data
- Date: Oct 15, 2021
- Presenters: Clemens, Ben V.
- Tools: [softImpute](https://cran.r-project.org/web/packages/softImpute/index.html)
- Tool: [least square projection](https://github.com/DReichLab/EIG/blob/master/POPGEN/lsqproject.pdf)
- Approaches
  - mean imputation
  - projection
  - EM-imputation
  - MDS-projection?

### Session 5 (Practical): More on projection and PCA
- Date: Oct 22, 2021
- Goal: Try out various missing data techniques

### Session 6: Structure / Admixture
- Date: Nov 5, 2021
- Presenters: Leonardo A., Ke
- Reading: 
  - Pritchard et al. 2000
  - Alexander et al. 2009 (Admixture)
  - maybe some review (for example Falush "Badmixture")
    
### Session 7 (Practical): How to run Admixture?
- Date: Nov 12, 2021
- Presenters: Sandra, Laura, Joscha
- Tool: [ADMIXTURE](https://dalexander.github.io/admixture/download.html)
- Tasks: Run admixture
    - Run admixture in supervised mode
    - Comparison with PCA
    - PCA on Admixture components (?)
    - Dystruct?

### Session 8: Foundational principles behind PCA/Admixture
- Date: Nov 26, 2021
- Presenters: Stephan, Federica, Alba
- Reading: Engelhardt and Stephens, “Analysis of Population Structure.”
- Reading: McVean 2009

### Session 9 (Practical): Simulations / predictions
- Date: Dec 3, 2021
- Presenters: Leonardo I., Arev
- Tool: [msprime](https://tskit.dev/msprime/docs/stable/intro.html)
- Tasks 
    - Simulation with sample sizes / coalescence rates
    - Task: Predicted PCA vs Simulations

### Session 9: Topic TBD
- Date: Dec 3, 2021
- Presenters:

### Session 10: Topic TBD
- Date: Dec 10, 2021
- Presenters:

### Session 11: Topic TBD
- Date: Dec 17, 2021
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
