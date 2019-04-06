#' Exercise 2 - inspect the plan
#'
#' Change the file content
#'
#' Required libraries -----------

library(drake)
library(dplyr)

# Modify the file: we keep only the first 100 rows

read.csv("data/madrid_daily_pollution.csv") %>%
  slice(1:100) %>%
  write.csv("data/madrid_daily_pollution.csv", row.names = FALSE)

# Check the plan from ex1

vis_drake_graph(ex1_conf)

# Restore the file

system("git checkout -- data/madrid_daily_pollution.csv")

vis_drake_graph(ex1_conf)
