library(geosphere)
library(htmltools)
library(zeallot)
library(yaImpute)
library(DT)

getCoastlineNeighbors <- function(pointOfInterest) {
  numbNeighbors <- 20
  
  panelOfPoints <- db[ann(as.matrix(db), 
                          as.matrix(list("V1" = pointOfInterest$lng, "V2" = pointOfInterest$lat) %>% as.data.frame), 
                          k=numbNeighbors)$knnIndexDist[1, 1:numbNeighbors], ]
  
  panelOfPoints$group <- "panel"
  panelOfPoints$layerId <- rownames(panelOfPoints)
  panelOfPoints
}

getRelevantNeighbors <- function(clickerMarker) {
  indexOfDeparture <- clickerMarker$id
  pointOfDeparture <- db[indexOfDeparture, ]
  indexOfNeighbor1 <- as.character(indexOfDeparture %>% as.integer - 1)
  indexOfNeighbor2 <- as.character(indexOfDeparture %>% as.integer + 1)
  relevantNeighbors <- db[c(indexOfNeighbor1, indexOfNeighbor2), ]
  relevantNeighbors$label <- formatLabel(relevantNeighbors)
  list(pointOfDeparture, relevantNeighbors)
}

formatLabel <- function(data, ...) {
  lapply(paste(sep = "<br/>", ..., paste0("lat = ", data$V2 %>% round(2)), paste0("lng = ", data$V1 %>% round(2))), HTML)
}

findConnectingPoint <- function(pointOfDeparture, relevantNeighbors) {
  neighborsPath <- gcIntermediate(relevantNeighbors[1, c("V1", "V2")], relevantNeighbors[2, c("V1", "V2")], n=100, sp=T)
  neighborsPathData <- neighborsPath@lines[[1]]@Lines[[1]]@coords %>% as.data.frame
  pointToConnect <- apply(neighborsPathData, 1, function(lonlat) distCosine(pointOfDeparture, lonlat)) %>% which.min
  list(neighborsPath, neighborsPathData[pointToConnect, ])
}

server <- function(input, output) {
  
  values <- reactiveValues(panelOfPoints = data.frame(), visitedCountries = data.frame())
  visitedCountriesSize <- reactive(dim(values$visitedCountries)[1])
  
  output$table <- DT::renderDataTable( if(visitedCountriesSize() > 1)   
    { DT::datatable(values$visitedCountries, escape = F, rownames = F, options=list(lengthMenu = 3, ordering = F, searching=F, paging=F)) %>%
      formatStyle(columns = 1, backgroundColor = 'orange', color = 'black', fontWeight = 'bold') %>%
      formatStyle(columns = 2, backgroundColor = 'gray') })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      setView(-0.580816, 44.836151, zoom = 8) %>%
      addProviderTiles(providers$Esri.WorldImagery, options = list(noWrap=T)) %>% 
      addProviderTiles("CartoDB.PositronOnlyLabels", options = list(noWrap=T)) %>%
      addTerminator()
  })
  
  observeEvent(input$map_click, {
    
    removeUI("table")
    
    pointOfInterest <- input$map_click
    values$panelOfPoints <- getCoastlineNeighbors(pointOfInterest)
    
    leafletProxy('map') %>% 
      clearMarkers() %>%
      clearPopups() %>%
      removeShape(layerId = c('aroundTheWorld', 'neighborsPath')) %>%
      addCircleMarkers(values$panelOfPoints$V1, 
                       values$panelOfPoints$V2, 
                       label = formatLabel(values$panelOfPoints),
                       labelOptions = labelOptions(style = list("background-color" = "orange")),
                       group = values$panelOfPoints$group, 
                       layerId = values$panelOfPoints$layerId, 
                       popup = values$panelOfPoints$layerId,
                       color = "orange", fillColor = "orange", opacity = 1, weight = 4, fillOpacity = 0.4)
  })
  
  observeEvent(input$map_marker_click, {

    clickerMarker <- input$map_marker_click
    
    if(clickerMarker$id %>% is.null) {
      leafletProxy('map') %>%
        clearMarkers() %>%
        addPopups(clickerMarker$lng, 
                  clickerMarker$lat, 
                  "Please make another selection by clicking on the map", 
                  layerId = "anotherSelection",
                  options = popupOptions(closeButton = FALSE, opacity=0.4 )
        )
      return()
    }
    
    # TODO: handle exception when this fails
    c(pointOfDeparture, relevantNeighbors) %<-% getRelevantNeighbors(clickerMarker)
    #print(relevantNeighbors)
    
    neighborsPath <- gcIntermediate(relevantNeighbors[1, c("V1", "V2")], relevantNeighbors[2, c("V1", "V2")], n=100, sp=T)
    startBearing <- bearing(relevantNeighbors[1, c("V1", "V2")], relevantNeighbors[2, c("V1", "V2")])
    endBearing <- finalBearing(relevantNeighbors[1, c("V1", "V2")], relevantNeighbors[2, c("V1", "V2")])
    
    gc <- greatCircleBearing(pointOfDeparture, 0.5 * (startBearing + endBearing) + 90, n=2000)
    worldTourData <- gc %>% as.data.frame
    colnames(worldTourData) <- c("V1", "V2")
    
    c(maxNorth, maxSouth) %<-% list(worldTourData[worldTourData$V2 %>% which.max, ], worldTourData[worldTourData$V2 %>% which.min, ])
    
    worldTour <- SpatialPoints(worldTourData)
    proj4string(worldTour) <- proj4string(countries)
    augmentedWorldTour <- sp::over(worldTour, countries)
    
    if(resolution == 10) {
      visitedCountries <- unique(augmentedWorldTour$NAME) %>% na.omit %>% as.data.frame
    } else {
      visitedCountries <- unique(augmentedWorldTour$name) %>% na.omit %>% as.data.frame
    }
    
    visitedCountries$flag <- apply(visitedCountries, 1, 
                                   function(row) paste0('<img src="', strsplit(row[[1]], " ")[[1]] %>% paste(collapse = '_'), '.svg" height="40"></img>'))
    
    colnames(visitedCountries) <- c("", "")
    values$visitedCountries <- visitedCountries
    
    #--------------------------------
    
    leafletProxy('map') %>% 
      clearMarkers()    %>%
      addCircleMarkers(relevantNeighbors$V1, relevantNeighbors$V2, group = "selected",
                       label = relevantNeighbors$label,
                       labelOptions = labelOptions(style = list("background-color" = "orange")),
                       color = "orange", fillColor = "orange", opacity = 1, weight = 3, fillOpacity = 0.4) %>%
      addCircleMarkers(pointOfDeparture$V1, pointOfDeparture$V2, group = "selected",
                       label = HTML(paste(sep = "<br/>", "Point of departure", 
                                          paste0("lat = ", pointOfDeparture$V2 %>% round(2)),
                                          paste0("lng = ", pointOfDeparture$V1 %>% round(2)))),
                       labelOptions = labelOptions(style = list("background-color" = "salmon")),
                       color = "red", fillColor = "red", opacity = 1, weight = 6, fillOpacity = 0.4) %>%
      addCircleMarkers(maxNorth$V1, maxNorth$V2, 
                       label = formatLabel(maxNorth, "Northernmost position"), color = "green", 
                       labelOptions = labelOptions(style = list("background-color" = "lightgreen"))) %>%
      addCircleMarkers(maxSouth$V1, maxSouth$V2, 
                       label = formatLabel(maxSouth, "Southernmost position"), color = "green",
                       labelOptions = labelOptions(style = list("background-color" = "lightgreen"))) %>%
      addPolylines(data = gc, layerId = 'aroundTheWorld', color = 'red', weight = 6, opacity = 0.7) %>%
      addPolylines(data = neighborsPath, layerId = 'neighborsPath', color = 'orange', weight = 3, opacity = 0.7)
  })
  
}
