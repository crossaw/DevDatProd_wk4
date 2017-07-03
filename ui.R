library(shiny)
library(leaflet)

shinyUI(fluidPage(
  titlePanel("Population Growth by State"),
  titlePanel(paste( "Created: ", date(), " GMT" )),
  
  sidebarLayout(
    sidebarPanel(
       radioButtons("yr", "Year", 2010:2016),
       width=2
    ),
    
    mainPanel(
      leafletOutput("popMap", height=500),
      "Circles are positioned at the population centers of the states.  Circle area is
        proportional to the population change as of July of the given year, relative
       to April of 2010.  Increases are blue; decreases are red.",
       width=10
    )
  )
))
