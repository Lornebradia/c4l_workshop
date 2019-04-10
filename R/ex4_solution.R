#' Exercise 4 - peak pollution
#'
#' We take the results from ex3

#' Setup -------------------

theme_set(theme_minimal())

#' Add to the plan --------------------------

ex4_plan <- drake_plan(
  aggregated_renested = filtered %>%
    group_by(agent, date) %>%
    summarise(concentration = mean(concentration, na.rm = TRUE)) %>%
    group_by(agent) %>%
    nest(.key = "history"),
  to_ts = aggregated_renested %>%
    mutate(history = map(
      history,
      ~ .x %>%
        rename(time = date) %>%
        tsbox::ts_ts()
    )),
  seasonal_plots = to_ts %>%
    mutate(
      seasonal = map2(
        history,
        agent,
        ~ .x %>%
          ggseasonplot(year.labels = F) +
          stat_smooth(aes(group = NULL, color = NULL),
                      se = FALSE, method = "loess") +
          scale_x_continuous(breaks = seq(0, 1, length.out = 12),
                             labels = month.abb) +
          labs(title = glue::glue("Seasonal plot for {.y}"))
      )
    )
)

# Add to the previous plan

ex4_plan <- bind_plans(ex3_plan, ex4_plan)

# Config --------------------

ex4_conf <- drake_config(ex4_plan)
vis_drake_graph(ex4_conf)

# Run ----------------------

make(ex4_plan)

vis_drake_graph(ex4_conf, collapse = TRUE)
readd(final) %>% pluck("fplot", 5)
