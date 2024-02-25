library(shiny)
setwd("C:/Users/Carlos/Desktop/Universidad/CUARTO/TFG/OptoBelopApp") #Cambiar a ruta donde este este script

library(reticulate)
use_condaenv("Optogait", required=TRUE) 


library(DT)
library(shinydashboard)
library(shinyWidgets)
library(ggplot2)
library(readxl)
library(readr)
library(survival)
library(survminer)
library(dplyr)
library(shinyjs)
library(shinycssloaders)
library(graphics)

runApp("App_Files")