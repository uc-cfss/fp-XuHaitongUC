library(shiny)
library(tidyverse)
library(feather)
library(scales)

# Load relevant dataset
hOurworld_df_old <- read_feather("data/hOurworld_df_old.feather")

# Build UI
ui <- fluidPage(titlePanel("Time Bank Initiatives Associated with hOurworld"),
                sidebarLayout(
                  sidebarPanel(
                    sliderInput(
                      "membershipInput",
                      "Membership Size",
                      min = 0,
                      max = 1500,
                      value = c(50, 500)
                    ),
                    sliderInput(
                      "activeInput",
                      "Active Member Ratio",
                      min = 0,
                      max = 1,
                      value = c(0.3, 0.8)
                    ),
                    sliderInput(
                      "adminInput",
                      "Number of Admin Accounts",
                      min = 0,
                      max = 15,
                      value = c(1, 5)
                    ),
                    "This interactive page serves as an index of time banks currently 
                    associated with hOurworld in the United States, and illustrates the
                    relative importance of three main factors that in theory would
                    affect the exchange activity of time banks: the membership size 
                    of the time bank network, the ration of members who are actually
                    active, and the number of time bank coordinators (measured by the 
                    the number of admin accounts). The current activity level of time banks is 
                    measured by the exchange per capita made by time bank members in the past year."
                  ),
                  mainPanel(plotOutput("coolplot"),
                            tableOutput("results"))
                ))

# Server
server <- function(input, output) {
  filtered <- reactive({
    # Types
    hOurworld_df_old %>%
      filter(
        Total.Members >= input$membershipInput[1],
        Total.Members <= input$membershipInput[2],
        ActiveRatio >= input$activeInput[1],
        ActiveRatio <= input$activeInput[2],
        X.Admin.Account >= input$adminInput[1],
        X.Admin.Account <= input$adminInput[2]
      )
  })

  # Histogram
  output$coolplot <- renderPlot({
    ggplot(filtered(), aes(Exchange.Past.Year_per_Capita)) +
      geom_histogram() +
      labs(x = "Exchange Past Year per Capita (hr)", y = "Number of Time Bank Initiatives")
  })
  # Table
  output$results <- renderTable({
    filtered()
  })
}

shinyApp(ui = ui, server = server)