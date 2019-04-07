#' Exercise 3 - Nesting a dataframe

# We're taking the result from ex1

# Add to the plan ------------------

ex3_plan <- drake_plan(
  pivoted = joined_data %>%
    # Pivot the data into long format
    gather(key = "agent", value = "concentration", BEN:CH4) %>%
    # Reorder the columns
    select(station:address, agent, date, everything()) %>%
    # We need to remove those stations and agents for which ALL the data is missing
    group_by(station, agent) %>%
    mutate(all_missing = all(is.na(concentration))) %>%
    filter(!all_missing) %>%
    # Cleanup
    select(-all_missing),
  filtered = pivoted %>%
    filter(agent %in% c("PM10", "PM25", "NO_2","CO")),
  nested = filtered %>%
    group_by_at(1:7) %>%
    nest(.key = "history")
  # nested = target(
  #   group_by(filtered, vars) %>% nest(),
  #   transform = map(vars = c(station, agent)))
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

