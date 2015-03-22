library(shiny)
library(markdown)

data_transformation <- c('convert to lower-case', 'remove numbers', 'remove stop-words', 'remove punctuation', 'strip white space')

shinyUI(fluidPage(
  div(style='color:FireBrick; font-family:trebuchet ms; font-style:italic', img(src='logo.png'), hr()),
  tabsetPanel(type='tabs',
    tabPanel('Data Visualization',
             sidebarLayout(
               sidebarPanel(
                 div(style='text-align:center', h4("Data Explorer")),
                 br(),
                 sliderInput('sliderDataSampleSize', 'Dataset Sample Size:', min=500, max=5000, value=1000, step=500, round=0),
                 br(),
                 sliderInput('sliderDataMinFreq', 'Minimum Word Frequency Across Sampled Data:', min=1, max=10, value=5, step=1, round=0),
                 br(),
                 sliderInput('sliderDataMaxWords', 'Maximum Number of Words Across Sampled Data:', min=10, max=100, value=40, step=10, round=0),
                 br(),
                 actionButton('buttonDataUpdate', 'Update')
               ),
               mainPanel(
                 plotOutput('plotData')
               )
             ),
             fluidRow(
               hr(),
               div(style='text-align:center', h4("Data Set Sample")),
               dataTableOutput('tableData')
             )
    ),
    tabPanel('Model Building',
             sidebarLayout(
               sidebarPanel(
                 div(style='text-align:center', h4("Model Building Parameters")),
                 br(),
                 checkboxGroupInput('checkboxGroupDataTransf', 'Data Transformation:', data_transformation),
                 br(),
                 sliderInput('sliderModelSampleData', 'Subset of the Data Set (%):', min=10, max=100, value=10, step=10, round=0),
                 br(),
                 sliderInput('sliderModelTestData', 'Holdout Data for Model Validation (%):', min=5, max=50, value=20, step=5, round=0),
                 br(),
                 sliderInput('sliderModelFreqTerms', 'Minimum Count of Terms in the Document-Term Matrix:', min=1, max=10, value=5, step=1, round=0),
                 br(),
                 sliderInput('sliderModelLaplace', 'Laplace Smoothing for Naive Bayes:', min=0, max=5, value=1, step=1, round=0),
                 br(),
                 actionButton('buttonModelBuild', 'Build Model')
               ),
               mainPanel(
                 div(style='text-align:center', h4('Model Validation Results')),
                 verbatimTextOutput('outputModelResults')
               )
             )
    ),
    tabPanel('Model Scoring',
             sidebarLayout(
               sidebarPanel(
                 div(style='text-align:center', h4('Try your Own Data')),
                 br(),
                 textInput('textInputScoring', label='Enter your own text message that you want to be classified as either spam or ham:', value=''),
                 br(),
                 radioButtons('radioButonsClass', label='Message Class', choices=list('Spam'='spam', 'Non-Spam'='ham'), selected='spam'),
                 br(),
                 helpText('Note: your input text will be pre-processed according to the options you have set up in the Model Building pane.'),
                 br(),
                 actionButton('buttonModelScoring', 'Classify')
               ),
               mainPanel(
                 div(style='text-align:center', h4('Scoring Results')),
                 verbatimTextOutput('outputScoringResults')
               )
             )
    ),
    navbarMenu('About',
      tabPanel('About SMS Spam Detector',
        includeMarkdown('about.md')
      ),
      tabPanel('How to Use It',
        includeMarkdown('using.md')
      )
    )
  )
))