#' Exercise 1 - your first plan
#'
#' You need to create a first plan with drake
#'
#' Required libraries -----------

library(drake)
library(readr)
library(tidyverse)


# Create plan ------------

library(readr)




ex1 <- drake_plan(
  measurements = read_csv(file_in("data/madrid_daily_pollution.csv"),
                          col_types = cols(CH4 = col_double(),
                                           NO = col_double(), PM25 = col_double(),
                                           TCH = col_double(), TOL = col_double(),
                                           date = col_date(format = "%Y-%m-%d"),
                                           station = col_character())
                          ),
  stations = read_csv(file_in("data/stations.csv"),
                      col_types = cols(id = col_character())),
  joined_data = inner_join(measurements, stations, by = c("station" = "id")) %>%
    tbl_df())

# Visualise your plan ------------

ex1

ex1_conf <- drake_config(ex1)
vis_drake_graph(ex1_conf)

# Run your plan ------------------

make(ex1)

# See results ----

readd(join_data)
# loadd(raw_data)

# Graph after running
vis_drake_graph(ex1_conf)
