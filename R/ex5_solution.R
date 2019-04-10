#' Exercise 5

# Required libraries--------------------------

library(forecast)

#' Add to the plan --------------------
ex5_plan <- drake_plan(
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
  final = combined %>%
    mutate(
      accuracy = map(model,
                     ~.x %>%
                       accuracy() %>%
                       as_tibble(rownames = "set") %>%
                       pluck("MAPE") %>%
                       round(2)),
      fplot = map2(
        model,
        agent,
        ~.x %>% autoplot() +
          labs(x = "Year",
               y = "Concentration",
               subtitle = glue::glue("Polluting agent: {.y}"))+
          theme(plot.title = element_text(size = 12, face = "bold"))
      )
    )
)

ex5_plan <- bind_plans(
  ex4_plan,
  ex5_plan
)


#' Config ---------------------------------

ex5_conf <- drake_config(ex5_plan)
vis_drake_graph(ex5_conf)

# Run the plan  ---------------------------

make(ex5_plan)



