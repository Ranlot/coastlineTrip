library(shinydashboard)
library(leaflet)

ui <- dashboardPage(
  skin = "yellow",
  dashboardHeader(title = "Your next world tour?", 
                  titleWidth = 350, 
                  dropdownMenu(type = "messages", 
                               icon = icon("search"), 
                               badgeStatus = NULL,
                               headerText = tags$div(class="header",
                                                     checked=NA, 
                                                     tags$p("How to use the app:", style = "color: black; font-size:22px;font-weight:bold;"),
                                                     tags$ul(
                                                       tags$li("Click somewhere close to the coastline of interest", style = "color: black; font-size:16px;"),
                                                       tags$li(tags$div("This will reveal data from the",
                                                                        tags$a(href="http://www.naturalearthdata.com/downloads/", target="_blank", "Natural Earth", style="color:blue; font-size:18px; font-weight:bold;"),
                                                                        "dataset"), style = "color: black; font-size:16px;"),
                                                       tags$li("Click on a point and see where it takes you!", style = "color: black; font-size:16px;"))),
                               notificationItem(tags$p("About me...", style = "color: black; font-size:20px;;font-weight:bold;"), 
                                                icon = icon("linkedin-square"), 
                                                href = "https://il.linkedin.com/in/laurent-boué-b7923853"),
                               notificationItem(tags$p("Source code", style = "color: black; font-size:20px;;font-weight:bold;"), 
                                                icon = icon("github-square"), 
                                                href = "https://github.com/Ranlot"))
                  ),
  dashboardSidebar(width = 350, DT::dataTableOutput("table")),
  dashboardBody(tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                tags$head(tags$style(HTML('.dropdown-menu {background-color:orange;}
                                          .dropdown-menu * {background-color:orange !important;}
                                          '))),
                leafletOutput("map"))
)
