#!/bin/sh
# Hydrate cached packages
cp -r /app/renv/library /home/rstudio/covid19-austria-excess-mortality/renv
cp -r /app/renv/staging /home/rstudio/covid19-austria-excess-mortality/renv

# Run rstudio server
/init