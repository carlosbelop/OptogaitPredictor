# Define UI

ui <- dashboardPage(
  
  ## Cabecera de la página ##
  
  dashboardHeader(
    title = "OptoPrediction",
    titleWidth = 300
  ),
  
  ## Barra lateral ##
  
  dashboardSidebar(
 
    fileInput("xml_Optogait_file", label = "Selecciona un archivo xml:",accept = c(".xml"))
  ),
  
  ## Cuerpo de la APP ##
  
  dashboardBody(
    tags$head(
      tags$link(rel="stylesheet",type = "text/css",href="main.css") #No hace falta poner la dirección absoluta, solo con poner la relativa, el programa sabe que está en www
      ),
    useShinyjs(),
    #Creo un panel condicional que se muestra solo si se ha subido un archivo válido
    conditionalPanel(
      condition="output.fileUploaded == true",
      # Titular de la pestaña
    h1("Dataframe del nuevo paciente"),
    
    div(DTOutput("tabla"), style = "margin-bottom: 20px;"), # Tabla que muestra el df
    
    #Botón que se habilita cuando se introduce el Peso, Altura y Nº de Pie
    div(
      fluidRow(
        column(width=2,actionButton("newPredictionButton","Predict", disabled=TRUE)),
        column(width=6,div(id="noPossiblePrediction",textOutput("noPossiblePrediction")))
      )
     ),
    # Gráfico con los resultados que se habilitar cuando se clica el botón de 'Predict'
    conditionalPanel(
      condition="input.newPredictionButton != 0",
      div(plotOutput("prediction") %>% withSpinner(color="#0dc5c1"), style="height: 50px;")
      
      )
    ),
    
  )
 
)
