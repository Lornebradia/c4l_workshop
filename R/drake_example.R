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

file.exists("data/madrid_2001.csv")

# Drake plan ---------------------

plan <- drake_plan(
  raw_data = map(list.files("data/", pattern = "madrid_", full.names = T),
                 ~.x %>%
                   fread()) %>%
    bind_rows(),
  stations = fread(file_in("data/stations.csv")),
  data_mutated = raw_data %>%
    mutate(
      station = as.character(station),
      date = ymd_hms(date)),
  data_thick = data_mutated %>%
    arrange(date) %>%
    thicken(interval = "day",
            colname = "date_thick"),
  data_summary = data_thick %>%
    group_by(station, date_thick) %>%
    select(-date) %>%
    summarise_if(is_numeric, mean, na.rm = T) %>%
    arrange(date_thick),
  write = fwrite(data_summary, file = file_out("data/monthly.csv")),
  nested = data_summary %>%
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
