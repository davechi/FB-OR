
if(FALSE) {
  ## Load libraries
	install.packages("tree")
	install.packages("randomForest")
	install.packages("gbm")
	install.packages("rpart")
	install.packages('plyr')
	install.packages('ROracle')
	install.packages('RODBC')
	install.packages('RJDBC')
	
	library(tree)
	library(randomForest)
	library(gbm)
	library(rpart)

	## Read CSV file (header assumed), then put that into "csv.data" data object (any name is ok).
	## SQL query: /Users/davechi/Dropbox (Facebook)/1_SQL/Estimated_Payment_Date/estimated_payment_date_calc.sql
	invoice.data <- read.delim("cycle_time_ML_13.tsv")
}

# create a data frame to hold the columns to be used for prediction for each cycle time.
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

  # Use Count of attributes with high number of levels
  pred_matrix[1]=c(0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[2]=c(0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[3]=c(0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[4]=c(0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[5]=c(0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[6]=c(0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[7]=c(0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  pred_matrix[8]=c(0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0)
  pred_matrix[9]=c(0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0)
  
  # Cost Center as level
  # gbm does not currently handle categorical variables with more than 1024 levels
  #  pred_matrix[1]=c(0,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #  pred_matrix[2]=c(0,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #  pred_matrix[3]=c(0,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #  pred_matrix[4]=c(0,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #  pred_matrix[5]=c(0,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #  pred_matrix[6]=c(0,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #  pred_matrix[7]=c(0,0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0)
  #  pred_matrix[8]=c(0,0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0)
  #  pred_matrix[9]=c(0,0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0,0)
    
## Algorithm parameter optimization
  n_trees = c(500, 1000, 2000, 4000)
  shrinkage = c(0.001, 0.005, 0.01, 0.1)
  int_depth = c(4)
  #shrinkage = c(0.001, 0.005, 0.01, 0.1, 0.2)
  
  cycle_times <- as.data.frame(matrix("x",ncol=1,nrow = (ncol(pred_matrix))*length(n_trees)*length(int_depth)*length(shrinkage)), stringsAsFactors=FALSE)
  ml_param <- as.data.frame(matrix(0, ncol = 8, nrow = (ncol(pred_matrix))*length(n_trees)*length(int_depth)*length(shrinkage)))
  ml_results_df <- cbind(cycle_times, ml_param)
  colnames(ml_results_df) <- c("cycle_time", "datapoints", "index","trees","depth","shrinkage","run_time", "mse_training", "mse_test")

  for (cycle_time_index in 1:ncol(pred_matrix)){
  #for (cycle_time_index in c(4,5,8,9)){
    cycle_time <- colnames(pred_matrix)[cycle_time_index]
    col_pull <- which(pred_matrix[cycle_time_index] == 1)

    ## Create table for training and testing
    ml_data <- invoice.data[col_pull]
    ## Move cycle time column to front
    cycle_time_col <- match(colnames(pred_matrix[cycle_time_index]), names(ml_data))

    ml_data <- ml_data[c(names(ml_data[cycle_time_col]),names(ml_data)[-cycle_time_col])]
    
    ## Change name of response column
    colnames(ml_data)[1] <- "CYCLE_TIME"

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
    invoice.test=ml_data[-train ,"CYCLE_TIME"]
    datapoints = nrow(ml_data)

  	for (i in 1:length(n_trees)){
  		for (j in 1:length(int_depth)){
  			for (k in 1:length(shrinkage)){
  				# fit model
  				ptm <- Sys.time()
  				index = (cycle_time_index-1)*(length(n_trees)*length(int_depth)*length(shrinkage)) + (i-1)*(length(int_depth)*length(shrinkage)) + (j-1)*length(shrinkage) + k
  				print(index)
  				print(cycle_time)
  				boost.invoice=gbm(CYCLE_TIME~.,data=ml_data[train,],distribution="gaussian",n.trees=n_trees[i], interaction.depth=int_depth[j], shrinkage=shrinkage[k], verbose=F)
  				yhat_train.boost=predict(boost.invoice,newdata=ml_data[train,], n.trees=n_trees[i])
  				yhat_test.boost=predict(boost.invoice,newdata=ml_data[-train,], n.trees=n_trees[i])		
  				# write to results df
  				ml_results_df[index,1] <- cycle_time
  				ml_results_df[index,2] <- datapoints
  				ml_results_df[index,3] <- index
  				ml_results_df[index,4] <- n_trees[i]
  				ml_results_df[index,5] <- int_depth[j]
  				ml_results_df[index,6] <- shrinkage[k]
  				ml_results_df[index,7] <- difftime(Sys.time(), ptm, units = 'sec')
  				ml_results_df[index,8] <- mean((yhat_train.boost-invoice.train)^2)
  				ml_results_df[index,9] <- mean((yhat_test.boost-invoice.test)^2)
  			}
  		}
  	}
  }

write.table(ml_results_df, file="ml_results_df_4.csv", sep=",",col.names = colnames(ml_results_df))
