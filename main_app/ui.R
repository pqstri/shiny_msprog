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
    "Compute multiple sclerosis progression from longitudinal data.",
    windowTitle = "MSprog"
  ),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      fileInput(
        "dat",
        "Please choose or drag and drop here a CSV or Excel file.",
        multiple = FALSE,
        # c("text/csv", "text/comma-separated-values,text/plain", ".csv", ".xls", ".xlsx"
        accept = ".csv"
      ),
      
      sliderInput(
        "conf_weeks",
        "Period before confirmation (weeks):",
        min = 1,
        max = 53,
        value = 12,
        step = 1
      ),
      
      numericInput(
        "conf_tol_days",
        "Tolerance window for confirmation visit (days); can be an integer (same tolerance on left and right) or list-like of length 2 (different tolerance on left and right). In all cases, the right end of the interval is ignored if conf_unbounded_right is set to TRUE.",
        min = 0,
        max = 365,
        value = 30,
        step = 7
      ),
      
      selectInput("subj_col",
                  "Name of data column with subject ID",
                  choices = c("")),
      
      selectInput(
        "value_col",
        "Name of data column with outcome value",
        choices = c("")
      ),
      
      selectInput("date_col",
                  "Name of data column with date of visit",
                  choices = c("")),
      
      sliderInput(
        "conf_tol_days",
        "Tolerance window for confirmation visit (days) 
        [the right end of the interval is included]",
        min = -60,
        max = 60,
        value = c(-30, 30)
      ),
      
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
        "event",
        "Specifies which events to detect.",
        choices = c("firstprog", "first", "firsteach", "firstprogtype",
                    "firstPIRA", "firstRAW", "multiple")
      ),
      
      selectInput(
        "baseline",
        "Specifies the baseline scheme.",
        choices = c("fixed", "roving_impr", "roving")
      ),
      
      radioButtons(
        "outcome",
        "Name of data column with date of visit",
        choices = c("edss", "nhpt", "t25fw", "sdmt"),
        selected = NA
      ),
      
      selectInput(
        "subjects",
        "Subset of subjects to include",
        choices = c("Include all")
      ),
      
      fileInput(
        "relapse.dat",
        "Upload relapse longitudinal data",
        multiple = FALSE,
        accept = c(".csv")
      ),
      
      numericInput(
        "min_value",
        "Outcome theshold above which consider progressions events",
        value = 0
      ),
    ),
    
    
    # Show a plot of the generated distribution
    mainPanel(
      tableOutput("inputTab"),
      tableOutput("relapseTab"),
      tableOutput("outputTab_details"),
      htmlOutput("messages")
    ),
  ),
)
