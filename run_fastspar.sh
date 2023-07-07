PROFILE=$1
PREFIX=$2
CORR=${PREFIX}_correlation.tsv
COVAR=${PREFIX}_covariance.tsv
BOOSTSTARP_COUNTS=${PREFIX}_bootstrap_counts
BOOSTSTARP_CORR=${PREFIX}_bootstrap_correlation
PVALUE=${PREFIX}_pvalues.tsv

fastspar --iterations 50 --exclude_iterations 20 --threshold 0.2 --otu_table $PROFILE --correlation $CORR --covariance $COVAR

mkdir $BOOSTSTARP_COUNTS
fastspar_bootstrap --otu_table $PROFILE --number 1000 --prefix $BOOSTSTARP_COUNTS/fake_data

mkdir $BOOSTSTARP_CORR
parallel fastspar --otu_table {} --correlation $BOOSTSTARP_CORR/cor_{/} --covariance $BOOSTSTARP_CORR/cov_{/} -i 5 ::: $BOOSTSTARP_COUNTS/*

fastspar_pvalues --otu_table $PROFILE --correlation $CORR --prefix $BOOSTSTARP_CORR/cor_fake_data_ --permutations 1000 --outfile $PVALUE
