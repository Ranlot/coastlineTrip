library(shiny)
library(shinydashboard)
library(DT)

shinyApp(
  ui = dashboardPage(
    skin="yellow",
    dashboardHeader(
      title = "wv ji", 
      titleWidth = 350, 
      dropdownMenu(
        type = "messages", 
        icon = icon("search", class="icon"),
        badgeStatus = NULL,
        headerText = tags$div(
          class="header", 
          checked=NA, 
          tags$p("Description:", style = "color: black;"),
          tags$ul(
            tags$li("main panel", style = "color: black; font-size:20px;"),
            tags$li("tag1", class("test111")),
            tags$li("tag2")),
          tags$div(
            class="linkDiv",
            tags$i(class="fa fa-question fa-2x"),
            tags$a("mylink",class="mylink", href = "http://google.com", target="_blank"))
          )
        
        #notificationItem("another", icon = icon("question-mark"),  href = tags$a("http://google.com"))
      )
                  
    ), 
    dashboardSidebar(), 
    dashboardBody(
      tags$head(tags$style(HTML('
      .dropdown-menu {background-color:orange;}
      .dropdown-menu * {background-color:orange !important;}
      .icon::before{content:" bla bla"; color:blue; font-size:20px;}
      .dropdown-menu .mylink { margin-left:10px; color:red !important; text-decoration:none;}
      .dropdown-menu .mylink:hover{  color:black !important; text-decoration:underline;}
      .dropdown-menu .linkDiv {padding-left:20px; margin-top:10px;}
      ')))
    )
  ),
  server = function(input, output, session) {}
)
