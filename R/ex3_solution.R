#' Exercise 3 - Nesting a dataframe

# We're taking the result from ex1

# Add to the plan ------------------

ex3_plan <- drake_plan(
  pivot = joined_data %>%
    gather(key = "agent", value = "concentration", BEN:CH4) %>%
    select(station:address, agent, date, everything()) %>%
    group_by_at(1:7) %>%
    nest(.key = "history")
)

# We add this plan to our previous plan

ex3_plan <- bind_rows(ex1_plan,
                      ex3_plan)

# Config ------------------------------

ex3_conf <- drake_config(ex3_plan)
vis_drake_graph(ex3_conf)

# Run ---------------------------------

make(ex3_plan)
vis_drake_graph(ex3_conf)

readd(pivot)
