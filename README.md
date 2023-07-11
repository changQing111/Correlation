# Construction of microbial interaction network
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
Multiple commands are written in a single file
```shell
bash run_Sparcc.sh merge_reads_count.txt out_file_prefix
```
FastSpar is SparCC's C++ version, has faster speed and more exact p-value , usage: [https://github.com/scwatts/fastspar](https://github.com/scwatts/fastspar)
```shell
bash run_fastspar.sh merge_reads_count.txt out_file_prefix
```
#### 3.3 FlashWeave
transform reads count table into FlashWeave accepted format
```shell
Rscript format_transform_flashWeave.R -p merge_reads_count.txt -s species.txt -r sample_list.txt -t kssd -o reads_count_flashWeave.txt
```
`FlashWeave` detail usage: [https://github.com/meringlab/FlashWeave.jl](https://github.com/meringlab/FlashWeave.jl)

