library(magrittr)
library(curl)

popCen <- read.csv("http://www2.census.gov/geo/docs/reference/cenpop2010/CenPop2010_Mean_ST.txt",
                   stringsAsFactors=F)
stDF  <- data.frame(lat=popCen$LATITUDE, lng=popCen$LONGITUDE)
webName <- gsub(" ", "_", popCen$STNAME)

shinyServer( function(input, output) {
   refPop <- reactive({
     censDat[censDat$yr==input$refY, 1]
   })

   newPop  <- reactive({
     censDat[ censDat[,2]==input$resY, 1 ]
   })
   cirSize  <- reactive({
      isDecrease <- refPop() > newPop()
      sqrt( (newPop() / refPop() - 1) * (1-2*isDecrease) ) * 80
   })
   colIndex <- reactive( {1+(refPop() > newPop())} )

   output$popMap <- renderLeaflet({
      stDF %>% leaflet() %>% addTiles() %>% addMarkers()
   })
   observe({
      refY <- input$refY
      resY <- input$resY
      
      leafletProxy("popMap", data=stDF) %>% clearMarkers() %>%
      addCircleMarkers(radius=cirSize(),
                       weight=0,
                       fillColor=c("blue", "red")[colIndex()],
                       fillOpacity=0.4,
                       popup=paste0( "<a href=https://en.wikipedia.org/wiki/",
                                    webName, ">", popCen$STNAME, "</a><br>", refY, " pop: ",
                                    format(censDat[censDat$yr==refY, 1], big.mark=","),
                                    "<br>", resY, " pop: ",
                                    format(censDat[censDat$yr==resY, 1], big.mark=",") )
      )
   })
} )
