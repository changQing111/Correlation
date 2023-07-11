# co-abundance
### 1. transform percent table to reads count table with all sample
multiply total reads number per sample, detailed usage: Rscript reads_num.R -h
```shell
Rscript reads_num.R -l sample_list.txt -d profile_dir -n sample_reads_num.txt -t kssd -o reads_count_dir
```

### 2. merge all metagenome sample reads count into a table
first enter profile file folder
```shell
cd profile_dir
```
second merge all profile file into a table, detailed usage: python merge_sample_filter.py -h
```shell
python merge_sample_filter.py -l file_list.txt -t kssd -p merge_profile.txt -s species.txt # defalut discard species bleow 20% 
```

### 3. Construction of microbial interaction network
#### 3.1 fitted
```shell

```
#### 3.2 SparCC/FastSpar
#### 3.3 FlashWeave


