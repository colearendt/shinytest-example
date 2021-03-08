app <- ShinyDriver$new("../../")
app$snapshotInit("mytest")

app$setInputs(api = "aspirin")
app$setInputs(start_date = "2004-01-15")
app$setInputs(end_date = "2020-02-28")
app$setInputs(seriousness = "1")
app$setInputs(submit = "click")

first_plot <- app$waitForValue("plt", iotype = "output", ignore = list(NULL))
Sys.sleep(5 + 1) # sleeping past notifications
app$snapshotDownload("download_data")
app$snapshot()

app$setInputs(api = "tylenol")
app$setInputs(submit = "click")
app$waitForValue("plt", iotype = "output", ignore = list(first_plot))
Sys.sleep(5 + 1) # sleeping past notifications
app$snapshot()
