# https://jymaze.shinyapps.io/open_fda_a

library(shiny)

shinyUI(
    fluidPage(
        titlePanel("Adverse Events Query to OpenFDA", windowTitle = "Adverse Events Query to OpenFDA"),
        fluidRow(
            column(3,
                br(),
                p("The OpenFDA project makes adverse-event data gathered after January 1, 2004, 
                  available via a public-access portal that enables developers to quickly and 
                  easily use it in applications. The project is hosted at:"),
                a(href="https://open.fda.gov/", "open.fda.gov"),
                br(),
                br(),
                p("This web-app provides a user-friendly graphical interface to the openFDA web-server"),
                br(),
                p("To explore the adverse event data between two dates:"),
                textInput("api", "1) Enter the name of drug:", "asdsdsd"),
                dateInput('start_date', '2) Enter the start date:', min = '2004-01-01', value = '2004-01-01'),
                dateInput('end_date', '3) Enter the end date:', min = '2004-01-02'),
                radioButtons('seriousness', '4) Filter by seriousness:', choices = c("All" = 0, "Serious" = 1, "Non-serious" = 2)),
                submitButton('Submit Request'),
                br(),
                strong(htmlOutput("message")),
                uiOutput("download_button"),
                br(),
                br()
            ),
            column(9,
                #textOutput("error"),
                plotOutput("plt", width = "auto", height = "640")
            )
        ),
        fluidRow(
            column(12,
                dataTableOutput("tble")
            )
        )
    )
)