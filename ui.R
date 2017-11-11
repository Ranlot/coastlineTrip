library(shinydashboard)
library(leaflet)

ui <- dashboardPage(
  skin = "yellow",
  dashboardHeader(title = "Your next world tour?", 
                  titleWidth = 350, 
                  dropdownMenu(type = "messages", 
                               icon = icon("search", class = 'icon'), 
                               badgeStatus = NULL,
                               headerText = tags$div(class="header",
                                                     checked=NA, 
                                                     tags$ul(
                                                       tags$li("Click somewhere close to the coastline of interest.", style = "color: black; font-size:16px;"),
                                                       tags$li(tags$div("This will reveal data from the Natural Earth",
                                                                        tags$a(href="http://www.naturalearthdata.com/downloads/", target="_blank", "dataset.", style="color:blue; font-size:18px; font-weight:bold;")),
                                                                        style = "color: black; font-size:16px;"),
                                                       tags$li("Click on a point representing the beach you'll be leaving from.", style = "color: black; font-size:16px;"),
                                                       tags$li("Imagine you're standing on this beach and facing straight out to the sea, it will show you where your next world tour will take you to!", 
                                                               style = "color: black; font-size:16px; font-weight:bold;")
                                                       )
                                                     ),
                               notificationItem(tags$p("About me...", style = "color: black; font-size:20px;"), 
                                                icon = icon("linkedin-square"), 
                                                href = "https://il.linkedin.com/in/laurent-boué-b7923853"),
                               notificationItem(tags$p("Source code", style = "color: black; font-size:20px;"), 
                                                icon = icon("github-square"), 
                                                href = "https://github.com/Ranlot"))
                  ),
  dashboardSidebar(width = 350, DT::dataTableOutput("table")),
  dashboardBody(tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                tags$head(tags$style(HTML('.dropdown-menu {background-color:orange;}
                                          .dropdown-menu * {background-color:orange !important;}
                                          .icon::before{content:"How to use the app"; color:black; font-size:20px; font-weight:bold;}
                                          '))),
                leafletOutput("map"),
                tags$head(includeScript("google-analytics.js")))
)
