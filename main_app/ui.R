# install msprog package
# devtools::install_github("noemimontobbio/msprog")

# load libraries
library(msprog)
library(shiny)
library(shinyjs)
library(DT)
library(shinyBS)
library(shinyWidgets)

csv_guide_text <- tagList(
  HTML(
    '<!-- Introduction -->
            <h2>CSV files</h2>

            <p>CSV (Comma-Separated Values) files are widely used for data storage and exchange between different software applications because of their simplicity and universality. They are commonly employed in data analysis, databases, and spreadsheet applications.</p>

            <p>A CSV file is a plain text file that stores tabular data (numbers and text) in a plain, human-readable format. In a CSV file, each line represents a row of the table, and the values within each row are separated by commas. The first row contains headers, specifying the names of the columns.
            </p>

            <!-- Using Excel -->
            <h3>Using Excel:</h3>

            <ol>
              <li><strong>Open Excel:</strong>
                <ul>
                  <li>Launch Microsoft Excel on your computer.</li>
                </ul>
              </li>

              <li><strong>Enter, Copy, or Import Data:</strong>
                <ul>
                  <li>Envision a table with three or more columns: subject identifier, visit dates, and a outcome values.</li>
                  <li>The first row designates the name of each column or variable, placed in separate cells.</li>
                  <li>Below that, input your data row by row, adhering to the order of cells in the first row.</li>
                </ul>
              </li>

              <li><strong>Save as CSV:</strong>
                <ul>
                  <li>Navigate to the top-left corner and click "File."</li>
                  <li>Select "Save As."</li>
                  <li>Choose the destination for your file.</li>
                  <li>In the "Save as type" dropdown, opt for "CSV (Comma delimited) (*.csv)."</li>
                  <li>Provide your file with a name ending in <code>.csv</code>, and then click "Save."</li>
                </ul>
              </li>
            </ol>

            <!-- Using a Text Editor -->
            <h3>Using a Text Editor (e.g., Notepad or VS Code):</h3>

            <ol>
              <li><strong>Open Text Editor:</strong>
                <ul>
                  <li>Open your preferred text editor.</li>
                </ul>
              </li>

              <li><strong>Enter, Copy, or Import Data:</strong>
                <ul>
                  <li>Visualize a table with three or more columns: subject identifier, visit dates, and a outcome values.</li>
                  <li>The first row signifies the name of each column, separated by a comma.</li>
                  <li>Below that, input your data row by row, ensuring alignment with the column order and separating columns with commas.</li>
                </ul>
              </li>

              <li><strong>Save as CSV:</strong>
                <ul>
                  <li>Head to the top-left corner and click "File."</li>
                  <li>Opt for "Save As."</li>
                  <li>Indicate the file\'s destination.</li>
                                     <li>Provide a name for your file ending with <code>.csv</code>.</li>
                                     <li>In the "Save as type" dropdown, choose "All Files (*.*)".</li>
                                     <li>Click "Save."</li>
                                     </ul>
                                     </li>
                                     </ol>

                                     <p>Once you\'ve successfully created a CSV file you can upload in MSprog.</p>

            <p><i>Tip: Use the '
  ),
  icon("eye", id = "eye_outcome"),
  HTML(
    'icon to preview your CSV data in MSprog before calculating progressions. Ensure everything looks correct before proceeding!</I></p>
            ')
)

# Define UI for application that draws a histogram
fluidPage(
  
  # Note the wrapping of the string in HTML()
  tags$head(
    
    # to scroll from compute to results
    tags$style(HTML(
      "html{scroll-behavior: smooth;}"
    ))),
  
  # Application title
  # titlePanel(title = "MSprog", windowTitle = "MSprog"),
  titlePanel(
    title = tagList(
      img(
        src = "logo_R.png",
        height = "100px",
        style = "margin-right:10px;"
      ),
      "MSprog"
    ),
    windowTitle = "MSprog Web App"
  ),
  
  
  # Introduction block
  HTML("
  <p>Welcome to the MSprog Web App. This page serves as a graphical interface
  to the <code>MSprog()</code> function, the core component of the 
  <a href='https://github.com/noemimontobbio/msprog/'><i>msprog</i> R package</a>
  developed by the Biostatistics group at the Health Sciences Department (DISSAL)
  of the University of Genoa (Genoa, Italy).</p>"),
  icon("book"), tags$a(href='https://github.com/noemimontobbio/msprog/blob/master/msprog.pdf',
                       "msprog reference manual"),
  HTML("<br><br><p>If you use the <i>msprog</i> R package or the <i>MSprog</i> web app in your work, please cite:</p>
  <blockquote style='font-size: 1em' cite='https://doi.org/10.1177/13524585241243157'><b>Creating an automated tool for a consistent 
  and repeatable evaluation of disability progression in clinical studies for Multiple Sclerosis</b><br>
     <i>Noemi Montobbio, Luca Carmisciano, Alessio Signori, Marta Ponzano, Irene Schiavetti, Francesca Bovis, Maria Pia Sormani</i><br>
     Mult Scler. 2024;30(9):1185-1192. <b>doi</b>: <a href='https://doi.org/10.1177/13524585241243157'>10.1177/13524585241243157</a>
  </blockquote><br><br>"
  ),
  
  # new section
  # title
  # HTML("<h3>The <code>MSprog</code> function</h3>"),
  # subtitle
  h3("Extract multiple sclerosis disability events from longitudinal data"),
  
  # description of the tool
  HTML("Identify and characterise confirmed disability worsening (CDW) or improvement (CDI) events
        of an outcome measure across the data of one or more subjects.
        The procedure utilizes repeated clinical assessments over time 
        and considers the dates of acute episodes, if provided. 
        Customize results by setting qualitative and quantitative options, and
        enhance reproducibility by reporting the applied settings in your work.<br><br>
       <i>Please input the required information; <span style='color:red;'>mandatory fields are
       marked with an asterisk (*)</span></i><br><br>"
  ),
  
  # Sidebar
  sidebarLayout(div(
    sidebarPanel(
      
      # set the width of the sidebar to half (6/12)
      width = 6,
      
      # tell frontend to load shinyjs
      useShinyjs(),
      
      # Import outcome data ----------------------------------------------------
      div(
        id = "outcome_data_block",
        style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
        
        # File
        h4(
          "Import outcome data", tags$span("*", style = "color: red;"),
          hidden(icon("eye", id = "eye_outcome"))
        ),
        HTML(
          "Choose or drag and drop here a <b>CSV or EXCEL file</b>"
        ),
        actionLink('csv_guide_outcome', label = "(read more)"),
        HTML(
          "with longitudinal assessments of an outcome measure (e.g., EDSS) for one or more
            patients (one row per subject per visit).<br>
            <i>Note: the outcome file should contain at least the following columns:
            individual subject identifier (anonymised), outcome values, and date of visits.</i>"
        ),
        fileInput(
          inputId = "dat",
          label = "",
          multiple = FALSE,
          accept = c(".csv", ".xls", ".xlsx")
        ),
        
        bsModal(
          id = "outcomeTab_pop",
          title =  "Outcome data",
          trigger = "eye_outcome",
          DT::DTOutput("inputTab")
        ),
        
        bsModal(
          id = "csv_guide_outcome_pop",
          title = "Guide",
          trigger = "csv_guide_outcome",
          csv_guide_text
        ),
        
        # Columns
        HTML(
          "Specify the column names corresponding in your outcome file to the required columns.<br>"
        ),
        HTML("<br>"),
        div(
          id = "subj_col_block",
          style = "display: inline-block;vertical-align:top; width: 30%;",
          selectInput(
            inputId = "subj_col",
            label = "Subject ID",
            choices = c("")
          )
        ),
        div(
          id = "value_col_block",
          style = "display: inline-block;vertical-align:top; width: 30%;",
          selectInput(
            inputId = "value_col",
            label = "Outcome value",
            choices = c("")
          )
        ),
        div(
          id = "date_col_block",
          style = "display: inline-block;vertical-align:top; width: 30%;",
          selectInput(
            inputId = "date_col",
            label = "Date of visit",
            choices = c("")
          )
        )
      ),
      
      # Import relapse data ----------------------------------------------------
      # File
      div(
        style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
        h4("Import relapse data (optional)", hidden(icon("eye", id = "eye_relapse"))),
        HTML(
          "Choose or drag and drop here a <b>CSV or EXCEL file</b>"
        ),
        actionLink('csv_guide_relapse', label = "(read more)"),
        HTML(
          "with the dates of relapses (one row per subject per relapse).<br>
          <i>Note: the relapse file should contain at least the following columns:
             individual subject identifier, date of relapse.</i>"
        ),
        fileInput(
          inputId = "relapse.dat",
          label = "",
          multiple = FALSE,
          accept = c(".csv", ".xls", ".xlsx")
        ),
        
        bsModal(
          id = "relapseTab_pop",
          title =  "Relapse data",
          trigger = "eye_relapse",
          DT::DTOutput("relapseTab")  #tableOutput("relapseTab")
        ),
        
        bsModal(
          id = "csv_guide_relapse_pop",
          title = "Guide",
          trigger = "csv_guide_relapse",
          csv_guide_text
        ),
        
        # Columns
        HTML(
          "Specify the column names corresponding in your relapse file to the required columns.<br>"
        ),
        HTML("<br>"),
        div(
          style = "display: inline-block;vertical-align:top; width: 49.4%;",
          selectInput(
            inputId = "rsubj_col",
            label = "Subject ID",
            choices = c("")
          )
        ),
        div(
          style = "display: inline-block;vertical-align:top; width: 49.4%;",
          selectInput(
            inputId = "rdate_col",
            label = "Date of relapse",
            choices = c("")
          )
        )
      ),
      
      HTML("<p><i><b>Tip: After uploading your data, use the "),
      icon("eye", id = "eye_outcome"),
      HTML('icon to preview your data in MSprog.
           Ensure everything looks correct before proceeding!</b></i></p>'),
      
      # Outcome ----------------------------------------------------------------
      div(
        id = "outcome_type_block",
        style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
        h4("Outcome definition", tags$span("*", style = "color: red;")),
        radioButtons(
          inputId = "outcome",
          label = "Specify the outcome type:",
          choices = c(
            "Expanded Disability Status Scale (EDSS)" = "edss",
            "Nine-Hole Peg Test (NHPT)" = "nhpt",
            "Timed 25-Foot Walk (T25FW)" = "t25fw",
            "Symbol Digit Modalities Test (SDMT)" = "sdmt"
          ),
          selected = NA
        ),
        HTML(
          "<i>Note: this selection determines the direction of worsening (increase for EDSS, NHPT, and T25FW; 
          decrease for SDMT) and the minimum accepted clinically meaningful change given the reference value. 
          Specifically:<ul>
  <li>EDSS: 1.5 if baseline=0; 1.0 if 0 &lt; baseline &le; 5.0; 0.5 if baseline &gt; 5.0 (<a href='https://doi.org/10.1056/nejmoa2415988'>Fox 2025</a>)</li>
  <li>NHPT and T25FW: 20% of baseline (<a href='https://doi.org/10.1177/1352458510370464'>Bosma 2010</a>)</li>
  <li>SDMT: either 3 points or 10% of baseline (<a href='https://doi.org/10.1177/1352458518808204'>Strober 2018</a>).
  </ul></i>"
        )
      ),
      
      # Event ------------------------------------------------------------------
      div(
        style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
        h4("Event definition"),
        radioButtons(
          inputId = "event",
          label = "Specify the event setting of interest:",
          choices = c(
            "First CDW" = "firstCDW",
            "First CDI" = "firstCDI",
            "All events, detected sequentially" = "multiple",
            "First progression independent of relapse activity (PIRA)" = "firstPIRA",
            "First relapse-associated worsening (RAW)" = "firstRAW",
            "Only the very first event (CDW or CDI)" = "first"
          ),
          selected = "firstCDW"
        )
      ),
      
      # Baseline ---------------------------------------------------------------
      div(
        style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
        h4("Baseline definition"),
        radioButtons(
          inputId = "baseline",
          label = "Specify a baseline scheme:",
          choices = c(
            "Fixed: first eligible visit in the data" = "fixed",
            "Roving: updated after each CDW or CDI (suitable for a multiple-event setting; 
            not recommended for randomised data)" = "roving",
            "Roving (CDI-only): updated after each CDI (suitable for discarding fluctuations around baseline in a
                first-CDW setting; not recommended for multiple events or randomised data)" = "roving_impr"
          ),
          selected = "fixed"
        )
      ),
      
      # Confirmation -----------------------------------------------------------
      div(
        style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",
        h4("Confirmation definition"),
        HTML(
          "An event is <i>confirmed</i> if a clinically meaningful outcome change from baseline 
          is maintained at all visits up to the confirmation visit.<br>"
        ),
        HTML("<hr>"),
        sliderInput(
          inputId = "conf_weeks",
          label = "Specify the time interval from event onset to the confirmation visit:",
          min = 0,
          max = 96,
          value = 12,
          step = 1,
          post = " weeks",
        ),
        
        HTML("<hr>"),
        
        shinyWidgets::sliderTextInput(
          inputId = "conf_tol_days",
          post = " days",
          from_max = 0,
          to_min = 0,
          grid = T,
          # force_edges = T,
          label = "Specify the tolerance window for the confirmation interval above 
          (slide to the right end of the bar for \"no upper bound\")",
          selected = c(-7, 365 * 2),
          choices = c(seq(-60, 365 * 3, 1), "Unlimited")
        ),
        tags$style(HTML("
              .irs--shiny .irs-shadow{
                height: 0px;
              }")),
        
        HTML(
          "<i>Note: larger intervals improve the stability of event detection 
          but are likely to decrease the number of events.</i><br>"
        ),
        
      ),
      
      # Advanced ---------------------------------------------------------------
      hidden(
          
        div(
          id = 'advancedbox',
          style = "margin:10px; border:1px solid #e3e8e4; padding:20px; border-radius: 5px;",

          radioButtons(
            inputId = "proceed_from",
            label = "After detecting a confirmed disability event, continue searching:",
            choices = c(
              "from the next visit after the first qualifying confirmation visit" = "firstconf",
              "from the next visit after the event onset" = "event"
            ),
            selected = "firstconf"
          ),
          HTML("<i>Note: this only applies in a multiple-event setting.</i>"),
          
          HTML("<hr>"),
          
          div(
            id = "validconf_block",
            selectInput(
              inputId = "validconf_col",
              label = "Name of (optional) column in the data specifying which visits 
              can (TRUE/1) or cannot (FALSE/0) be used as confirmation:",
              choices = c("")
            )
            ),
          
          HTML("<hr>"),
          
          numericInput(
            "require_sust_weeks",
            "Minimum number of weeks over which a confirmed change must be sustained 
            (i.e., clinically meaningful change maintained at all visits occurring in the specified period)
            to be retained as an event:",
            min = 0,
            value = 0,
            step = 1
          ),
          
          checkboxInput(
            inputId = "require_sust_inf",
            label = "Only retain events sustained up to end of follow-up",
            value = FALSE
          ),
          
          HTML("<i>Note: events sustained for the remainder of the follow-up period 
                are always retained regardless of follow-up duration 
               (e.g., if 48 weeks is entered above and follow-up ends after 36 weeks from event onset).</i>"),
          
          HTML("<hr>"),
          
          numericInput(
            "relapse_to_bl",
            "Minimum distance from last relapse (days) for a visit to be used as baseline 
            (otherwise the baseline is moved to the next eligible visit):",
            min = 0,
            max = 731,
            value = 30,
            step = 30
          ),
          
          HTML("<hr>"),
          
          numericInput(
            "relapse_to_event",
            "Minimum distance from last relapse (days) to event onset:",
            min = 0,
            max = 731,
            value = 0,
            step = 30
          ),
          
          HTML("<hr>"),
          
          numericInput(
            "relapse_to_conf",
            "Minimum distance from last relapse (days) for a visit to be a valid confirmation visit:",
            min = 0,
            max = 731,
            value = 30,
            step = 30
          ),
          
          HTML("<hr>"),
          
          numericInput(
            "relapse_assoc",
            "Relapse-associated worsening (RAW) is defined as a CDW whose onset occurs within
            a specified interval from a previous relapse. Interval length (in days) can be modified below:",
            min = 0,
            max = 365,
            value = 90,
            step = 30,
          ),
          
          HTML("<hr>"),
          
          # radioButtons(
          #   inputId = "check_intermediate",
          #   label = "Check for confirmation over all intermediate visits up to the confirmation visit?",
          #   choices = c(
          #     "Yes (reccomendend)" = TRUE,
          #     "No" = FALSE
          #   ),
          #   selected = TRUE
          # ),
          # 
          # HTML("<hr>"),
          
          radioButtons(
            inputId = "impute_last_visit",
            label = "Specify the behaviour for unconfirmed disability worsening occurring at the last available visit:",
            choices = c(
              "censored (not retained as a CDW)" = 0,
              "imputed (retained as a CDW)" = 1,
              "Random mixture of censoring and imputation (specify imputation probability below)" = "mix"
            ),
            selected = 0
          ),
          
          numericInput(
            "impute_prob",
            "Imputation probability (enter a value between 0 and 1):",
            min = 0,
            max = 1,
            value = .5,
            step = .05
          ),
          
          HTML("<hr>"),
          
          # selectInput(
          #   "subjects",
          #   "Subset of subjects to include",
          #   choices = c("Include all")
          # ),
          
        )
      ),
      
      div(
        style = "text-align: center; margin:10px",
        actionButton(inputId = "advanced_button_on", label = "Advanced settings"),
        hidden(
          actionButton(inputId = "advanced_button_off", label = "Close advanced settings")
        )
      ),
      
      div(
        style = "text-align: center;",
        actionButton(
          type = "button",
          inputId = "run_msprog",
          label = "Compute",
          onclick = 'document.getElementById("results_panel").scrollIntoView();'
        )
      )
      
    ),
    
  ),
  
  
  
  # Information downloaded:
  # 1. Extended event report [csv ottenuto da results(output)]
  # 2. Event count [csv ottenuto da event_count(output)]
  # 3. Textual description of criteria used, to be reported to ensure reproducibility
  mainPanel(
    width = 6,
    div(
      id = "results_panel",
      p(),
      h3("Results"),
      HTML(
        '<p id = input_guide_message_all>Fill in the required input, then press the "Compute" button below to display results.</p>'
      ),
      
      # REQUIRED INFO (if adding/deleting, modify output.inputs_complete flag in server too!!)
      HTML(
        '<p hidden id = input_guide_message_outcome_file>Please <a href="#outcome_data_block">import outcome data</a>.</p>'
      ),
      HTML(
        '<p hidden id = input_guide_message_outcome_definition>Please <a href="#outcome_type_block">select outcome type</a>.</p>'
      ),
      HTML(
        '<p hidden id = input_guide_message_outcome_idcol>Please specify the column names corresponding in your outcome file to the <a href="#subj_col_block">subject identifier column</a>.</p>'
      ),
      HTML(
        '<p hidden id = input_guide_message_outcome_outcol>Please specify the column names corresponding in your outcome file to the <a href="#value_col_block">outcome values column</a>.</p>'
      ),
      HTML(
        '<p hidden id = input_guide_message_outcome_datecol>Please specify the column names corresponding in your outcome file to the <a href="#date_col_block">date of visits column</a>.</p>'
      ),
      
      # Criteria
      hidden(
        h4(id = "criteria_description_title", "Description of criteria"),
        h5(id = "criteria_description_subtitle", 
           "Please report the package version and full settings (or textual description) in your work.")
      ),
      htmlOutput("messages"),
      
      # Event count
      hidden(h4(id = "event_count_title", "Event count")),
      div(style = "max-height: 500px; overflow: scroll;",
          tableOutput("outputTab_details")),
      
      # "Computing..." spinner
      conditionalPanel(
        condition = "input.run_msprog > 0 
                      && output.inputs_complete
                      && !output.has_results",
        
        div(
          style = "margin-top:10px; font-weight: bold; color:#555;",
          icon("spinner", class = "fa-spin"),
          " Computing… This may take a few minutes for large datasets."
        )
      ),
      
      HTML("<br>"),
      
      # Download button
      hidden(
        div(
          id = "download_panel",
          downloadButton(
            outputId = "download",
            label = "Download full individual-patient results (.xlsx)",
            class = "btn-primary btn-block"
          )
        )
      )
    )
  )
  ),
  
  # Footer
  HTML(
    '<footer style="text-align: center;color: lightgray;">
      <p>version 0.3</p>
      <p>Developed by the <a href="mailto:noemi.montobbio@edu.unige.it">biostatistics group</a> 
      <br>Health Sciences Department (DISSAL), University of Genoa, Genoa, Italy</p>
     </footer>'
  )
)
