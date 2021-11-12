############################################# Investigate Asian-Papuan admixture in the Pacific

#get the data from: https://share.eva.mpg.de/index.php/s/8KS5az37qHE3ioE
#or copy it using:
cp /r1/people/sandra_oliveira/Documents/PCAandfriends/Admixture_Asia_Pacific.tar.gz .
tar -xvf Admixture_Asia_Pacific.tar.gz
setwd("")


############################################# 1. DATA

########### get data through poseidon
#mkdir poseidon-repository
#./trident-Linux fetch -d poseidon-repository -f "*2012_PattersonGenetics*,*2018_LipsonCurrentBiology*,*2014_LazaridisNature*,*2018_PosthNatureEcologyEvolution*,*2016_Mallick_SGDP1240K_diploid_pulldown*"
#./trident-Linux forge -d poseidon-repository -o forged_package_new -n package_1 --forgeFile forge_file.txt --intersect --eigenstrat

########### convert eingenstrat to ped (note: some ind were set to Ignore because they were the same ind or related)
#convertf -p par_eig2ped

########### prune data
#plink --file Asia_Pacific --indep-pairwise 200 25 0.4 --out tmp
#plink --file Asia_Pacific --extract tmp.prune.in --make-bed --out Asia_Pacific_pruned

########### correct .fam names using the .ind file
a=read.table("Asia_Pacific_pruned.fam", sep="", head=F)
b=read.table("package_1.ind_mod", sep="", head=F)
for(i in 1:length(a[,1])){
  a[i,1]=b[b[,1]==a[i,2],3]
}
write.table(a,"Asia_Pacific_pruned.fam", sep="/t", quote=F, col.names = F, row.names = F)



############################################# 2. ADMIXTURE

########### unsupervised admixture analysis (3 replicates for k=2:6)
dir=""
for (i in 1:3){
  system(paste0("mkdir ",dir,"/run_",i))
  setwd(paste0(dir,"/run_",i))
  #define the seed - this is important is you do replicates
  s=i*21
  for(k in 2:6){
    cat("k=",k,"i=",i,"\n")
    system(paste0("nohup admixture --seed ",s ," --cv ../Asia_Pacific_pruned.bed ", k, " -j2 | tee log",k, ".out &"))
  }
}

########### supervised admixture analysis (Papuans and Austronesians as sources)
#for this analysis we need an additional file with the .pop extention
a=read.table("Asia_Pacific_pruned.fam", sep="", head=F)
a[a[,1]%in%c("Ami", "Atayal", "Ami.DG", "Atayal.DG"),1]="Austronesian"
a[a[,1]%in%c("Papuan.DG"),1]="Papuan"
a[!a[,1]%in%c("Austronesian", "Papuan"),1]="-"
write.table(as.matrix(a[,1]),"Asia_Pacific_pruned.pop",quote=F, col.names = F, row.names = F, sep=" ")
system(paste0("less Asia_Pacific_pruned.pop"))

dir=""
for (i in 1:3){
  system(paste0("mkdir ",dir,"/run_sup_",i))
  setwd(paste0(dir,"/run_sup_",i))
  s=i*21
  k=2
  cat("k=",k,"i=",i,"\n")
  system(paste0("nohup admixture --seed ",s ," --cv --supervised ../Asia_Pacific_pruned.bed ", k, " -j2 | tee log",k, ".out &"))
}

########### plot supervised and unsupervised admixture analysis
#less pong_filemap_unsupervised
#pong -m pong_filemap_unsupervised -o plot_unsupervised -i pop_ids -n pop_order
#pong -m pong_filemap_supervised -o plot_supervised -i pop_ids -n pop_order

########### check cross validation error
CVmat=matrix(NA,nrow = 3, ncol = 5)
colnames(CVmat)=c("k2", "k3", "k4", "k5", "k6")
rownames(CVmat)=c("run1", "run2", "run3")
LLmat=CVmat
for(run in 1:3){
  for(k in 2:6){
    a=scan(paste("run_", run, "/log", k, ".out", sep=""), sep="\n", what = "character")
    CVmat[run,(k-1)]=strsplit(a[grep("CV error",a)], split = " ")[[1]][4]
    LLmat[run,(k-1)]=strsplit(a[grep("Loglikelihood:",a)], split = " ")[[length(strsplit(a[grep("Loglikelihood:",a)], split = " "))]][2]
  }
}
v=apply(CVmat,2,function(x){mean(as.numeric(x))})
pdf("cv_error_unsupervised.pdf")
plot(2:6, v, xlab="K", ylab="cv error", type="b")
dev.off()



############################################# 3. DyStruct

########### prepare data for dystruct analysis
#create generation file
a=read.table("/mnt/archgen/users/lacher/PCA_class/Pacific/forged_package_new/package_1.janno" , sep="\t", head=T)
ind=as.matrix(read.table("Asia_Pacific_pruned.fam", sep="", head=F))
gen=vector()
for(i in 1:length(ind[,2])){
  gen[i]=a[which(a[,1]==ind[i,2]),10]
  if( gen[i]=="n/a"){
    gen[i]=0
  }
  else{
    gen[i]=round(mean(as.numeric(strsplit(gen[i],";")[[1]]), na.rm=T)/29, digits = 0)
  }
}
bin=seq(0,110, by = 5)
gen_bin=bin[.bincode(as.numeric(gen), breaks=bin, right = F, include.lowest = T)]
unique(gen_bin) #max recommended is 15
write.table(as.matrix(gen_bin),"Asia_Pacific_pruned.gen_bin",quote=F, col.names = F, row.names = F, sep=" ")

########### convert data to eigenstrat
#plink --bfile Asia_Pacific_pruned --recode --out Asia_Pacific_pruned_DyStruct
#convertf -p par_ped2eig

########### correct pop names in the .ind file
a=read.table("Asia_Pacific_pruned_DyStruct.ind", sep="", head=F)
b=read.table("pop_ids", sep="", head=F)
a[,3]=b[,1]
write.table(a,"Asia_Pacific_pruned_DyStruct.ind", sep="/t", quote=F, col.names = F, row.names = F)

########### get number of snps
system("wc -l Asia_Pacific_pruned.bim")
#159542

########### run dystruct
#For best performance set the number of threads to the number of ancestral populations (K)
#A set of genotypes of size --hold-out-fraction * --nloci is treated as missing during training.
#After convergence, DyStruct outputs the conditional log likelihood on the hold out set.
#The final value can be used to compare runs across K.
#To compare runs for the same K, DyStruct outputs the final value of the objective function.
#The run with the highest objective function should be chosen.

# mkdir Dystruct/
# for i in {1..3};do
#   mkdir Dystruct/run_$i
#   cd Dystruct/run_$i
#   for k in {2..6};do
#     export OMP_NUM_THREADS=$k
#     dystruct --input ../../Asia_Pacific_pruned_DyStruct.geno --generation-times ../../Asia_Pacific_pruned.gen_bin --output Asia_Pacific_pruned_DyStruct.$k --npops $k --nloci 159542 --seed $RANDOM --hold-out-fraction 0.05 --hold-out-seed 28149 | tee log$k.out &
# done
# done

########### plot results
#pong -m pong_filemap_dystruct -o plot_dystruct -i pop_ids -n pop_order

########### chose k and best run
r=3
k=5
mat=matrix(NA,r,k)
colnames(mat)=c("k2", "k3", "k4", "k5", "k6")
rownames(mat)=c("run1", "run2", "run3")
mat2=mat
for(i in 1:r){
  for(j in 1:k){
    a=scan(paste0("Dystruct/run_",i,"/log",j+1,".out"), sep="\n", what="character" )
    mat[i,j]=as.numeric(gsub("hold out log likelihood:\t","", a[grep("log likelihood",a)]))
    mat2[i,j]=as.numeric(gsub("objective:\t","", a[grep("objective",a)]))
  }
}
v=apply(mat, 2, function(x){mean(x, na.rm = T)})
pdf("Dystruct_conditional_log_likelihood.pdf")
plot(2:(k+1), v,xlab="k", ylab="conditional log likelihood", type="b")
dev.off()

#you can also check which run has the highest objective function, for example for k=2
which(mat2[,1]==max(mat2[,1]))
