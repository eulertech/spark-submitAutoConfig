#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
source('global.R')

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tags$head(
    tags$style(HTML("hr {border-top: 1px solid #000000;}"))
  ),
  # Application title
  titlePanel("spark-submit auto configuration with EC2 instance type (LiangK)"),
  hr(),
  p("This application is to select the best spark submit parameters for EMR jobs based on number of instances and the EMR instance type."),
  p("spark-submit --class <CLASS_NAME> --num-executors ? --executor-cores ? --executor-memory ? ...."),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       h3("INPUT Variables"),
       hr(),
       selectInput("instanceListId","Choose EMR instance type",choices = instanceList,selected = "m4.xlarge"),
       textOutput("cpuId", container = if(inline) span else div, inline=FALSE),
       textOutput("memId", container = if(inline) span else div, inline=FALSE),
       hr(),
       sliderInput("numInstanceId",
                   "number of instances (Nodes)",
                   min = 1,
                   max = 200,
                   value = 100,
                   step = 5),
       sliderInput("numExecCoreId",
                   "Number of executor cores per each executor (5 recommended)",
                   min = 1,
                   max = 10,
                   value = 5,
                   step = 1
       ),
       sliderInput("memOverheadId",
                   "Memory overhead % (7% by default,max 20%)",
                   min = 1,
                   max=30,
                   value = 7,
                   step = 1
                   ),
       sliderInput("coreYarnId",
                   "Number of core per node reserved for Hadoop/Yarn (1 recommended)",
                   min = 1,
                   max = 5,
                   value = 1,
                   step = 1
                   ),
       sliderInput("excecutorAMId",
                   "Number of exectors reserved for Application Manager (1 recommended)",
                   min = 1,
                   max = 5,
                   value = 1,
                   step = 1
       )

       
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Reommended Spark Settings", tableOutput("results")),
        tabPanel("README",imageOutput("readmeId")),
        tabPanel("Amazon EMR instance ref table", dataTableOutput("tableId"))
        
      )
    )
  )
))
