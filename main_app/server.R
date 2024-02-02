#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  capture.msprog <- purrr::quietly(MSprog)
  
  dat <- reactive({
    req(input$dat)
    if (!endsWith(input$dat$name, ".csv")) {
      validate("Invalid file; Please upload a .csv")
    }
    read.csv(input$dat$datapath,
             header = TRUE, 
             row.names = NULL,
             sep = ",",
             strip.white = TRUE,
             na.strings = "")[,-1]
  })
  
  relapse.dat <- reactive({
    if(is.null(input$relapse.dat)) return(NULL)
    if (!endsWith(input$relapse.dat$name, ".csv")) {
      validate("Invalid file; Please upload a .csv")
    }
    read.csv(input$relapse.dat$datapath,
             header = TRUE, 
             row.names = NULL,
             sep = ",",
             strip.white = TRUE,
             na.strings = "")[,-1]
  })
  
  observeEvent(input$dat, {
    updateSelectInput(
      session = session, 
      inputId = 'subj_col', 
      choices  = c("", names(dat()))
    )
    
    updateSelectInput(
      session = session, 
      inputId = 'value_col', 
      choices  = c("", names(dat()))
    )
    
    updateSelectInput(
      session = session, 
      inputId = 'date_col', 
      choices  = c("", names(dat()))
    )
  })
  
  observeEvent(input$relapse.dat, {
    updateSelectInput(
      session = session, 
      inputId = 'rsubj_col', 
      choices  = c("", names(relapse.dat()))
    )
    
    updateSelectInput(
      session = session, 
      inputId = 'rdate_col', 
      choices  = c("", names(relapse.dat()))
    )
  })
  
  observeEvent(input$conf_unbounded_right, {
    if(input$conf_unbounded_right) {
      updateSliderInput(
        session = session, 
        inputId = 'conf_tol_days',
        value = c(input$conf_tol_days[1], 60),
      )
    }
  })
  
  ## observe the button being pressed
  observeEvent(input$advenced_button_on, {
    shinyjs::show(id = "advancedbox")
    shinyjs::show(id = "advenced_button_off")
    shinyjs::hide(id = "advenced_button_on")
  })
  observeEvent(input$advenced_button_off, {
    shinyjs::hide(id = "advancedbox")
    shinyjs::show(id = "advenced_button_on")
    shinyjs::hide(id = "advenced_button_off")
  })
  
  output$inputTab <- renderTable({
    dat()
  })
  
  output$relapseTab <- renderTable({
    relapse.dat()
  })
  
  rsubj_col <- reactive({
    if(is.null(input$relapse.dat)) return(NULL)
    input$rsubj_col
  })
  
  rdate_col <- reactive({
    if(is.null(input$relapse.dat)) return(NULL)
    input$rdate_col
  })
  
  
  progs <- reactive({
    req(input$dat)
    req(input$subj_col)
    req(input$value_col)
    req(input$date_col)
    req(input$outcome)
    
    capture.msprog(
      data = dat(),
      subj_col  = input$subj_col,
      value_col = input$value_col,
      date_col  = input$date_col,
      outcome   = input$outcome,
      subjects = NULL,
      relapse = relapse.dat(),
      rsubj_col = rsubj_col(),
      rdate_col = rdate_col(),
      delta_fun = NULL,
      conf_weeks = input$conf_weeks,
      conf_tol_days = abs(input$conf_tol_days),
      conf_unbounded_right = FALSE,
      require_sust_weeks = input$require_sust_weeks,
      relapse_to_bl = input$relapse_to_bl,
      relapse_to_event = input$relapse_to_event,
      relapse_to_conf = input$relapse_to_conf,
      relapse_assoc = input$relapse_assoc,
      event = ifelse(is.null(input$event), "firstprog", input$event),
      baseline = ifelse(is.null(input$baseline), "fixed", input$baseline),
      relapse_indep = NULL,
      sub_threshold = FALSE,
      relapse_rebl = FALSE,
      min_value = input$min_value,
      prog_last_visit = FALSE,
      include_dates = TRUE,
      include_value = TRUE,
      include_stable = TRUE,
      verbose = 1
    )
  })
  
  # da far scaricare tutte e due
  output$outputTab_details <- renderTable({
    progs()$result[2]
  })
  
  output$messages <- renderUI({
    out <- paste(progs()$messages, collapse = "</br>")
    HTML(out)
  })
  
}