# Excess Mortality During the COVID-19 Pandemic Period in Austria 

Code for estimates of the excess mortality in Austria during the pandemic. 
Estimated using an age structured Bayesian generalized additive model, considering yearly trends
and weekly seasonality. 

## Project Structure

The implementation is written in [R](https://www.r-project.org/) using [brms](https://github.com/paul-buerkner/brms).

- [data](data/) Input data files (most inputs are automatically downloaded in the pipline though)
- [R](R/) All code

## Building

Builds are executed by first installing the `renv` package and installing all required packages:
```
renv::restore()
```

Once all packages have been installed the [targets](https://books.ropensci.org/targets/)
pipeline can be executed using 

```
run.sh
``` 
or 

```
targets::tar_make()
```


## Reproducible Development Environment

A docker-compose file is provided in this project to ensure a reproducible development environment.

To run the rstudio server in docker execute the following command:
```
docker-compose -f docker-compose-rstudio.yml up
```
