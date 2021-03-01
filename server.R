library(shiny)
library(jsonlite)
library(ggplot2)
library(stringr)

datafile = NULL
current_api = 'empty'

shinyServer(function(input, output) {

output$plt = renderPlot({
    datafile <<- NULL
    current_api <<- 'empty'
    fail = FALSE
    output$message = renderText({""})
    output$tble = renderText({""})
    output$download_button = renderUI({""})
    
    raw_api = input$api
    api = gsub(' ', '+', tolower(raw_api)) # to lowercase, then replace spaces with plus signs
    start_date = as.character(input$start_date)
    end_date = as.character(input$end_date)
    if(input$seriousness == 0) {seriousness = ""} #no seriousness filter statement if keep all 
    else{seriousness = paste0('+AND+serious:', as.character(input$seriousness))} # 1 for serious, 2 for non serious according to API
    data_url = paste0('https://api.fda.gov/drug/event.json?search=(patient.drug.medicinalproduct:',api,
                      '+OR+patient.drug.openfda.generic_name:',api,'+OR+patient.drug.openfda.substance_name:',api,
                      '+OR+patient.drug.openfda.brand_name:',api,')',seriousness,'+AND+receivedate:[',start_date,
                      '+TO+',end_date,']&count=patient.reaction.reactionmeddrapt.exact&limit=1000')
    tryCatch({
        raw_data = fromJSON(url(data_url))},
        error = function(e){
            output$message = renderText({'Your request did not return any result.<br>Please try again!'})
            #output$error = renderPrint({data_url})
            fail <<- TRUE
        }
        )
    if (!fail){
        ranks = 1:length(raw_data$results$term)
        df = data.frame(ranks, raw_data$results$term, raw_data$results$count)
        names(df) = c("Rank", "Event", "Count")
        df$Event = as.character(df$Event)
        df$Frequency = sprintf("%.3f %%", (df$Count / sum(df$Count)) * 100)
        datafile <<- df
        current_api <<- api
        df_subset = df[1:10, ]
        df_subset$Event = str_wrap(df_subset$Event, width=15)
        output$tble = renderDataTable({df})
        output$download_button = renderUI({downloadButton("download_data", 'Download CSV')})
        output$message = renderText({'5) Download the data:'})
        plt = ggplot(data=df_subset, aes(x=reorder(Event,Count,FUN=function(x) -x), y=Count))+
        geom_bar(stat='identity', colour='white', fill='navyblue', alpha = 0.6, width=0.6)+
        geom_text(data=df_subset, aes(x=Event, y=Count*1.1, label=Count), size=4,
                position = position_dodge(width=1)) +
        xlab('')+ylab('COUNT\n')+
        ggtitle(paste0('TOP 10 MOST FREQUENT ADVERSE EVENTS FOR ', toupper(raw_api), '\n\n'))+
        theme(axis.text.x=element_text(angle=30, hjust=1, color='black', size=11),
                axis.text.y=element_text(hjust=1, color='black', size=11),
                legend.position='none')
        return(plt)
    }
})

output$download_data <- downloadHandler(
       filename = function() {
         paste0(current_api, '.csv')
       },
       content = function(file) {
         write.csv(datafile, file, row.names = FALSE)
       }
     )

})