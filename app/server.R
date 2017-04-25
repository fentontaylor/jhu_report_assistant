library(shiny)
suppressMessages(library(stringi))
suppressMessages(library(dplyr))

#New databases - Need to update algorithm
ngrams_accuracy <- readRDS("data/all_ng_trim1.rds")
ngrams_speed <- readRDS("data/all_ng_trim5.rds")
shinyServer(function(input, output) {
   
    ngrams <- reactive({
        if(input$dbPreference=="Accuracy") { ngrams_accuracy }
        else { ngrams_speed }
    })
    
    predList <- reactive({
        # Clean the text with the same process that generated n-gram lists
        x <- input$text
        x <- tolower(x)
        # Delete text before EOS punctuation since it will skew prediction.
        x <- gsub(".*<EOS>", "", x)
        x <- gsub(" $", "", x)
        # Get length of string for loop iterations
        m <- length(stri_split_fixed(str=x, pattern=" ")[[1]])
        m <- ifelse(m < 5, m, 5)
        
        for( i in m:1 ){
            x <- stri_split_fixed(str=x, pattern=" ")[[1]]
            n <- length(x)
            # As i decreases, length of x is shortened to search smaller n-grams
            x <- paste(x[(n-i+1):n], collapse=" ")
            search <- grep(paste0("^", x, " "), ngrams()[[i]]$words)
            
            if( length(search) == 0 ) { next }
            break
        }
        
        choices <- ngrams()[[i]][search,]
        choices <- arrange(choices, desc(freq))
        words <- gsub(paste0(x," "), "", choices$words)
        list(x=x, choices=choices, words=words)
    })
    
    output$prediction <- renderText({
        words <- predList()$words
        n <- length(words)
        max <- input$maxResults
        if ( n == 0 ) {
            if( input$text == "" ) { 
                print("Please begin typing...")
            } else if (input$text != "" & predList()$x == "") {
                print("Please continue typing...")
            } else {
                paste(topFive[1:max], collapse = " | ")
            }
        } else if ( n > max ) { 
            paste(words[1:max], collapse = " | ")
        } else { 
            paste(words, collapse = " | ")
        }
    })
  
})
