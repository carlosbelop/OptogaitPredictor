### --- MODULES ---

modules_tabs <- c("global", "helper", "ui", "server")  
for(m in modules_tabs){
  print(paste("Loading server module: ", m, sep=''))
  source(paste("modules/", m , ".R", sep=''), local = TRUE, encoding = "UTF-8")
}


### --- APP ---
shinyApp(ui, server)
               