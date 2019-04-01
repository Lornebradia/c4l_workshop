# Setup --------------------------

library(shiny)
library(shinydashboard)

station_data <- readd(plot_station)


# Header -----------------------

header <- dashboardHeader(title = "Madrid Pollution 2001-2018")


# Sidebar ----------------------

sidebar <-  dashboardSidebar(
  sidebarMenu(
    menuItem(text = "General Map",
             tabName = "genmap",
             icon = icon("map")),
    menuItem(text = "Agent",
             tabName = "agent",
             icon = icon("skull"))
  )
)

# Body -------------------------

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "genmap", h2("Map")),
    tabItem(tabName = "agent", h2("Agent"))
  )

)

# UI ----------------------------------

ui <- dashboardPage(
  header,
  sidebar,
  body
)

# Server ------------------------------


server <- function(input, output, session){

}

# Launch ----------------------------


shinyApp(ui, server)
