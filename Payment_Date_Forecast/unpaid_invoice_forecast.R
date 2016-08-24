## R script to forecast future cycle times
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
  
  library(tree)
  library(randomForest)
  library(gbm)
  library(rpart)
  
  ## Read CSV file (header assumed), then put that into "csv.data" data object (any name is ok).
  invoice.data <- read.delim("cycle_time_ML_15.tsv")
  invoice.active <- read.delim("unpaid_invoices_13.tsv")
}

# create a data frame to hold the columns to be used for prediction
  pred_matrix <- data.frame(matrix(0, ncol(invoice.active), ncol = 9))
  
  rownames(pred_matrix) <- colnames(invoice.active)
  
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
  #pred_matrix[1]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #pred_matrix[2]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #pred_matrix[3]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #pred_matrix[4]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #pred_matrix[5]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #pred_matrix[6]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #pred_matrix[7]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #pred_matrix[8]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0)
  #pred_matrix[9]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0)

  pred_matrix[1]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0)
  pred_matrix[2]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0)
  pred_matrix[3]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0)
  pred_matrix[4]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0)
  pred_matrix[5]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0,0)
  pred_matrix[6]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0,0)
  pred_matrix[7]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0,0)
  pred_matrix[8]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0,0)
  pred_matrix[9]=c(1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0,0)
  
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

  if(is.null(model_list[[9]])){
    model_list <- vector(mode="list", length=ncol(pred_matrix))
  }
  
if(FALSE) {
#if(TRUE) {
# Create Boosted DT models
  for (cycle_time_index in 1:ncol(pred_matrix)){
  #for (cycle_time_index in 3:3){
    cycle_time <- colnames(pred_matrix)[cycle_time_index]
    col_pull <- which(pred_matrix[cycle_time_index] == 1)
    
    ## Create table for training and testing
    ml_data <- invoice.data[col_pull]
    
    ## Move cycle time column to front
    cycle_time_col <- match(colnames(pred_matrix[cycle_time_index]), names(ml_data))
    ml_data <- ml_data[c(names(ml_data[cycle_time_col]),names(ml_data)[-cycle_time_col])]
    ## Change name of response column
    colnames(ml_data)[1] <- "CYCLE_TIME"
    ## Get col number of INVOICE_ID to remove from modeling
    inv_id_col = which(colnames(ml_data)=='INVOICE_ID')
    
    ## filter rows without relevant cycle time
    ml_data <- ml_data[!is.na(ml_data[1]),]
    ## filter rows with cycle time > 60 days
    ml_data <- subset(ml_data, CYCLE_TIME <= 60)
    
    ## Convert columns from Int to Factor
    ml_data$PO_NON_PO = as.factor(ml_data$PO_NON_PO)
    ml_data$ORG_ID = as.factor(ml_data$ORG_ID)
    ml_data$DUE_DAYS = as.factor(ml_data$DUE_DAYS)
    
    ## Create training data set
    set.seed(1)
    train = sample(1:nrow(ml_data), nrow(ml_data)/2)
    invoice.train=ml_data[train ,"CYCLE_TIME"]
    
    boost.invoice = gbm(CYCLE_TIME~.,data=ml_data[train,-inv_id_col],distribution="gaussian",n.trees=algo_matrix[1, cycle_time_index], interaction.depth=algo_matrix[2, cycle_time_index], shrinkage=algo_matrix[3, cycle_time_index], verbose=F)
    model_list[[cycle_time_index]] <- boost.invoice
    print(cycle_time_index)
  }
}
  
# Loop through predicting cycle times in chronological order

ncol_orig <- ncol(invoice.active)  
cycle_time_col_names = c("CYCLE_TIME_INVOICE_RECEIVED", "CYCLE_TIME_RECEIVED_ENTRY", "CYCLE_TIME_ENTRY_HOLD", "CYCLE_TIME_HOLD_PREAPPROVAL", "CYCLE_TIME_ENTRY_VALIDATION", "CYCLE_TIME_VALIDATION_APPROVAL", "CYCLE_TIME_APPROVAL_HOLD", "CYCLE_TIME_HOLD_POSTAPPROVAL", "CYCLE_TIME_APPROVAL_PAYMENT") 
cycle_time_col_op <- match(cycle_time_col_names, colnames(invoice.active))

for (cycle_time_index in 1:ncol(pred_matrix)){
#for (cycle_time_index in c(2:2)){
  cycle_time <- colnames(pred_matrix)[cycle_time_index]
  col_pull <- which(pred_matrix[cycle_time_index] == 1)
  
  ## Create table for training and testing
  ml_data <- invoice.active[col_pull]
  
  ## Move cycle time column to front
  cycle_time_col <- match(colnames(pred_matrix[cycle_time_index]), names(ml_data))
  ml_data <- ml_data[c(names(ml_data[cycle_time_col]),names(ml_data)[-cycle_time_col])]
  ## Change name of response column
  colnames(ml_data)[1] <- "CYCLE_TIME"
  ## Get col number of INVOICE_ID to remove from modeling
  inv_id_col = which(colnames(ml_data)=='INVOICE_ID')
  
  ## filter to rows missing cycle time being modeled
  ml_data <- ml_data[is.na(ml_data[1]),]

  ## Convert columns from Int to Factor
  ml_data$PO_NON_PO = as.factor(ml_data$PO_NON_PO)
  ml_data$ORG_ID = as.factor(ml_data$ORG_ID)
  ml_data$DUE_DAYS = as.factor(ml_data$DUE_DAYS)
  
  # Fit model forecast
  forecast.boost=predict(model_list[[cycle_time_index]],newdata=ml_data[,-inv_id_col], n.trees=algo_matrix[1, cycle_time_index])
  
  # write forecast and MSE data back to table
  ml_data[1] = forecast.boost
  
  # Add cycle time forecast and MSE to invoice.active
  if (nrow(ml_data) > 0){
    ml_data[ml_data[1] < 0, 1] = 0
    last_col = ncol(invoice.active)
    # forecast
    invoice.active[is.na(invoice.active[cycle_time_col_op[cycle_time_index]]),last_col+1] <- ml_data[match(invoice.active[is.na(invoice.active[cycle_time_col_op[cycle_time_index]]),1], ml_data$INVOICE_ID),1]
    invoice.active[is.na(invoice.active[last_col+1]),last_col+1] <- 0
    colnames(invoice.active)[last_col+1] <- paste(colnames(pred_matrix[cycle_time_index]), "FORECAST", sep = "_")
    # MSE    
    invoice.active[is.na(invoice.active[cycle_time_col_op[cycle_time_index]]),last_col+2] <- algo_matrix[4, cycle_time_index]
    invoice.active[is.na(invoice.active[last_col+2]),last_col+2] <- 0
    colnames(invoice.active)[last_col+2] <- paste(colnames(pred_matrix[cycle_time_index]), "MSE", sep = "_")
    }
      print(cycle_time_index)
}

# Sum forecast for remaining steps and forecast payment date
  col_forecast <- c()
  col_mse <- c()
  for (column in (ncol_orig+1):ncol(invoice.active)){
    if(substr(colnames(invoice.active[column]),nchar(colnames(invoice.active[column]))-7,nchar(colnames(invoice.active[column]))) == "FORECAST")
    {col_forecast <- c(col_forecast, column)}
    else
    {col_mse <- c(col_mse, column)}
  }
  
    invoice.active$DUE_DATE <- as.POSIXct(invoice.active$DUE_DATE, format="%d-%b-%y %I:%M %p", usetz=FALSE)
    invoice.active$LATEST_DATE <- as.POSIXct(invoice.active$LATEST_DATE, format="%d-%b-%y %I:%M %p", usetz=FALSE)
    invoice.active$REMAINING_CYCLE_TIME <- rowSums(invoice.active[col_forecast])
    invoice.active$ESTIMATED_DATE_ACTUAL <- invoice.active$LATEST_DATE + rowSums(invoice.active[col_forecast])
    
# Sum MSE for remaining steps and calculated RMS
    invoice.active$RMS <- sqrt(rowSums(invoice.active[col_mse]))
# Bookend estimated payment data [GREATEST(Due Date, TODAY) - GREATEST(Due Date + 30, TODAY + 30]
    invoice.active$ESTIMATED_DATE <- invoice.active$DUE_DATE
    invoice.active$ESTIMATED_DATE[invoice.active$ESTIMATED_DATE_ACTUAL > invoice.active$ESTIMATED_DATE] <- invoice.active$ESTIMATED_DATE_ACTUAL[invoice.active$ESTIMATED_DATE_ACTUAL > invoice.active$ESTIMATED_DATE]
    invoice.active$ESTIMATED_DATE[invoice.active$ESTIMATED_DATE > invoice.active$DUE_DATE + 30] <- invoice.active$DUE_DATE[invoice.active$ESTIMATED_DATE > invoice.active$DUE_DATE + 30] + 30
    invoice.active$ESTIMATED_DATE[invoice.active$ESTIMATED_DATE <= Sys.time()] <- Sys.time() + invoice.active$REMAINING_CYCLE_TIME[invoice.active$ESTIMATED_DATE <= Sys.time()] + (Sys.time() - invoice.active$ESTIMATED_DATE[invoice.active$ESTIMATED_DATE <= Sys.time()])

  # Create data frame for Oracle table
  # INVOICE_ID, ACTUAL_ESTIMATED_PAYMENT_DATE, ESTIMATE_RMS, ML_VERSION, ESTIMATED_PAYMENT_DATE, CREATED_DATE, CREATED_BY, LAST_UPDATED_DATE, LAST_UPDATED_BY
    forecast_col_names = c("INVOICE_ID", "ESTIMATED_DATE_ACTUAL", "RMS", "ESTIMATED_DATE")
    output_col <- match(forecast_col_names, colnames(invoice.active))
    
    forecast_table <- invoice.active[output_col]
    forecast_table$ML_VERSION <- 'ML0001'
    forecast_table$CREATED_DATE <- Sys.time()
    forecast_table$CREATED_BY <- 216575
    forecast_table$LAST_UPDATED_DATE <- Sys.time()
    forecast_table$LAST_UPDATED_BY <- 216575
    
    write.table(forecast_table, file="active_invoice_payment_forecast.csv", sep=",",col.names = colnames(forecast_table), row.names = FALSE)
    write.table(invoice.active, file="active_invoice.csv", sep=",",col.names = colnames(invoice.active), row.names = FALSE)
    