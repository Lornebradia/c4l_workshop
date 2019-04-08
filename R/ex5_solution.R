#' Exercise 5 - Reporting
#'
#'

library(shiny)

ex5_plan <- drake_plan(
  # We need to export the results to be able to later publish - the drake cache is not available for export
  export_final = final %>% saveRDS(file_out("R/final.RDS")),
  export_seasonal = seasonal_plots %>% saveRDS(file_out("R/seasonal_plots.RDS")),
  export_agg_ren = aggregated_renested %>%
    saveRDS(file = file_out("R/aggregated_renested.RDS")),
  report = rmarkdown::run(
    knitr_in("R/report.Rmd"))
)

ex5_plan <- bind_rows(
  ex4_plan,
  ex5_plan
)

ex5_conf <- drake_config(ex5_plan)
vis_drake_graph(ex5_conf, collapse = TRUE)


make(ex5_plan, lock_envir = FALSE)


