# An example using drake

# Loading libraries --------------

library(drake)
library(data.table)
library(dplyr)
library(ggplot2)
library(tidyr)
library(purrr)
library(ggridges)
library(glue)
library(here)
library(shiny)
library(leaflet)


# Custom functions --------------

bsts_modelling <- function(data, niter = 1000, burn = .1){
  ss <- AddSemilocalLinearTrend(list(), data)
  ss <- AddAutoAr(ss, data$sales, lags = 1)
  ss <- AddAutoAr(ss, data$sales, lags = 12)
  ss <- AddSeasonal(ss, data, nseasons = 12)

  model <- bsts(data, ss, niter = niter, ping = 0, model.options = BstsOptions(save.full.state = F))

  burn <- SuggestBurn(burn, model)

  model$mean.trend.contributions <- colMeans(model$state.contributions[-(1:burn),"trend",])
  model$mean.season.contributions <- colMeans(model$state.contributions[-(1:burn),"seasonal.12.1",])
  model$state.contributions <- model$state.contributions[niter,,]
  model$one.step.prediction.errors <- model$one.step.prediction.errors[-(1:burn),]

  return(model)
}

# Check (not get!) the files -----------------

fs::file_exists(here("data", "madrid_daily_pollution.csv"))
fs::file_exists(here("data", "stations.csv"))

# Drake plan ---------------------

plan <- drake_plan(
  raw_data = fread(file_in(("data/madrid_daily_pollution.csv"))),
  stations = fread(file_in("data/stations.csv")),
  cleaned_data = raw_data %>%
    mutate(date = ymd(date)) %>%
    gather(key = "agent",
           value = "conc",
           -c(station, date)) %>%
    as_tsibble(key = id(station, agent), index = date, regular = FALSE) %>%
    pad(interval = "day") %>%
    inner_join(stations, by = c("station" = "id")) %>%
    select(station, name, address, lon, lat, elevation, everything()),
  nested_station = cleaned_data %>%
    group_by(station, name, address, lon, lat, elevation) %>%
    nest(),
  nested_agent = cleaned_data %>%
    group_by(agent) %>%
    nest(),
  plot_station = nested_station %>%
    mutate(plot = map2(
      data,
      name,
      ~.x %>%
        filter(!is.na(conc)) %>%
        ggplot(aes(date, conc, color = agent)) +
        geom_line() +
        theme_minimal()+
        labs(title = glue("Station measurements for station {station}"))+
        facet_wrap(~agent, scales = "free_y", ncol = 3))
    ),
  plot_agent_ridge = nested_agent %>%
    mutate(plot = map2(
      data,
      agent,
      ~.x %>%
        filter(!is.na(conc)) %>%
        # mutate(month = month(date, label = TRUE)) %>%
        ggplot(aes(conc, as.factor(name), fill = as.factor(name)))+
        geom_density_ridges(scale = 10, size = .25, show.legend = FALSE, alpha = .8) +
        scale_fill_viridis_d()+
        theme_ridges(font_family = "Helvetica", font_size = 12)+
        # facet_wrap(~month, ncol = 4)+
        labs(title = glue("Concentrations of {.y} per station")))
    ),
  centroids = nested_station %>% select(lon, lat) %>% colMeans()
  # station_map = nested_station %>%
  #   leaflet() %>%
  #   setView(lng = centroids[1], lat = centroids[2], zoom = 13) %>%
  #   addTiles() %>%
  #   addMarkers(lng = ~nested_station$lon,
  #              lat = ~nested_station$lat,
  #              popup = ~nested_station$name)
  # report = rmarkdown::run(
  #   knitr_in("R/report.Rmd")
  # ),


)



# Config ---------------

config <- drake_config(plan)

vis_drake_graph(config)



# Run the plan ------------------

make(plan, jobs = 4, parallelism = "future", lock_envir = FALSE, verbose = TRUE)



