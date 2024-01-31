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
    
    sidebarPanel(width = 7,
        
      # Import outcome data ----------------------------------------------------
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
      div(style="display: inline-block;vertical-align:top; width: 32%;",
        selectInput(inputId = "subj_col", label = "Subject ID", choices = c(""))
        ),
      div(style="display: inline-block;vertical-align:top; width: 32%;",
        selectInput(inputId = "value_col", label = "Outcome value", choices = c(""))
      ),
      div(style="display: inline-block;vertical-align:top; width: 32%;",
        selectInput(inputId = "date_col", label = "Date of visit", choices = c(""))
      ),
      HTML("<hr>"),
      
      # Import relapse data ----------------------------------------------------
      # File
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
      ),
      HTML("<hr>"),
      
      # Outcome ----------------------------------------------------------------
      h4("Outcome definition*"),
      HTML("Specify the outcome type. This selection is associated to a
            minimum delta corresponding to a valid change from the provided 
            baseline value (<a href=''>more options</a>). 
            <br>
            <i>[pick one of the options]</i>"),
      radioButtons(
        inputId = "outcome",
        label = "",
        choices = c(
          "Expanded Disability Status Scale (EDSS)" = "edss", 
          "Nine-Hole Peg Test (NHPT)" = "nhpt", 
          "Timed 25-Foot Walk (T25FW)" = "t25fw",
          "Symbol Digit Modalities Test (SDMT)" = "sdmt"
          ),
        selected = NA
      ),
      HTML("<hr>"),
      
      
      
      
      selectInput(
        inputId = "event",
        label = "",
        multiple = FALSE,
        choices = c("firstprog", "first", "firsteach", "firstprogtype",
                    "firstPIRA", "firstRAW", "multiple")
      ),

      
      sliderInput(
        "conf_weeks",
        "Period before confirmation (weeks):",
        min = 0,
        max = 96,
        value = 12,
        step = 1
      ),
      
      
      # aggiusta il meno
      sliderInput(
        "conf_tol_days",
        "Tolerance window for confirmation visit (days)",
        min = -60,
        max = 60,
        value = c(-30, 30)
      ),
      
      # aggiusta label
      # sposta conf_tol_days dx 
      checkboxInput("conf_unbounded_right",
                    'Do you want the confirmation window to be unbounded on the right? (e.g., "confirmed at 12 weeks or more")'),
      
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
        "baseline",
        "Specifies the baseline scheme.",
        choices = c("fixed", "roving_impr", "roving")
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
      
      # Calcola bottone
    ),
    
    
    # Show a plot of the generated distribution
    mainPanel(width = 4,
      tableOutput("inputTab"),
      tableOutput("relapseTab"),
      tableOutput("outputTab_details"),
      htmlOutput("messages")
    ),
  ),
)
