#' Exercise 6 - Reporting
#'
#'

library(shiny)

ex6_plan <- drake_plan(
  # We need to export the results to be able to later publish - the drake cache is not available for export
  export_final = final %>% saveRDS(file_out("R/final.RDS")),
  export_seasonal = seasonal_plots %>% saveRDS(file_out("R/seasonal_plots.RDS")),
  export_agg_ren = aggregated_renested %>%
    saveRDS(file = file_out("R/aggregated_renested.RDS")),
  report = rmarkdown::run(
    knitr_in("R/report.Rmd"))
)

ex6_plan <- bind_plans(
  ex5_plan,
  ex6_plan
)

ex6_conf <- drake_config(ex6_plan)
vis_drake_graph(ex6_conf, collapse = TRUE)


make(ex6_plan, lock_envir = FALSE)


