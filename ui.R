library(leaflet)

yrs <- as.integer( unique(censDat$yr) )

shinyUI(fluidPage(
  titlePanel("Population Growth by State"),

  sidebarLayout(
    sidebarPanel(
       numericInput( "refY", "Reference Year", min(yrs), min(yrs), max(yrs) ),
       numericInput( "resY", "Display Year", max(yrs), min(yrs), max(yrs) ),
       p("Click the arrows in the boxes above to increase or decrease the years."),
       width=2
    ),

    mainPanel(
      leafletOutput("popMap", height=500),
      p("Circles are positioned at the 2010 population centers of the states.
        Circle area is proportional to the population change from the Reference
        Year to the Display Year.  Increases are blue; decreases are red."),
      width=10
    )
  ),
  
  mainPanel(
    p( paste0("This application allows you to explore the growth and contraction of populations
    throughout the United States.  The map indicates the population change for each state
    and some other similar political entities. Use the numeric input boxes on the left to
    select a reference year and a display year. Data is available for years ranging
    from ", min(yrs), " to ", max(yrs), ". The display is based on the population estimates
    for 1 Jul of each year. The data was obtained from the U.S. Census Bureau through their
    web API.") ),
    p("Clicking on any circle will produce a pop-up showing what state is represented
    by that circle and what that state's population was in the reference year and the display
    year.  Further clicking on the name of the state takes you to that state's wikipedia page."),
    p("The map can be zoomed in, zoomed out and panned."),
    width=12)
))
