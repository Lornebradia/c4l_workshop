# An example using drake
#
# Loading libraries --------------

library(drake)
library(data.table)
library(dplyr)
library(ggplot2)
library(tidyr)
library(purrr)
library(tibble)
library(padr)
library(lubridate)

# Custom functions --------------



# Check (not get!) the files -----------------

file.exists("data/madrid_daily_pollution.csv")
file.exists("data/stations.csv")

# Drake plan ---------------------

plan <- drake_plan(
  raw_data = fread(file_in("data/madrid_daily_pollution.csv")),
  stations = fread(file_in("data/stations.csv")),
  nested = raw_data %>%
    group_by(station) %>%
    nest(),
  test_plot = nested %>%
    pluck("data", 2) %>%
    ggplot(aes(date_thick, NO_2)) +
    geom_line()

)



# Config ---------------

config <- drake_config(plan)

vis_drake_graph(config)



# Run the plan ------------------

make(plan, jobs = 2, parallelism = "future")
progress()

vis_drake_graph(config)
