#' Install R packages
#'
#' This script will install in your machine all the packages you'll need for this workshop.

paq <- c(
  "drake",
  "flexdashboard",
  "forecast",
  "glue",
  "rsconnect",
  "shiny",
  "sweep",
  "tidyverse",
  "tsbox"
)

if(any(!paq %in% installed.packages())) {
  install.packages(paq[!paq %in% installed.packages()])
}else{
    cat("All necessary packages installed!")
}

