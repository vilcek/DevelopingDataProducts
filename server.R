library(shiny)
library(tm)
library(wordcloud)
library(e1071)
library(caret)

data_all <- read.table('data/SMSSpamCollection', sep='\t', header=F, stringsAsFactors=F, quote='', col.names=c('Class', 'Message'))
data_all$Class[data_all$Class=='ham'] <- 'non-spam'
data_all$Class <- factor(data_all$Class, c('spam', 'non-spam'))

built_model <- F

shinyServer(function(input, output) {
  
  sampleSize <- reactive({
    input$buttonDataUpdate
    input$sliderDataSampleSize
  })
  
  minFreq <- reactive({
    input$buttonDataUpdate
    input$sliderDataMinFreq
  })
  
  maxWords <- reactive({
    input$buttonDataUpdate
    input$sliderDataMaxWords
  })
  
  wordCloud <- reactive({
    input$buttonDataUpdate
    isolate({
      withProgress({
        setProgress(message = "Building Word Cloud ...")
        set.seed(12345)
        data <- data_all[sample(c(1:nrow(data_all)), sampleSize()),]
        spam_wordcloud <- subset(data, Class=='spam')
        ham_wordcloud <- subset(data, Class=='non-spam')
        wordcloud_rep <- repeatable(wordcloud)
        layout(matrix(c(1,2,3,4), 2, 2, byrow=T), c(1,1), c(1,4))
        par(mar=rep(0, 4))
        plot.new()
        text(x=0.5, y=0.5, 'Frequent Spam Words', cex=1.5, font=2)
        plot.new()
        text(x=0.5, y=0.5, 'Frequent Non-Spam Words', cex=1.5, font=2)
        wordcloud_rep(spam_wordcloud$Message, min.freq=minFreq(), max.words=maxWords(), scale=c(4, 0.5), colors=brewer.pal(8, "Dark2"))
        wordcloud_rep(ham_wordcloud$Message, min.freq=minFreq(), max.words=maxWords(), scale=c(4, 0.5), colors=brewer.pal(8, "Dark2"))
      })
    })
  })
  
  dataTransformation <- reactive({
    input$buttonModelBuild
    input$checkboxGroupDataTransf
  })
  
  dataFraction <- reactive({
    input$buttonModelBuild
    input$sliderModelSampleData
  })
  
  testFraction <- reactive({
    input$buttonModelBuild
    input$sliderModelTestData
  })
    
  minFreqTerms <- reactive({
    input$buttonModelBuild
    input$sliderModelFreqTerms
  })
  
  laplaceSmoothing <- reactive({
    input$buttonModelBuild
    input$sliderModelLaplace
  })
  
  modelResult <- reactive({
    input$buttonModelBuild
    isolate({
      withProgress({
        setProgress(message = "Building Model ...")
        data_transformation <<- dataTransformation()
        data_fraction <- dataFraction()
        test_fraction <- testFraction()
        min_freq_terms <- minFreqTerms()
        laplace_smoothing <- laplaceSmoothing()
        
        data <- data_all[sample(c(1:nrow(data_all)), nrow(data_all)*(data_fraction/100)),]
        
        data_corpus <- Corpus(VectorSource(data$Message))
        if('convert to lower-case' %in% data_transformation) {
          data_corpus <- tm_map(data_corpus, content_transformer(tolower))
        }
        if('remove numbers' %in% data_transformation) {
          data_corpus <- tm_map(data_corpus, removeNumbers)
        }
        if('remove stop-words' %in% data_transformation) {
          data_corpus <- tm_map(data_corpus, removeWords, stopwords('english'))
        }
        if('remove punctuation' %in% data_transformation) {
          data_corpus <- tm_map(data_corpus, removePunctuation)
        }
        if('strip white space' %in% data_transformation) {
          data_corpus <- tm_map(data_corpus, stripWhitespace)
        }
        
        data_dtm <- DocumentTermMatrix(data_corpus)
        
        idx_train <- sample(nrow(data_dtm), ceiling(nrow(data_dtm)*(1-(test_fraction/100))))
        idx_test <- c(1:nrow(data_dtm))[-idx_train]
        data_raw_train <- data[idx_train,]
        data_raw_test <- data[idx_test,]
        data_corpus_train <- data_corpus[idx_train]
        data_corpus_test <- data_corpus[idx_test]
        data_dtm_train <- data_dtm[idx_train,]
        data_dtm_test <- data_dtm[idx_test,]
        
        data_dict <- findFreqTerms(data_dtm_train, min_freq_terms)
        
        data_dtm_train <- DocumentTermMatrix(data_corpus_train, list(dictionary=data_dict))
        data_dtm_test <- DocumentTermMatrix(data_corpus_test, list(dictionary=data_dict))
        
        convert_counts <<- function(x) {
          x <- ifelse(x>0, 1, 0)
          x <- factor(x, levels=c(0, 1))
          return(x)
        }
        
        data_dtm_train <- apply(data_dtm_train, 2, convert_counts)
        data_dtm_test <- apply(data_dtm_test, 2, convert_counts)
        
        data_dtm_ref <<- data_dtm_test[1,]
        
        sms_classifier <<- naiveBayes(data_dtm_train, data_raw_train$Class, laplace=laplace_smoothing)
        built_model <<- T
        sms_test_pred <- predict(sms_classifier, data_dtm_test)
        
        unique_train <- apply(data_dtm_train, 2, function(x) {sum(as.numeric(x))})
        unique_train <- length(unique_train[unique_train!=0])
        unique_test <- apply(data_dtm_test, 2, function(x) {sum(as.numeric(x))})
        unique_test <- length(unique_test[unique_test!=0])
        data_info <- paste('Train Data Size: ', nrow(data_dtm_train), ' documents, ', unique_train, ' unique terms.')
        data_info <- paste(data_info, '\nValidation Data Size: ', nrow(data_dtm_test), ' documents, ', unique_test, ' unique terms.\n\n')
        cat(data_info)
        
        confusionMatrix(sms_test_pred, data_raw_test$Class)
      })
    })
  })
  
  messageText <- reactive({
    input$buttonModelScoring
    input$textInputScoring
  })
  
  messageClass <- reactive({
    input$buttonModelScoring
    input$radioButonsClass
  })
  
  modelScore <- reactive({
    input$buttonModelScoring
    isolate({
      withProgress({
        setProgress(message = "Scoring Data ...")
        if(!built_model) {
          cat('You need to build your model first.')
        } else {
          tmp_data_dtm_ref <- data_dtm_ref
          tmp_sms_classifier <- sms_classifier
          message_text <- messageText()
          message_class <- messageClass()
          if(!message_text == '') {
            data <- data.frame(Class=message_class, Message=message_text, stringsAsFactors=F)
            data$Class <- factor(data$Class, c('spam', 'non-spam'))
            data_corpus <- Corpus(VectorSource(data$Message))
            if('convert to lower-case' %in% data_transformation) {
              data_corpus <- tm_map(data_corpus, content_transformer(tolower))
            }
            if('remove numbers' %in% data_transformation) {
              data_corpus <- tm_map(data_corpus, removeNumbers)
            }
            if('remove stop-words' %in% data_transformation) {
              data_corpus <- tm_map(data_corpus, removeWords, stopwords('english'))
            }
            if('remove punctuation' %in% data_transformation) {
              data_corpus <- tm_map(data_corpus, removePunctuation)
            }
            if('strip white space' %in% data_transformation) {
              data_corpus <- tm_map(data_corpus, stripWhitespace)
            }
            terms <- DocumentTermMatrix(data_corpus)$dimnames$Terms
            for(t in terms) {
              if(!t %in% names(tmp_data_dtm_ref)) {
                tmp_data_dtm_ref[t] <- '0'
              }
            }
            data_dtm <- rbind(rep('0', length(tmp_data_dtm_ref)), tmp_data_dtm_ref)
            for(t in terms) {
              data_dtm[1, `t`] <- '1'
            }
            prediction <- predict(tmp_sms_classifier, data_dtm)[1]
            output <- paste('Message:\t', message_text, '\n\nActual Class:\t', message_class, '\nPredicted Class:\t', prediction)
            cat(output)
          }
        }
      })
    })
  })
  
  output$plotData <- renderPlot({
    wordCloud()
  })
  
  output$tableData <- renderDataTable(options=list(lengthMenu=c(5,10,15,25,50), pageLength=5), {
    set.seed(12345)
    data_all[sample(c(1:nrow(data_all)), sampleSize()),]
  })
  
  output$outputModelResults <- renderPrint({
    modelResult()
  })
  
  output$outputScoringResults <- renderPrint({
    modelScore()
  })
  
})