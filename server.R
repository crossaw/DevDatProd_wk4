library(jsonlite)
library(magrittr)
library(curl)

getCensDat <- function (api) {
   # obtain the api from https://www.census.gov/data/developers/data-sets/popest-popproj/popest.html
   cd           <- fromJSON(paste0("https://", api, "?get=POP,DATE,DATE_DESC&for=state:*"
                           ))[,-2][-1,] # for 2016, it won't get other years unless DATE is included
   colnames(cd) <- c("pop", "yr", "state")            # cd is a character matrix
   cd           <- data.frame(cd, stringsAsFactors=F) # turn it into a dataframe
   cd[1]        <- as.integer(cd[,1])                 # the population values
   cd[2]        <- sub("7/1/(\\d{4}).*", "\\1", cd$yr)# just the year for Jul values
   cd[ grep("^\\d{4}", cd$yr), ]                      # prune and return
}
apiURLs <- c("api.census.gov/data/2000/pep/int_population",
             "api.census.gov/data/2016/pep/population")
if(F){    # replaced by function
censDat <- fromJSON("https://api.census.gov/data/2016/pep/population?get=POP,DATE&for=state:*")
colnames(censDat) <- censDat[1,]
censDat <- censDat[2:nrow(censDat),]
censDat <- data.frame(censDat, stringsAsFactors=F)
censDat[1] <- as.integer(censDat[,1])
censDat[2] <- as.integer(censDat[,2])
}
popCen <- read.csv("http://www2.census.gov/geo/docs/reference/cenpop2010/CenPop2010_Mean_ST.txt",
                   stringsAsFactors=F)
censDat <- data.frame()
for (thisURL in apiURLs) {
   censDat <- rbind( censDat, getCensDat(thisURL) )
}
yrs <- sort( unique(censDat$yr) )
stDF  <- data.frame(lat=popCen$LATITUDE, lng=popCen$LONGITUDE)
#refPop <- censDat[ censDat[,2]==2, 1 ]

shinyServer( function(input, output) {
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
} )
