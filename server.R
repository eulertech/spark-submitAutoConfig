#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(png)
source('global.R')

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$results <- renderTable({
    recNumCorePerExecutor <- as.integer(input$numExecCoreId)
    vCorePerInstance <- as.integer(as.character(instance[instance$Model == input$instanceListId,2]))
    memoryPerInstance <-  as.integer(as.character(instance[instance$Model == input$instanceListId,3]))
    totalCore <- as.integer(input$numInstanceId) * vCorePerInstance
    totalMem <- as.integer(input$numInstanceId) * memoryPerInstance
    totalAvailCores <- (vCorePerInstance - input$coreYarnId) * input$numInstanceId
    numAvailExecutors <- max(1,ceiling(totalAvailCores/recNumCorePerExecutor) - input$excecutorAMId) # -num-executors
    numExecutorPerNode <- max(1,numAvailExecutors/input$numInstanceId)   
    memPerExecutor <- memoryPerInstance/numExecutorPerNode      # -- executor-memory 
    memWOverhead <- memPerExecutor * (1 - input$memOverheadId/100) 
    numParitions <- memPerExecutor * as.integer(input$numExecCoreId) # -- num partitions
    
    # save it to a dataframe
    namesList = c("num-executors","executor-memory(GB)","executor-cores",
                  "num-partitions","total cores","total memory (cluster)")

    results <- data.frame(
      "parameters" = namesList,
      "optimal values" = c(numAvailExecutors,memWOverhead,input$numExecCoreId, numParitions,totalCore,totalMem)
    )
    
  })
  output$readmeId <- renderImage({
    return(list(
      src = "www/readme.PNG",
      contentType = "image/png",
      alt = "readme"
    ))},deleteFile = FALSE)
  output$tableId <- renderDataTable({instance})
  output$cpuId <- renderText({paste("vGPU cores: ", as.character(instance[instance$Model == input$instanceListId,2]))})
  
  output$memId <- renderText({paste("Memory (GB): ", as.character(instance[instance$Model == input$instanceListId,3]))})
  
  output$submitId <- renderText({
    recNumCorePerExecutor <- as.integer(input$numExecCoreId)
    vCorePerInstance <- as.integer(as.character(instance[instance$Model == input$instanceListId,2]))
    memoryPerInstance <-  as.integer(as.character(instance[instance$Model == input$instanceListId,3]))
    totalCore <- as.integer(input$numInstanceId) * vCorePerInstance
    totalMem <- as.integer(input$numInstanceId) * memoryPerInstance
    totalAvailCores <- (vCorePerInstance - input$coreYarnId) * input$numInstanceId
    numAvailExecutors <- max(1,ceiling(totalAvailCores/recNumCorePerExecutor) - input$excecutorAMId) # -num-executors
    numExecutorPerNode <- max(1,numAvailExecutors/input$numInstanceId)   
    memPerExecutor <- memoryPerInstance/numExecutorPerNode      # -- executor-memory 
    memWOverhead <- memPerExecutor * (1 - input$memOverheadId/100) 
    numParitions <- memPerExecutor * as.integer(input$numExecCoreId) # -- num partitions
    commandString <- sprintf("spark-submit --class <CLASS_NAME> --num-executors %s --executor-cores %s --executor-memory %10.0fMB --driver-memory %10.0fMB --master yarn --deploy-mode client",
                             numAvailExecutors, input$numExecCoreId, memWOverhead * 1000,memoryPerInstance*0.6*.9*1000)
    # driver memory = The default values of spark.storage.memoryFraction and spark.storage.safetyFraction are respectively 0.6 and 0.9 so the real executorMemory
    #https://umbertogriffo.gitbooks.io/apache-spark-best-practices-and-tuning/content/sparksqlshufflepartitions_draft.html
#    commandString <- paste("<font color=\"#FF0000\"><b>", commandString, "</b></font>")
    })
  
})
