#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(writexl)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  capture.msprog <- purrr::quietly(MSprog)
  capture.criteria_text <- purrr::quietly(criteria_text)
  
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
    
    shinyjs::show(id = "eye_outcome")
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
    shinyjs::show(id = "eye_relapse")
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
    if(is.null(dat())) "Longitudinal assessments not uploaded"
    dat()
  })
  
  output$relapseTab <- renderTable({
    if(is.null(relapse.dat())) "Relapse data not uploaded"
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
  
  update.user.input.message <- reactive({
    shinyjs::hide(id = "input_guide_message_all")
    shinyjs::hide(id = "input_guide_message_outcome_file")
    shinyjs::hide(id = "input_guide_message_outcome_definition")
    shinyjs::hide(id = "input_guide_message_outcome_idcol")
    shinyjs::hide(id = "input_guide_message_outcome_outcol")
    shinyjs::hide(id = "input_guide_message_outcome_datecol")
    
    if (is.null(input$dat) & is.null(input$outcome)) {
      shinyjs::show(id = "input_guide_message_all")
    } else {
      
      if (is.null(input$dat)) {
        shinyjs::show(id = "input_guide_message_outcome_file")
      } else {
        if (input$subj_col == "") {
          shinyjs::show(id = "input_guide_message_outcome_idcol")
        } 
        if (input$value_col == "") {
          shinyjs::show(id = "input_guide_message_outcome_outcol")
        } 
        if (input$date_col == "") {
          shinyjs::show(id = "input_guide_message_outcome_datecol")
        } 
      }
      
      if (is.null(input$outcome)) {
        shinyjs::show(id = "input_guide_message_outcome_definition")
      }
      
     
    }
    

    
  }) 
  
  progs <- bindEvent(reactive({
    
    update.user.input.message()
    
    req(input$dat)
    req(input$subj_col)
    req(input$value_col)
    req(input$date_col)
    req(input$outcome)
    
    shinyjs::show(id = "download_panel")
    shinyjs::show(id = "criteria_description_title")
    shinyjs::show(id = "event_count_title")
    
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
      conf_tol_days = abs(as.numeric(input$conf_tol_days)),
      conf_unbounded_right = input$conf_tol_days[2] == "Unbound",
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
      min_value = switch(is.null(input$min_value), NULL, input$min_value),
      prog_last_visit = FALSE,
      include_dates = TRUE,
      include_value = TRUE,
      include_stable = TRUE,
      verbose = 0
    )
  }),
  input$run_msprog)
  
  # da far scaricare tutte e due
  output$outputTab_details <- renderTable({
    tibble::rownames_to_column(progs()$result$summary, var = input$subj_col)
  })

  output$messages <- renderUI({
    HTML(paste0("<p>",
                capture.criteria_text(progs()$result)$output,
                "</p><br><p>",
                paste(progs()$messages, collapse = "</br>"),
                "</p>"
           ))
  })
  
  output$download <- downloadHandler(
   
    filename = function() {
      paste("MSprog-", Sys.Date(), ".xlsx", sep="")
    },
    
    content = function(file) {
      writexl::write_xlsx(list(
          "Criteria" = data.frame(Description = capture.criteria_text(progs()$result)$output), 
          "Event count" = progs()$result$summary,
          "Event details" = progs()$result$results_df
        ),
        path = file)
    }
  )
  
}