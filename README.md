# string-dissimilarity-in-python

Repository for the Medium article of the same name.

## Download data

Download the sample data, consisting of T-cell receptor sequences obtained from [VDJdb](https://vdjdb.cdr3.net/)

```shell
pip install gdown
gdown https://drive.google.com/uc?id=1d5DQLQ1ibkuAPlEe-TJs3uZLJGkLPohA -O data/vdjdb.csv
```

## Run the experiments

It is assumed that `docker` is installed and running:

```bash
./run_experiments.sh
```
