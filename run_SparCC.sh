MYPATH=/home/changqing/bio_soft/SparCC
PROFILE=$1
PREFIX=$2
CORR=${PREFIX}_corr.csv
BOOT_DIR=${PREFIX}_bootstrap
PVAL_DIR=${PREFIX}_pvalue
LOG=${PREFIX}.log
OUT=${PREFIX}_pvals_two_sided.csv

python $MYPATH/Compute_SparCC.py -n Experiment_SparCC -di $PROFILE -ni 20 --save_cor=$CORR

if [ ! -d $BOOT_DIR ];then
        mkdir $BOOT_DIR
fi
python $MYPATH/MakeBootstraps.py $PROFILE -n 1000 -t permutation_#.csv -p $BOOT_DIR/

if [ ! -d $PVAL_DIR ];then
        mkdir $PVAL_DIR
fi
for i in `seq 0 999`;do python $MYPATH/Compute_SparCC.py --name Experiment_SparCC -di $BOOT_DIR/permutation_$i.csv --save_cor $PVAL_DIR/perm_cor_$i.csv >> $LOG; done

python $MYPATH/PseudoPvals.py $CORR $PVAL_DIR/perm_cor_#.csv 1000 -o $OUT -t two_sided
