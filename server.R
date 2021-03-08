library(shiny)
library(jsonlite)
library(ggplot2)
library(stringr)


adverse_event_plot <- function(data, api_name) {
  ggplot(data = data, aes(x = reorder(Event, Count, FUN = function(x) -x), y = Count)) +
      geom_bar(stat = 'identity', colour = 'white', fill = 'navyblue', alpha = 0.6, width = 0.6) +
      geom_text(data = data, aes(x = Event, y = Count*1.1, label = Count), size = 4,
          position = position_dodge(width = 1)) +
      xlab('') +
      ylab('COUNT\n') +
      ggtitle(paste0('TOP 10 MOST FREQUENT ADVERSE EVENTS FOR ', toupper(api_name), '\n\n')) +
      theme(
          axis.text.x = element_text(angle = 30, hjust = 1, color = 'black', size = 11),
          axis.text.y = element_text(hjust = 1, color = 'black', size = 11),
          legend.position = 'none'
      )
}

clean_data <- function(raw_data) {
    count <- raw_data$results$count
    data.frame(
        Rank = seq_along(raw_data$results$term),
        Event = as.character(raw_data$results$term),
        Count = count,
        Frequency = sprintf("%.3f %%", (count / sum(count)) * 100)
        stringsAsFactors = FALSE
    )
}

subset_data <- function(df) {
    df_subset <- df[1:10, ]
    df_subset$Event <- str_wrap(df_subset$Event, width=15)
    return(df_subset)
}



function(input, output) {

    api_data <- reactiveVal(NULL)

    result_message <- reactiveVal("Your request did not return any result.<br>Please try again!")

    display_drug <- reactiveVal("")

    api <- reactive(gsub(' ', '+', tolower(input$api))) # to lowercase, then replace spaces with plus signs
    start_date <- reactive(as.character(input$start_date))
    end_date <- reactive(as.character(input$end_date))
    seriousness <- reactive({
        req(input$seriousness)
        if (input$seriousness == 0) {
            return("")
        } else {
            # 1 for serious, 2 for non serious according to API
            return(paste0('+AND+serious:', as.character(input$seriousness)))
        }
    })

    data_url <- reactive({
        req(api(), start_date(), end_date())
        paste0(
            'https://api.fda.gov/drug/event.json?search=(patient.drug.medicinalproduct:',
            api(),
            '+OR+patient.drug.openfda.generic_name:',
            api(),
            '+OR+patient.drug.openfda.substance_name:',
            api(),
            '+OR+patient.drug.openfda.brand_name:',
            api(),
            ')',
            seriousness(),
            '+AND+receivedate:[',
            start_date(),
            '+TO+',
            end_date(),
            ']&count=patient.reaction.reactionmeddrapt.exact&limit=1000'
        )
    })

    # retrieve data
    observeEvent(
        input$submit, {
            showNotification(paste0("Submitted request for \"", api(), "\""), type = "default")
            tryCatch(
                {
                    raw_data <-  fromJSON(url(data_url()))
                    api_data(clean_data(raw_data))
                    result_message("5) Download the data:")
                    display_drug(api())
                    showNotification("DONE!")
                },
                error = function(e){
                    showNotification(paste0("ERROR. No results for \"", api(), "\""), type = "error")
                    result_message("Your request did not return any result.<br>Please try again!")
                    api_data(NULL)
                }
            )
        }
    )

    df_subset <- reactive({
        req(api_data())
        subset_data(api_data())
    })

    output$message <- renderText(result_message())

    output$tble <- renderDataTable({req(api_data()); return(api_data())})
    output$download_button <- renderUI({
        req(api_data())
        downloadButton("download_data", 'Download CSV')
    })

    output$plt <- renderPlot({
        req(df_subset(), display_drug())
        tryCatch({
            adverse_event_plot(df_subset(), display_drug())
        }, error = function(e) {
            message(e)
        })
    })

    output$download_data <- downloadHandler(
        filename = function() {
            paste0(display_drug(), '.csv')
        },
        content = function(file) {
            write.csv(api_data(), file, row.names = FALSE)
        }
    )

}
