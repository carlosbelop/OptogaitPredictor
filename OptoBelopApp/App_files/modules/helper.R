#function for creating a editable datatable
# parámetro editable={'cell', 'all', 'row', 'column'} dependiendo de lo que quieras que se pueda editar
render_dt = 
  function(data, editable = 'cell', server = TRUE, ...) {
  DT::renderDT(data, selection = 'none', server = server, editable = editable, ...)
}