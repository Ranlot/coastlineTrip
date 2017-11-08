library(rgdal)
library(plyr)
library(magrittr)

rawData <- readOGR(dsn="staticData/10m/", layer=paste0("ne_10m_coastline"))
data <- Map(function(shape) { Map(function(part) part@coords %>% as.data.frame, shape@Lines) %>% ldply(data.frame) }, rawData@lines)
db <- data %>% ldply(data.frame)
countries <- readOGR(dsn="staticData/countries10m/", layer="ne_10m_admin_0_countries")