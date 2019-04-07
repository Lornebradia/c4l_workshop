#' Exercise 4 - peak pollution
#'
#' We take the results from ex3

#' Required libraries -------------------

library(forecast)
theme_set(theme_minimal())

#' Add to the plan --------------------------

ex4_plan <- drake_plan(
  # Yes, this is not optimal - we should go and fix the plan!
  unnested = nested %>%
    unnest(),
  aggregated_renested = unnested %>%
    group_by(agent, date) %>%
    summarise(concentration = mean(concentration, na.rm = TRUE)) %>%
    group_by(agent) %>%
    nest(.key = "history"),
  to_ts = aggregated_renested %>%
    mutate(history = map(history,
                         ~.x %>%
                           rename(time = date) %>%
                           tsbox::ts_ts())),
  seasonal_plots = to_ts %>%
    mutate(seasonal = map2(
      history,
      agent,
      ~.x %>% ggseasonplot(year.labels = F) +
        scale_x_continuous(breaks = seq(0, 1, length.out = 12),
                           labels = month.abb) +
        labs(title = glue::glue("Seasonal plot for {.y}")))),
  # We will train three models in one
  modelling = target(
    to_ts %>% mutate(model = map(history, ~.x %>% stlf(method = how))),
    transform = map(how = c("ets", "arima", "naive"))
    ),
  combined = target(
    bind_rows(list(ets = modelling_.ets.,
                   arima = modelling_.arima.,
                   naive = modelling_.naive.),
              .id = "m_function")),
  plotting = combined %>%
    mutate(fplot = pmap(
      list(model,
           agent,
           m_function),
      function(x, y, z){

        x %>% autoplot() +
          labs(x = "Year",
               y = "Concentration",
               subtitle = glue::glue("Polluting agent: {y}"),
               caption = glue::glue("Modelling function: {z}"))
      }

    )
    )

)

# Add to the previous plan

ex4_plan <- bind_rows(ex3_plan, ex4_plan)

# Config --------------------

ex4_conf <- drake_config(ex4_plan)
vis_drake_graph(ex4_conf)

# Run ----------------------

make(ex4_plan)

vis_drake_graph(ex4_conf, collapse = TRUE)
readd(plotting) %>% pluck("fplots",1)


