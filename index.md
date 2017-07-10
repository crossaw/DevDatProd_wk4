U.S. Population Growth
========================================================
author: Arnold Cross
date: 9 Jul 2017
autosize: true

========================================================
### The [U.S. Census Bureau](https://census.gov/)
- Makes a plethora of data publicly available
- Through their [API](https://www.census.gov/developers/)
- Yearly estimates of population
 - Among the most basic of that data
 - A variety of geographic division schemes

### This project
- Graphically show the percentage of population change
- By state
- From one year to another (not necessarily consecutive years)
- Hosted [online](https://arnoldcross.shinyapps.io/DevDatProd_wk4/)

========================================================
### Coding considerations
- Use leaflet for a map
- Let the user select the reference year and the display year
- Use at least two datasets from the Census Bureau API
 - Motivates the use of a function
 - Makes the DATE field ambiguous (see next slide)
- The population center coordinates are obtained from a text file at the [Census Bureau references page](https://www.census.gov/geo/reference/centersofpop.html)
- Need a global.R file, because ui.R gets the years from the datasets

========================================================
<small>Exploratory Analysis: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I found that it is better to extract the year from the DATE_DESC field than the DATE field.

```r
library(jsonlite); censDat <- fromJSON( "https://api.census.gov/data/2016/pep/population?get=POP,DATE,DATE_DESC&for=state:*")
head(censDat[,2:4], 8)
```

```
     [,1]   [,2]                                 [,3]   
[1,] "DATE" "DATE_DESC"                          "state"
[2,] "1"    "4/1/2010 Census population_old"     "01"   
[3,] "2"    "4/1/2010 population_old estimates " "01"   
[4,] "3"    "7/1/2010 population_old estimate"   "01"   
[5,] "4"    "7/1/2011 population_old estimate"   "01"   
[6,] "5"    "7/1/2012 population_old estimate"   "01"   
[7,] "6"    "7/1/2013 population_old estimate"   "01"   
[8,] "7"    "7/1/2014 population_old estimate"   "01"   
```

```r
yr <- sub("7/1/(\\d{4}).*", "\\1", censDat[-1, 3])
str( yr[grep("^\\d{4}", yr)] )
```

```
 chr [1:364] "2010" "2011" "2012" "2013" "2014" "2015" "2016" "2010" ...
```
</small>

========================================================
<small>Example code calculating 2015 results, referenced to 2012. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(It helps that the states are arranged in the same order in each dataset.)

```r
popCen <- read.csv( "http://www2.census.gov/geo/docs/reference/cenpop2010/CenPop2010_Mean_ST.txt", stringsAsFactors=F)
stDF <- data.frame(lat=popCen$LATITUDE, lng=popCen$LONGITUDE)
pops <- as.integer(censDat[-1,1])
refPop <- pops[yr=="2012"]; newPop <- pops[yr=="2015"]
isDecrease <- refPop > newPop
cirSize <- sqrt( (newPop/refPop - 1) * (1 - 2*isDecrease) ) * 80
colorSelect <- c("blue", "red")[1+isDecrease]
head(data.frame(cirSize, colorSelect, stDF))
```

```
    cirSize colorSelect      lat        lng
1  7.098296        blue 33.00810  -86.75683
2  7.612615        blue 61.39988 -148.87397
3 16.180538        blue 33.36827 -111.86431
4  7.676396        blue 35.14258  -92.65524
5 12.864179        blue 35.46359 -119.32536
6 17.869875        blue 39.51342 -105.20806
```
</small>
