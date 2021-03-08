app <- ShinyDriver$new("../../")
app$snapshotInit("philtest")

app$setInputs(api = "test", timeout_ = 10000)
app$setInputs(submit = "click")
app$setInputs(seriousness = "1")
app$setInputs(end_date = "2020-03-02")
app$setInputs(submit = "click")
first_plot <- app$waitForValue("plt", iotype = "output", ignore = list(NULL))
Sys.sleep(2) # sleeping past notifications

app$setInputs(api = "a")
app$setInputs(api = "tylenol")
app$setInputs(submit = "click")
first_plot <- app$waitForValue("plt", iotype = "output", ignore = list(first_plot))
Sys.sleep(2) # sleeping past notifications
app$snapshot()
