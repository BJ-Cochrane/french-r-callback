# Load quietly
suppressPackageStartupMessages(library(crayon))

# Define everything in a local environment to avoid polluting global env
local({
  # load the French words
  french_words <- utils::read.csv("C:/Users/benco/AppData/Local/R/scripts/french_words.csv", stringsAsFactors = FALSE)
  
  # default options
  if (is.null(getOption("french.callback"))) options(french.callback = TRUE) # turn on/off
  if (is.null(getOption("french.callback.frequency"))) options(french.callback.frequency = 3) # after how many executions 
  if (is.null(getOption("french.callback.interval"))) options(french.callback.interval = 10)  # after how many seconds
  # helpers
  if (is.null(getOption("french.callback.counter"))) options(french.callback.counter = 0)
  if (is.null(getOption("french.callback.lasttime"))) options(french.callback.lasttime = Sys.time())
  
  # define the task callback
  print_french_word <- function(expr, value, ok, visible) {
    if (!isTRUE(getOption("french.callback"))) return(TRUE)
    
    counter <- getOption("french.callback.counter", 0) + 1
    options(french.callback.counter = counter)
    
    freq <- getOption("french.callback.frequency", 3)
    interval <- getOption("french.callback.interval", 10)  # Use the new option
    last_time <- getOption("french.callback.lasttime", Sys.time())
    now <- Sys.time()
    
    if (counter %% freq == 0 && difftime(now, last_time, units = "secs") >= interval) {
      options(french.callback.lasttime = now)
      row <- french_words[sample(nrow(french_words), 1), ]
      example_fr <- sub(
        row[["french"]],
        underline(row[["french"]]),
        row[["example_fr"]],
        ignore.case = TRUE
      )
      cat(
        "\n",
        bold$yellow(row[["french"]]), "\n",
        green(row[["pronunciation"]]), "\n",
        cyan(row[["english"]]), "\n",
        bold$blue("Pour exemple: "), silver(example_fr), cyan(row[["example_en"]]), "\n"
      )
    }
    TRUE
  }
  
  # register the callback
  addTaskCallback(print_french_word)
})
