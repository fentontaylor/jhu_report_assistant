library(shiny)

users <- paste0("User", 1:4)
shinyUI(fluidPage(
  
  titlePanel("Report-Writing Assistant"),
  
  sidebarLayout(
    sidebarPanel(
       selectInput("user", "Select user:", users),
       selectInput("dbPreference", "Search which database?", c("Accuracy", "Speed")),
       sliderInput("maxResults", "Max number of predictions:", min = 1, max = 10, step = 1, value = 5),
       checkboxInput("showDetails", "Show Prediction Details", value = TRUE)
    ),
    
    mainPanel(
        textInput("text", label="Text Input"),
        textOutput("prediction")
    )
  )
))
