library(jsonlite)
library(magrittr)
library(curl)

censDat <- fromJSON("https://api.census.gov/data/2016/pep/population?get=POP,DATE&for=state:*")
colnames(censDat) <- censDat[1,]
censDat <- censDat[2:nrow(censDat),]
censDat <- data.frame(censDat, stringsAsFactors=F)
censDat[1] <- as.integer(censDat[,1])
censDat[2] <- as.integer(censDat[,2])
popCen <- read.csv("http://www2.census.gov/geo/docs/reference/cenpop2010/CenPop2010_Mean_ST.txt", stringsAsFactors=F)
stDF  <- data.frame(lat=popCen$LATITUDE, lng=popCen$LONGITUDE)
refPop <- censDat[ censDat[,2]==2, 1 ]

shinyServer(function(input, output) {
   newPop <- reactive({
      yrNum <- as.integer(input$yr) - 2007
      censDat[ censDat[,2]==yrNum, 1 ]
   })
   cirSize  <- reactive({
      isDecrease <- refPop > newPop()
      sqrt( (newPop() / refPop - 1) * (1-2*isDecrease) ) * 80
   })
   colIndex <- reactive( {1+(refPop > newPop())} )

   output$popMap <- renderLeaflet({
      stDF %>% leaflet() %>% addTiles() %>% addMarkers()
   })
   observe({
      leafletProxy("popMap", data=stDF) %>% clearMarkers() %>%
      addCircleMarkers(radius=cirSize(),
                       weight=0,
                       fillColor=c("blue", "red")[colIndex()],
                       fillOpacity=0.4,
                       popup=popCen$STNAME)
   })
})