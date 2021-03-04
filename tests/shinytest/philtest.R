app <- ShinyDriver$new("../../")
app$snapshotInit("philtest")

app$setInputs(api = "test", timeout_ = 10)
app$setInputs(submit = "click")
app$setInputs(seriousness = "1")
app$setInputs(end_date = "2021-03-02")
app$setInputs(submit = "click")
Sys.sleep(2) # sleeping past notifications
app$setInputs(api = "a")
app$setInputs(api = "tylenol")
app$setInputs(submit = "click")
Sys.sleep(2) # sleeping past notifications
app$snapshot()
