#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# install msprog package
# devtools::install_github("noemimontobbio/msprog")

# load libraries
library(shiny)   # to run the web app
library(writexl) # to export excel files
library(shinyBS) # to include alert and multiple pages
library(msprog)  # to compute progression

# Define server logic required to draw a histogram
function(input, output, session) {
  
  # make sure that msprog is available at the beginning of the session
  require(msprog)
  
  # define function to capture printed text in MSprog
  capture.msprog <- purrr::quietly(msprog::MSprog)
  
  # define function to capture printed text in MSprog
  capture.criteria_text <- purrr::quietly(print)
  
  
  # Data loader ----------------------------------------------------
  ## Event data ----------------------------------------------------
  # define event data source as a reactive data frame
  dat <- reactive({
    
    # to be created require the input file
    req(input$dat)
    
    # check if the format is .csv
    if (!endsWith(input$dat$name, ".csv")) {
      # otherwise prompt an error
      validate("Invalid file; Please upload a .csv")
    }
    
    # read the first line of the file to get .csv format details
    first.line <- readLines(input$dat$datapath, n = 1)

    # if the .csv format has semicolon(s) and not comma(s) rise an alert message
    if(grepl(";", first.line) & !grepl(",", first.line)) {
      shinyBS::createAlert(
        session = session, 
        anchorId = "outcome_data_block",
        title = "Something might be wrong...",
        content = "Double check if the CSV file is in the correct format (i.e. with a comma and not a semicoln separating the values)")
    }

    # read the csv source and skip row names
    read.csv(
      file = input$dat$datapath,
      header = TRUE,
      row.names = NULL,
      sep = ",",
      strip.white = TRUE,
      na.strings = ""
    )[,-1]
  })
  
  ## Relapse data ----------------------------------------------------
  # define relapse data source as a reactive data frame
  relapse.dat <- reactive({
    
    # since is optional return null if file was not uploaded
    if(is.null(input$relapse.dat)) return(NULL)

    # check if the format is .csv
    if (!endsWith(input$relapse.dat$name, ".csv")) {
      # otherwise prompt an error
      validate("Invalid file; Please upload a .csv")
    }
    
    # read the csv source and skip row names
    read.csv(input$relapse.dat$datapath,
             header = TRUE, 
             row.names = NULL,
             sep = ",",
             strip.white = TRUE,
             na.strings = "")[,-1]
  })
  
  # Column selection -----------------------------------------------
  ## Event data ----------------------------------------------------
  # when event file is loaded
  observeEvent(input$dat, {
    
    # update the corresponding select input of SUBJECT with the 
    # column names of the event data frame
    updateSelectInput(
      session = session, 
      inputId = 'subj_col', 
      choices  = c("", names(dat()))
    )
    
    # update the corresponding select input of VALUE with the 
    # column names of the event data frame
    updateSelectInput(
      session = session, 
      inputId = 'value_col', 
      choices  = c("", names(dat()))
    )
    
    # update the corresponding select input of DATE with the 
    # column names of the event data frame
    updateSelectInput(
      session = session, 
      inputId = 'date_col', 
      choices  = c("", names(dat()))
    )
    
    # show event data preview button
    shinyjs::show(id = "eye_outcome")
  })
  
  ## Relapse data ----------------------------------------------------
  # when relapse file is loaded
  observeEvent(input$relapse.dat, {
    
    # update the corresponding select input of SUBJECT with the 
    # column names of the event data frame
    updateSelectInput(
      session = session, 
      inputId = 'rsubj_col', 
      choices  = c("", names(relapse.dat()))
    )
    
    # update the corresponding select input of DATE with the 
    # column names of the event data frame
    updateSelectInput(
      session = session, 
      inputId = 'rdate_col', 
      choices  = c("", names(relapse.dat()))
    )
    
    # show relapse data preview button
    shinyjs::show(id = "eye_relapse")
  })

  # Advance settings ----------------------------------------------------
  
  # when opening advance button is pressed
  observeEvent(input$advenced_button_on, {
    
    # show advance setting
    shinyjs::show(id = "advancedbox")
    
    # show the button to close advance setting
    shinyjs::show(id = "advenced_button_off")
    
    # hide the button to open advance setting
    shinyjs::hide(id = "advenced_button_on")
  })
  
  # when closing advance button is pressed
  observeEvent(input$advenced_button_off, {
    
    # hide advance setting
    shinyjs::hide(id = "advancedbox")
    
    # show the button to open advance setting
    shinyjs::show(id = "advenced_button_on")
    
    # hide the button to close advance setting
    shinyjs::hide(id = "advenced_button_off")
  })
  
  # User messages --------------------------------------------------------

  # if event data is not uploaded ask for event data
  output$inputTab <- renderTable({
    if(is.null(dat())) "Longitudinal assessments not uploaded"
    dat()
  })
  
  # if relapse data is not uploaded ask for relapse data
  output$relapseTab <- renderTable({
    if(is.null(relapse.dat())) "Relapse data not uploaded"
    relapse.dat()
  })
  
  # if relapse subject column is not uploaded ask for relapse subject column
  rsubj_col <- reactive({
    if(is.null(input$relapse.dat)) return(NULL)
    input$rsubj_col
  })
  
  # if relapse date column is not uploaded ask for relapse date column
  rdate_col <- reactive({
    if(is.null(input$relapse.dat)) return(NULL)
    input$rdate_col
  })
  
  # define when to show the prompts asking for missing information
  update.user.input.message <- reactive({
    
    # start making all invisible
    shinyjs::hide(id = "input_guide_message_all")
    shinyjs::hide(id = "input_guide_message_outcome_file")
    shinyjs::hide(id = "input_guide_message_outcome_definition")
    shinyjs::hide(id = "input_guide_message_outcome_idcol")
    shinyjs::hide(id = "input_guide_message_outcome_outcol")
    shinyjs::hide(id = "input_guide_message_outcome_datecol")
    
    # ask only if necessary
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
  
  # Computation -------------------------------------------------------------
  
  # Power Horse function. it computes msprog.
  progs <- bindEvent(reactive({
    
    update.user.input.message()
    
    # require the presence of event data
    req(input$dat)
    
    # require the presence of event SUBJECT column
    req(input$subj_col)
    
    # require the presence of event VALUE column
    req(input$value_col)
    
    # require the presence of event DATE column
    req(input$date_col)
    
    # require the presence of event outcome selection
    req(input$outcome)
    
    # make output panels visible
    shinyjs::show(id = "download_panel")
    shinyjs::show(id = "criteria_description_title")
    shinyjs::show(id = "event_count_title")
    
    # actually compute
    capture.msprog(
      data = dat(),
      subj_col = input$subj_col,
      value_col = input$value_col,
      date_col = input$date_col,
      outcome = input$outcome,
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
      prog_last_visit = as.logical(input$prog_last_visit),
      check_intermediate = as.logical(input$check_intermediate),
      include_dates = TRUE,
      include_value = TRUE,
      include_stable = TRUE,
      verbose = 0
    ) 
  }),
  
  # bind the previous function is to user pressing the compute button.
  # [note: this is a custom behavior]
  # [note: shiny is force not to auto-update]
  input$run_msprog)
  
  # generate the results data.frame
  output$outputTab_details <- renderTable({
    
    # read the msprog summary results table
    outs <- progs()$result$event_count
    
    # adapt the output to different calculations behavior
    # use row names as a subject identifier column
    outs <- tibble::rownames_to_column(outs)
    
    # rename the "rowname" column using the same column name of the original data source
    if("rowname" %in% names(outs)) {
      names(outs)[which(names(outs) == "rowname")] <- input$subj_col
    }
    
    # in case the result table has only two columns
    if(length(names(outs)) == 2) {
      
      # name the second one as the selected event type
      names(outs)[2] <- input$event
    }
    
    # visualize the data.frame
    outs
  })

  # write a message to user in HTML
  output$messages <- renderUI({
    HTML(paste0(
      # add a paragraph on textual criteria
      "<p>",capture.criteria_text(progs()$result)$output, 
      
      # and a second spaced paragraph
      "</p><br><p>",
      
      # of MSprog messages
      paste(print(progs()$result), collapse = "</br>"),"</p>"))
  })
  
  # enable user to download the computed progressions
  output$download <- downloadHandler(
   
    # generate a filename
    filename = function() {
      paste("MSprog-", Sys.Date(), ".xlsx", sep="")
    },
    
    # create a multi sheet excel file
    content = function(file) {
      writexl::write_xlsx(list(
          
          # with criteria in the first sheet
          "Criteria" = data.frame(Description = capture.criteria_text(progs()$result)$output), 
          
          # MSprog summary results in the second sheet
          "Event count" = setNames(cbind(
            unique(dat()[, input$subj_col]), # ask noemi
            progs()$result$event_count), 
            c(input$subj_col, names(progs()$result$event_count))),
          
          # and MSprog detailed results in the third sheet
          "Event details" = progs()$result$results
        ),
        path = file)
    }
  )
  
}