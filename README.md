# co-abundance
### 1. transform percent table to reads count table with all sample
multiply total reads number per sample, detailed usage: Rscript reads_num.R -h
```shell
Rscript reads_num.R -l sample_list.txt -d profile_dir -n sample_reads_num.txt -t kssd -o reads_count_dir
```

### 2. merge all metagenome sample reads count into a table
enter profile file folder
```shell
cd reads_count_dir
```
merge all profile file into a table, defalut discard species bleow 20%, detailed usage: python merge_sample_filter.py -h
```shell
python merge_sample_filter.py -l sample_list.txt -t kssd -p merge_reads_count.txt -s species.txt 
```

### 3. Construction of microbial interaction network
#### 3.1 fitted
detailed usage: python direct_fitting.R -h
```shell
Rscript direct_fitting.R -p merge_reads_count.txt -s species.txt -c 0.5 -t kssd -o species_corr_pvalue
```
#### 3.2 SparCC/FastSpar
SparCC usage: [https://github.com/dlegor/SparCC](https://github.com/dlegor/SparCC)
```shell
bash run_Sparcc.sh prefix merge_reads_count.txt
```
#### 3.3 FlashWeave


