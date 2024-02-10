# install required packages if needed
if (!require(msprog)) {
  devtools::install_github("noemimontobbio/msprog")
  library(msprog)
}

library(shiny)
library(shinyjs)

# Define UI for application that draws a histogram
fluidPage(
  
  # Application title
  titlePanel(
    title = "MSprog",
    windowTitle = "MSprog"
    ),
  
  h3("Compute multiple sclerosis progression from longitudinal data."),
  HTML("Identify and characterize the progression or improvement events
        of an outcome measure across the data of one or more subject. 
        The procedure utilizes repeated assessments 
        over time and considers the dates of acute episodes. Customize 
        results by setting qualitative and quantitative options, and
        enhance reproducibility.<br><br>
       <i>Please input the required information; mandatory fields are
       marked with an asterisk (*)</i><br>"),
  
  HTML("<br>"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    
    div(
    sidebarPanel(width = 6,
                 
      useShinyjs(),
      
        # Import outcome data ----------------------------------------------------
        div(style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
            
          # File
          h4("Import outcome data*"),
          HTML("Choose or drag and drop here a <b>CSV file</b> with longitudinal 
            assessments of an outcome measure (e.g., EDSS) for one or more
            patients (<a href=''>read more</a>).
            <br>
            <i>Note: the outcome file should contain at least the following columns: 
            individual subject identifier, outcome values, and date of visits.</i>"),
          fileInput(inputId = "dat", label = "", multiple = FALSE, accept = ".csv"),
          
          # Columns
          HTML("Specify the column names corresponding in your outcome file to the required columns.<br>"),
          HTML("<br>"),
          div(style="display: inline-block;vertical-align:top; width: 30%;",
            selectInput(inputId = "subj_col", label = "Subject ID", choices = c(""))
            ),
          div(style="display: inline-block;vertical-align:top; width: 30%;",
            selectInput(inputId = "value_col", label = "Outcome value", choices = c(""))
          ),
          div(style="display: inline-block;vertical-align:top; width: 30%;",
            selectInput(inputId = "date_col", label = "Date of visit", choices = c(""))
          )
        ),
        
        # Import relapse data ----------------------------------------------------
        # File
        div(style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
          h4("Import relapse data (optional)"),
          HTML("Choose or drag and drop here a <b>CSV file</b> with the dates of 
             relapses (<a href=''>read more</a>). 
             <br>
             <i>Note: the relapse file should contain at least the following columns: 
             individual subject identifier, date of relapse.</i>"),
          fileInput(inputId = "relapse.dat", label = "", 
                    multiple = FALSE, accept = c(".csv")),
          
          # Columns
          HTML("Specify the column names corresponding in your relapse file to the required columns.<br>"),
          HTML("<br>"),
          div(style="display: inline-block;vertical-align:top; width: 49.4%;",
              selectInput(inputId = "rsubj_col", label = "Subject ID", choices = c(""))
          ),
          div(style="display: inline-block;vertical-align:top; width: 49.4%;",
              selectInput(inputId = "rdate_col", label = "Date of visit", choices = c(""))
          )
        ),
        
        # Outcome ----------------------------------------------------------------
        div(style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
          h4("Outcome definition*"),
          HTML("Specify the outcome type.
               <br>This selection is associated to a
                minimum delta corresponding to a valid change from the provided 
                baseline value (<a href=''>more options</a>).<br>"),
          HTML("<br>"),
          radioButtons(
            inputId = "outcome",
            label = "Pick one of the options",
            choices = c(
              "Expanded Disability Status Scale (EDSS)" = "edss", 
              "Nine-Hole Peg Test (NHPT)" = "nhpt", 
              "Timed 25-Foot Walk (T25FW)" = "t25fw",
              "Symbol Digit Modalities Test (SDMT)" = "sdmt"
              ),
            selected = NA
          )
        ),
        
        # Event ------------------------------------------------------------------
        div(style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
            h4("Event definition"),
          HTML("Specify the event setting of interest.<br>"),
          HTML("<br>"),
          radioButtons(
            inputId = "event",
            label = "Pick one of the options",
            choices = c(
              "First progression" = "firstprog",
              "First relapse-associated worsening (RAW)" = "firstRAW",
              "First progression independent of relapse activity (PIRA)" = "firstPIRA",
              "First progression of each kind (PIRA, RAW, and undefined), in chronological order" = "firstprogtype",
              "First improvement and first progression, in chronological order" = "firsteach",
              "Only the very first event (improvement or progression)" = "first",
              "All events, in chronological order" = "multiple"
              ),
            selected = NA
          )
        ),
        
        # Baseline ---------------------------------------------------------------
        div(style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
            h4("Baseline definition"),
            HTML("Specify a baseline scheme. <br>
                  <i>Note: to discard fluctuations around baseline for a 
                first-progression setting, the second option is more suitable, while 
                for a multiple-event setting the third option is more suitable.</i><br>"),
            HTML("<br>"),
            radioButtons(
              inputId = "baseline",
              label = "Pick one of the options",
              choices = c(
                "First valid outcome value" = "fixed",
                "Updated every time the value is lower than the previous 
                measure and confirmed at the following visit" = "roving_impr",
                "Updated after each event to last valid confirmed outcome value" = "roving"
              ),
              selected = NA
            )
        ),
        
        # Confirmation -----------------------------------------------------------
        div(style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
            h4("Confirmation definition"),
            HTML("Confirmation is defined as an 
                 event assessed within a specific time interval from the event onset.
                 <br><i>Note: higer intervals improve the stability of event
                 detection but is likely to decrease their number.</i><br>"),
            HTML("<br>"),
            HTML("<hr>"),
            sliderInput(
              inputId = "conf_weeks",
              label = "Specify the confirmation interval",
              min = 0,
              max = 96,
              value = 12,
              step = 1,
              post = " weeks"
            ),
            HTML("<hr>"),
            sliderInput(
              inputId = "conf_tol_days",
              label = "Specify the tolerance window for the confirmation interval",
              min = -60,
              max = 60,
              value = c(-30, 30),
              post = " days"
            ),
            HTML("<hr>"),
            # sposta conf_tol_days dx 
            radioButtons(
              inputId = "conf_unbounded_right",
              label = 'Do you want the confirmation window to be unbounded on 
              the right? (e.g., "confirmed at 12 weeks or more")',
              choices = c("Yes" = T, "No" = F),
              selected = NA
              ),
            
        ),
  
        # Other ------------------------------------------------------------------
        hidden(
          div(id = 'advancedbox', style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
            numericInput(
              "require_sust_weeks",
              "Minimum number of weeks for which a confirmed change must be sustained to be retained as an event.",
              min = 0,
              max = 53,
              value = 0,
              step = 1
            ),
            
            numericInput(
              "relapse_to_bl",
              "Minimum distance from last relapse (days) for a visit to be used as baseline (otherwise the next available visit is used as baseline).",
              min = 0,
              max = 365,
              value = 30,
              step = 30
            ),
            
            numericInput(
              "relapse_to_event",
              "Minimum distance from last relapse (days) for an event to be considered as such.",
              min = 0,
              max = 365,
              value = 0,
              step = 30
            ),
            
            numericInput(
              "relapse_to_conf",
              "Minimum distance from last relapse (days) for a visit to be a valid confirmation visit.",
              min = 0,
              max = 365,
              value = 30,
              step = 30
            ),
            
            numericInput(
              "relapse_assoc",
              "Maximum distance from last relapse (days) for a progression event to be considered as RAW.",
              min = 0,
              max = 365,
              value = 90,
              step = 30
            ),
            
            selectInput(
              "subjects",
              "Subset of subjects to include",
              choices = c("Include all")
            ),
            
            numericInput(
              "min_value",
              "Outcome theshold above which consider progressions events",
              value = 0
            ),
      )),
      
      div(style = "text-align: center; margin:10px",
          actionButton(inputId = "advenced_button_on", label = "Advanced setting"),
          hidden(
            actionButton(inputId = "advenced_button_off", label = "Close advanced setting")
          )
      ),
      
      div(style = "text-align: center;",
          actionButton(inputId = "run_msprog", label = "Compute")
      )
      ),
  
    ),
    
    
    # which information do you want to download:
    # 1. Extended event report [csv ottenuto da results(output)]
    # 2. Event count [csv ottenuto da event_count(output)]
    # 3. Textual description of criteria used, to be reported to 
    # ensure reproducibility
    mainPanel(width = 6,
      div(#style = "display:block;overflow:scroll;height: 400px",
        tableOutput("inputTab"),
      ),
      div(#style = "display:block;overflow:scroll;height: 400px",
          tableOutput("relapseTab"),
      ),
      tableOutput("outputTab_details"),
      htmlOutput("messages"),
      hidden(div(id = "download_panel",
          inputPanel(downloadButton(outputId = "download"))
      ))
    ),
  ),
)
