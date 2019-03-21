# An example using drake
#
# Loading libraries --------------

library(drake)
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
                   data.table::fread()) %>%
    bind_rows(),
  data = raw_data %>%
    mutate(
      station = as.factor(station),
      date = as.POSIXct(date),
      month = month(date)) %>%
    arrange(date) %>%
    thicken(interval = "day",
            colname = "date_thick") %>%
    group_by(station, date_thick) %>%
    select(-date) %>%
    summarise_if(is_numeric, mean, na.rm = T) %>%
    group_by(station) %>%
    nest(),
  test_plot = data %>%
    pluck("data", 1) %>%
    ggplot(aes(date_thick, NO_2)) +
    geom_line()




)


# Run the plan ------------------

make(plan, jobs = 4, parallelism = "future")

# Config ---------------

config <- drake_config(plan)

vis_drake_graph(config)

readd(test_plot)
