## R script to forecast past cycle times and compare to actual cycle times
## Author: David Chi
## Date Created: 2016-07-26
## 

if(FALSE) {
  
  ## Load libraries
  install.packages("tree")
  install.packages("randomForest")
  install.packages("gbm")
  install.packages("rpart")
  install.packages('plyr')
  install.packages('ROracle')
  install.packages('lubridate')
  
  library(tree)
  library(randomForest)
  library(gbm)
  library(rpart)
  library(lubridate)
  
  ## Read CSV file (header assumed), then put that into "csv.data" data object (any name is ok).
  invoice.data <- read.delim("cycle_time_ML_15.tsv")
  ## Get paid invoices only and drop NAs and empty strings
  invoice.paid <- invoice.data[!is.na(invoice.data[,"PAYMENT_DATE"]),]
  invoice.paid[invoice.paid$PAYMENT_DATE=="", "PAYMENT_DATE"] <- NA
  invoice.paid <- invoice.paid[!is.na(invoice.paid[,"PAYMENT_DATE"]),]
}

# create a data frame to hold the columns to be used for prediction
  pred_matrix <- data.frame(matrix(0, ncol(invoice.data), ncol = 9))
  
  rownames(pred_matrix) <- colnames(invoice.data)
  
  colnames(pred_matrix)[1] <- "CYCLE_TIME_INVOICE_RECEIVED"
  colnames(pred_matrix)[2] <- "CYCLE_TIME_RECEIVED_ENTRY"
  colnames(pred_matrix)[3] <- "CYCLE_TIME_ENTRY_HOLD"
  colnames(pred_matrix)[4] <- "CYCLE_TIME_HOLD_PREAPPROVAL"
  colnames(pred_matrix)[5] <- "CYCLE_TIME_ENTRY_VALIDATION"
  colnames(pred_matrix)[6] <- "CYCLE_TIME_VALIDATION_APPROVAL"
  colnames(pred_matrix)[7] <- "CYCLE_TIME_APPROVAL_HOLD"
  colnames(pred_matrix)[8] <- "CYCLE_TIME_HOLD_POSTAPPROVAL"
  colnames(pred_matrix)[9] <- "CYCLE_TIME_APPROVAL_PAYMENT"

# include INVOICE_ID to merge on later
  pred_matrix[1]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[2]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[3]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[4]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[5]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[6]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[7]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[8]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0)
  pred_matrix[9]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0)

# create a data frame to hold the boosted decision tree algorithm parameters
  algo_matrix <- data.frame(matrix(0, nrow = 4, ncol = 9))
  rownames(algo_matrix)[1] <- "n_trees"
  rownames(algo_matrix)[2] <- "depth"
  rownames(algo_matrix)[3] <- "shrinkage"
  rownames(algo_matrix)[4] <- "MSE"
  colnames(algo_matrix)[1] <- "CYCLE_TIME_INVOICE_RECEIVED"
  colnames(algo_matrix)[2] <- "CYCLE_TIME_RECEIVED_ENTRY"
  colnames(algo_matrix)[3] <- "CYCLE_TIME_ENTRY_HOLD"
  colnames(algo_matrix)[4] <- "CYCLE_TIME_HOLD_PREAPPROVAL"
  colnames(algo_matrix)[5] <- "CYCLE_TIME_ENTRY_VALIDATION"
  colnames(algo_matrix)[6] <- "CYCLE_TIME_VALIDATION_APPROVAL"
  colnames(algo_matrix)[7] <- "CYCLE_TIME_APPROVAL_HOLD"
  colnames(algo_matrix)[8] <- "CYCLE_TIME_HOLD_POSTAPPROVAL"
  colnames(algo_matrix)[9] <- "CYCLE_TIME_APPROVAL_PAYMENT"

  # CYCLE_TIME_INVOICE_RECEIVED
  algo_matrix[1,1] = 4000
  algo_matrix[2,1] = 4
  algo_matrix[3,1] = 0.1
  algo_matrix[4,1] = 101.6
  # CYCLE_TIME_RECEIVED_ENTRY
  algo_matrix[1,2] = 2000
  algo_matrix[2,2] = 4
  algo_matrix[3,2] = 0.1
  algo_matrix[4,2] = 19.5
  # CYCLE_TIME_ENTRY_HOLD
  algo_matrix[1,3] = 4000
  algo_matrix[2,3] = 4
  algo_matrix[3,3] = 0.01
  algo_matrix[4,3] = 1.4
  # CYCLE_TIME_HOLD_PREAPPROVAL
  algo_matrix[1,4] = 1000
  algo_matrix[2,4] = 4
  algo_matrix[3,4] = 0.005
  algo_matrix[4,4] = 21
  #CYCLE_TIME_ENTRY_VALIDATION
  algo_matrix[1,5] = 4000
  algo_matrix[2,5] = 4
  algo_matrix[3,5] = 0.001
  algo_matrix[4,5] = 2.8
  # CYCLE_TIME_VALIDATION_APPROVAL
  algo_matrix[1,6] = 2000
  algo_matrix[2,6] = 4
  algo_matrix[3,6] = 0.005
  algo_matrix[4,6] = 14.8
  # CYCLE_TIME_APPROVAL_HOLD
  algo_matrix[1,7] = 500
  algo_matrix[2,7] = 4
  algo_matrix[3,7] = 0.005
  algo_matrix[4,7] = 2.9
  # CYCLE_TIME_HOLD_POSTAPPROVAL
  algo_matrix[1,8] = 1000
  algo_matrix[2,8] = 4
  algo_matrix[3,8] = 0.001
  algo_matrix[4,8] = 1.5
  # CYCLE_TIME_APPROVAL_PAYMENT
  algo_matrix[1,9] = 500
  algo_matrix[2,9] = 4
  algo_matrix[3,9] = 0.005
  algo_matrix[4,9] = 13.9

# Create array to hold models if it doesn't already exits
  if(is.null(model_list[[9]])){
    model_list <- vector(mode="list", length=ncol(pred_matrix))
  }

# Loop through predicting cycle times in chronological order
  ncol_orig <- ncol(invoice.paid)  
  cycle_time_col_names = c("CYCLE_TIME_INVOICE_RECEIVED", "CYCLE_TIME_RECEIVED_ENTRY", "CYCLE_TIME_ENTRY_HOLD", "CYCLE_TIME_HOLD_PREAPPROVAL", "CYCLE_TIME_ENTRY_VALIDATION", "CYCLE_TIME_VALIDATION_APPROVAL", "CYCLE_TIME_APPROVAL_HOLD", "CYCLE_TIME_HOLD_POSTAPPROVAL", "CYCLE_TIME_APPROVAL_PAYMENT") 
  cycle_time_col_op <- match(cycle_time_col_names, colnames(invoice.paid))

  for (cycle_time_index in 1:ncol(pred_matrix)){
    #for (cycle_time_index in c(2:2)){
      cycle_time <- colnames(pred_matrix)[cycle_time_index]
      col_pull <- which(pred_matrix[cycle_time_index] == 1)
    ## Create table for testing
      ml_data <- invoice.paid[col_pull]
    ## Move cycle time column to front
      cycle_time_col <- match(colnames(pred_matrix[cycle_time_index]), names(ml_data))
      ml_data <- ml_data[c(names(ml_data[cycle_time_col]),names(ml_data)[-cycle_time_col])]
    ## Change name of response column
      colnames(ml_data)[1] <- "CYCLE_TIME"
    ## Get col number of INVOICE_ID to remove from modeling
      inv_id_col = which(colnames(ml_data)=='INVOICE_ID')
    ## filter to rows not missing cycle time being modeled
      ml_data <- ml_data[!is.na(ml_data[1]),]
    ## Convert columns from Int to Factor
      ml_data$PO_NON_PO = as.factor(ml_data$PO_NON_PO)
      ml_data$ORG_ID = as.factor(ml_data$ORG_ID)
      ml_data$DUE_DAYS = as.factor(ml_data$DUE_DAYS)
    # Fit model forecast
      forecast.boost=predict(model_list[[cycle_time_index]],newdata=ml_data[,-inv_id_col], n.trees=algo_matrix[1, cycle_time_index])
    # write forecast and MSE data back to table
      forecast_results <- ml_data[, inv_id_col]
      ml_data[length(colnames(ml_data))+1] = forecast.boost
    # Add cycle time forecast and MSE to invoice.paid
      if (nrow(ml_data) > 0){
        ml_data[ml_data[1] < 0, 1] = 0
        last_col = ncol(invoice.paid)
    # forecast
      invoice.paid[!is.na(invoice.paid[cycle_time_col_op[cycle_time_index]]),last_col+1] <- ml_data[match(invoice.paid[!is.na(invoice.paid[cycle_time_col_op[cycle_time_index]]),1], ml_data$INVOICE_ID),length(colnames(ml_data))]
      invoice.paid[is.na(invoice.paid[last_col+1]),last_col+1] <- 0
      colnames(invoice.paid)[last_col+1] <- paste(colnames(pred_matrix[cycle_time_index]), "FORECAST", sep = "_")
    # MSE    
      invoice.paid[!is.na(invoice.paid[cycle_time_col_op[cycle_time_index]]),last_col+2] <- algo_matrix[4, cycle_time_index]
      invoice.paid[is.na(invoice.paid[last_col+2]),last_col+2] <- 0
      colnames(invoice.paid)[last_col+2] <- paste(colnames(pred_matrix[cycle_time_index]), "MSE", sep = "_")
    }
    print(cycle_time_index)
  }

# Sum forecast for remaining steps and forecast payment date
  # Get forecast and MSE columns
    col_forecast <- c()
    col_mse <- c()
    for (column in (ncol_orig+1):ncol(invoice.paid)){
      if(substr(colnames(invoice.paid[column]),nchar(colnames(invoice.paid[column]))-7,nchar(colnames(invoice.paid[column]))) == "FORECAST")
        {col_forecast <- c(col_forecast, column)}
      else
        {col_mse <- c(col_mse, column)}
    }

  invoice.paid$DUE_DATE <- as.POSIXct(invoice.paid$DUE_DATE, format="%d-%b-%y %I:%M %p", usetz=FALSE)
  invoice.paid$LATEST_DATE <- as.POSIXct(invoice.paid$LATEST_DATE, format="%d-%b-%y %I:%M %p", usetz=FALSE)
  # Set Payment time to 5 PM
  invoice.paid$PAYMENT_DATE <- as.POSIXct(invoice.paid$PAYMENT_DATE, format="%d-%b-%y %I:%M %p", usetz=FALSE) + 17*60*60
  
  invoice_dates <- c("INVOICE_DATE", "INVOICE_RECEIVED_DATE", "ENTERED_DATE", "HOLD_PRE_FIRST_HOLD_DATE", "HOLD_PRE_HOLD_RELEASE_DATE", "VALIDATION_DATE", "LAST_APPROVAL_DATE", "HOLD_POST_FIRST_HOLD_DATE", "HOLD_POST_HOLD_RELEASE_DATE", "PAYMENT_DATE")
  invoice_date_replace <- c("INVOICE_DATE", "INVOICE_DATE", "ENTERED_DATE", "HOLD_PRE_FIRST_HOLD_DATE", "HOLD_PRE_HOLD_RELEASE_DATE", "ENTERED_DATE", "VALIDATION_DATE", "HOLD_POST_FIRST_HOLD_DATE", "HOLD_POST_HOLD_RELEASE_DATE", "PAYMENT_DATE")
  
  for (cycle_index in 1:length(col_forecast)){
    #invoice.paid[is.na(invoice.paid[invoice_dates[cycle_index]]),invoice_dates[cycle_index]] <- invoice.paid[is.na(invoice.paid[invoice_dates[cycle_index]]),invoice_date_replace[cycle_index]]
    last_col = ncol(invoice.paid)
    # convert invoice date columns to date data type
      invoice.paid[,invoice_dates[cycle_index]] <- as.POSIXct(invoice.paid[,invoice_dates[cycle_index]], format="%d-%b-%y %I:%M %p", usetz=FALSE)
    # Add up remaining cycle time forecasts to get estimate for total time remaining
      invoice.paid[last_col+1] <- rowSums(invoice.paid[col_forecast[cycle_index:length(col_forecast)]])
    # Add remaining cycle time to date to get estimated payment date
      invoice.paid[last_col+2] <- invoice.paid[,invoice_dates[cycle_index]] + 24*60*60*(rowSums(invoice.paid[col_forecast[cycle_index:length(col_forecast)]]))
    # Calcualte delta between actual payment date and estimated payment date
      invoice.paid[last_col+3] <- difftime(invoice.paid[,last_col+2], as.POSIXct(invoice.paid$PAYMENT_DATE, format="%d-%b-%y %I:%M %p", usetz=FALSE), units = 'days')
    # Caclulate delta between actual cycle time and estimated cycle time
      invoice.paid[last_col+4] <- invoice.paid[col_forecast[cycle_index]] - invoice.paid[31+cycle_index]
      
    colnames(invoice.paid)[last_col+1] <- paste("REMAINING_CYCLE_TIME_",cycle_index, sep = "")
    colnames(invoice.paid)[last_col+2] <- paste("ESTIMATED_DATE_",cycle_index, sep ="")
    colnames(invoice.paid)[last_col+3] <- paste("ACTUAL_FORECAST_DELTA_",cycle_index, sep ="")
    colnames(invoice.paid)[last_col+4] <- paste("CYCLE_ACTUAL_FORECAST_DELTA_",cycle_index, sep ="")
    print(cycle_index)
  }

# Fill in Cycle Times following hold steps that are NA with data from step before hold
  invoice.paid[is.na(invoice.paid$ESTIMATED_DATE_5),"ESTIMATED_DATE_5"] <- invoice.paid[is.na(invoice.paid$ESTIMATED_DATE_5),invoice_dates[3]] + 24*60*60*((invoice.paid[is.na(invoice.paid$ESTIMATED_DATE_5),"REMAINING_CYCLE_TIME_5"]))
  invoice.paid$ACTUAL_FORECAST_DELTA_5 <- difftime(invoice.paid$ESTIMATED_DATE_5, as.POSIXct(invoice.paid$PAYMENT_DATE, format="%d-%b-%y %I:%M %p", usetz=FALSE), units = 'days')
  
  invoice.paid[is.na(invoice.paid$ESTIMATED_DATE_9),"ESTIMATED_DATE_9"] <- invoice.paid[is.na(invoice.paid$ESTIMATED_DATE_9),invoice_dates[7]] + 24*60*60*((invoice.paid[is.na(invoice.paid$ESTIMATED_DATE_9),col_forecast[9]]))
  invoice.paid$ACTUAL_FORECAST_DELTA_9 <- difftime(invoice.paid$ESTIMATED_DATE_9, as.POSIXct(invoice.paid$PAYMENT_DATE, format="%d-%b-%y %I:%M %p", usetz=FALSE), units = 'days')

write.table(invoice.paid, file="paid_invoice.csv", sep=",",col.names = colnames(invoice.paid), row.names = FALSE)
