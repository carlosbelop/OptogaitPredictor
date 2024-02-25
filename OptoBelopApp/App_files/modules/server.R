# Define server
server <- function(input, output) {

  

# Cargamos los scripts de python (el que procesa el archivo subido y el que predice)
reticulate::source_python('python_funcs/xml_to_df.py')  
reticulate::source_python('python_funcs/predict.py')  
  
    
#Reactive value to get the Data from the file uploaded
  getData <- reactiveValues(df=NULL)
  output$noPossiblePrediction <- renderText("Introduce el Peso, Altura y Nº de Pie")
  
  observeEvent(input$xml_Optogait_file, {
    if(is.null(input$xml_Optogait_file)) 
      getData$df <- NULL
    
    else{
      
      # Obtener la ruta del archivo seleccionado
      file_path <- input$xml_Optogait_file$datapath
      
      withProgress(message="Cargando", value=100,{
        # Cargar los datos de entrada a Python para convertirlos a un formato adecuado (Función obtenida del script anterior)
       getData$df <-  xml_to_df(file_path)
      }) 
    }
  })
  
  #Reactive value for using a conditional panel in the UI (the condition is the file uploaded)
  output$fileUploaded <- reactive({
    return(!is.null(getData$df))
  })
  

    # Usa la función definida en helper.R (render_dt) para renderizar una tabla
    # que sea editable.
    observe({
      data <- getData$df
      output$tabla <- render_dt(
                              getData$df,
                              'cell',
                              TRUE,
                              options = list(
                                # Crea una tabla estandar de html
                                dom = 't',
                                # Crea una barra deslizante para ver las columnas
                                scrollX = TRUE,
                                #Uso JS para introducir un símbolo de warning en aquellos valores nulos
                                columnDefs = list(list(
                                  targets = "_all",
                                  render = JS(
                                    "function(data, type, row, meta) {",
                                    "  if (data === '') {",
                                    "    return '<span style=\" padding: 3px;\"><i class=\"fa-solid fa-triangle-exclamation\" style=\"color: #a21616;\"></i></span>';",
                                    "  } else {",
                                    "    return data;",
                                    "  }",
                                    "}"
                                  )
                                ))
                              )
                              )
                            })

    # save the edit of a cell
    observeEvent(input$tabla_cell_edit, {
      getData$df <<- editData(getData$df, input$tabla_cell_edit, 'tabla')
      #Primera fila de la tabla
      dataRow <- getData$df[1, ]
      #Creo la condicion para que el botón de "Predict" se actualice cada vez que se introduce un valor
      buttonCondition <- (dataRow[[1]]=="") || (dataRow[[2]]=="") || (dataRow[[3]]=="")
      
      if (buttonCondition){
        #desactivar botón e indicar un mensaje con explicación
        shinyjs::disable("newPredictionButton")
        output$noPossiblePrediction <- renderText("Introduce el Peso, Altura y Nº de Pie")
        
      }
      else{
        #activar el botón y quitar el mensaje de explicación
        shinyjs::enable("newPredictionButton")
        output$noPossiblePrediction <- renderText("")
      }
      
    })
    
    observeEvent(input$newPredictionButton,{
      output$prediction <- renderPlot({
        
        # Calculate rounded percentages
        pr <- optoPredict(getData$df)
        percentages <- round(pr[1,],3)*100
        
        # Create a data frame
        data <- data.frame(Category = c("No Fascitis", "Fascitis"),
                           Percentage = percentages)
        
        # Create the barplot using ggplot2
          ggplot(data, aes(Category,Percentage, fill = Category)) +
          geom_bar(stat="identity")+
          labs(title = "Resultados", x = "Categoría", y = "Porcentaje")+
          theme(
            plot.background = element_rect(fill = "#ecf0f5"), 
            panel.border = element_blank(),
            axis.text.y = element_text(face = "bold", size = 11)
            )+
          geom_text(aes(label = paste(Percentage, "%")),data=data, hjust = 1.1, color = "black", size = 4)+
          coord_flip(ylim = c(0, 100)) + # Flip the axes to make it horizontal
          guides(fill = FALSE) # Remove the legend
          
    })
  })
    
    outputOptions(output, 'fileUploaded', suspendWhenHidden=FALSE)
    
}
##### CONSEGUIR QUE SE VEA LA GRÁFICA BIEN SIN QUE SALGA ERROR
##### poner los resultados bonitos
