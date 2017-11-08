library(rgdal)
library(plyr)
library(magrittr)

resolution <- 10
rawData <- readOGR(dsn=paste0("staticData/", resolution, "m/"), layer=paste0("ne_", resolution, "m_coastline"))
data <- Map(function(shape) { Map(function(part) part@coords %>% as.data.frame, shape@Lines) %>% ldply(data.frame) }, rawData@lines)
db <- data %>% ldply(data.frame)
countries <- readOGR(dsn=paste0("staticData/countries", resolution, "m/"), layer=paste0("ne_", resolution, "m_admin_0_countries"))
