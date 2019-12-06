#' Exercise 5

# Required libraries--------------------------



#' Add to the plan --------------------

#' Create a target that runs models. Pass an argument so that it runs the model with different values
#' for the model paramenter.
#' Create a target that combines the results into one.
#' Create a plot using the following target:

  # final = combined %>%
  #   mutate(fplot = map2(
  #     model,
  #     agent,
  #     ~ .x %>%
  #       autoplot() +
  #       labs(
  #         x = "Year",
  #         y = "Concentration",
  #         subtitle = glue::glue("Polluting agent: {.y}")
  #       ) +
  #       theme(plot.title = element_text(size = 12, face = "bold"))
  #   )
  # )

# ex5_plan <-

# Combine this plan with the previous ones


#' Config ---------------------------------


# Run the plan  ---------------------------

