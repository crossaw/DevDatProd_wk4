library(shiny)
library(jsonlite)

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
censDat <- data.frame()

for (thisURL in apiURLs) {
  censDat <- rbind( censDat, getCensDat(thisURL) )
}
