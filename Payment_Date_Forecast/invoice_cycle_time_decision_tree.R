## Load library tree
install.packages("tree")
install.packages("randomForest")
install.packages("gbm")
install.packages("rpart")
install.packages('plyr')

library(tree)
library(randomForest)
library(gbm)
library(rpart)

## Read CSV file (header assumed), then put that into "csv.data" data object (any name is ok).
invoice.data <- read.delim("cycle_time_ML_4.tsv")

## This gives you a dialogue to choose a file, then the file is passed to read.csv() function
invoice.data <- read.delim(file.choose())

## Create table for training and testing
ml_data <- invoice.data[c("CYCLE_TIME_INVOICE_RECEIVED", "CNT_COSTCENTER", "CNT_CURRENCY", "CNT_VENDOR", "CNT_REQUESTER", "CNT_INVOICE_REQUESTER", "CNT_APPROVER_FIRST", "CNT_APPROVER_LAST", "INVOICE_CORRECTION", "INVOICE_TYPE_LOOKUP_CODE", "PAYMENT_METHOD_CODE", "RECEIPT_REQUIRED", "INVOICE_AMOUNT_USD", "PO_NON_PO", "ORG_ID", "DUE_DAYS")]

ml_data <- invoice.data[c("CYCLE_TIME_APPROVAL_PAYMENT", "CNT_COSTCENTER", "CNT_CURRENCY", "CNT_VENDOR", "CNT_REQUESTER", "CNT_INVOICE_REQUESTER", "CNT_APPROVER_FIRST", "CNT_APPROVER_LAST", "INVOICE_CORRECTION", "INVOICE_TYPE_LOOKUP_CODE", "PAYMENT_METHOD_CODE", "RECEIPT_REQUIRED", "INVOICE_AMOUNT_USD", "PO_NON_PO", "ORG_ID", "DUE_DAYS")]

ml_data <- invoice.data[c("CYCLE_TIME_HOLD_PREAPPROVAL", "HOLD_PRE_HOLD_REASON", "CNT_COSTCENTER", "CNT_CURRENCY", "CNT_VENDOR", "CNT_REQUESTER", "CNT_INVOICE_REQUESTER", "CNT_APPROVER_FIRST", "CNT_APPROVER_LAST", "INVOICE_CORRECTION", "INVOICE_TYPE_LOOKUP_CODE", "PAYMENT_METHOD_CODE", "RECEIPT_REQUIRED", "INVOICE_AMOUNT_USD", "PO_NON_PO", "ORG_ID", "DUE_DAYS")]


"CYCLE_TIME_INVOICE_RECEIVED"
"CYCLE_TIME_RECEIVED_ENTRY"
"CYCLE_TIME_ENTRY_HOLD"
"CYCLE_TIME_HOLD_PREAPPROVAL"
"CYCLE_TIME_ENTRY_VALIDATION"
"CYCLE_TIME_VALIDATION_APPROVAL"
"CYCLE_TIME_APPROVAL_HOLD"
"CYCLE_TIME_HOLD_POSTAPPROVAL"
"CYCLE_TIME_APPROVAL_PAYMENT"

"HOLD_PRE_HOLD_REASON"

## Change name of response column
colnames(ml_data)[1] <- "CYCLE_TIME"

## filter rows with NA
ml_data <- ml_data[complete.cases(ml_data),]

## filter rows with cycle time > 30 days
ml_data <- subset(ml_data, CYCLE_TIME <= 30)
ml_data <- subset(ml_data, CYCLE_TIME <= 100)

## Convert columns from Int to Factor
ml_data$PO_NON_PO = as.factor(ml_data$PO_NON_PO)
ml_data$ORG_ID = as.factor(ml_data$ORG_ID)
ml_data$DUE_DAYS = as.factor(ml_data$DUE_DAYS)

hist(ml_data$CYCLE_TIME)

## Create training data set
set.seed(1)
train = sample(1:nrow(ml_data), nrow(ml_data)/2)

## regression tree
tree.invoice=tree(CYCLE_TIME~.,ml_data, subset=train, control=tree.control(nrow(ml_data)/2, mincut = 5, minsize = 10, mindev = 0.0005))
summary(tree.invoice)

## test model
yhat=predict(tree.invoice ,newdata=ml_data[-train ,])
invoice.test=ml_data[-train ,"CYCLE_TIME"]
mean((yhat-invoice.test)^2)
	MSE
	[1] 45.2796 / mindev = 0.01
	[1] 37.13906 / mindev = 0.005

## Bagging
set.seed(1)
train = sample(1:nrow(ml_data), nrow(ml_data)/10)

bag.ml_data = randomForest(CYCLE_TIME~.,ml_data, subset=train, mtry=15, important=TRUE)
bag.ml_data

yhat_train.bag = predict(bag.ml_data ,newdata=ml_data[train ,])
invoice.train=ml_data[train ,"CYCLE_TIME"]
mean((yhat_train.bag-invoice.train)^2)

yhat.bag = predict(bag.ml_data ,newdata=ml_data[-train ,])
invoice.test=ml_data[-train ,"CYCLE_TIME"]
mean((yhat.bag-invoice.test)^2)
	MSE
	[1] 36.11735

## Random Forest

rf.ml_data = randomForest(CYCLE_TIME~.,ml_data, subset=train, mtry=5, important=TRUE)

yhat_train.rf = predict(rf.ml_data ,newdata=ml_data[train ,])
invoice.train=ml_data[train ,"CYCLE_TIME"]
mean((yhat_train.rf-invoice.train)^2)

yhat.rf = predict(rf.ml_data ,newdata=ml_data[-train ,])
invoice.test=ml_data[-train ,"CYCLE_TIME"]
mean((yhat.rf-invoice.test)^2)
	MSE
	[1] 35.37625 / mtry = 4
	[1] 35.28525 / mtry = 5
plot(yhat.rf, invoice.test)
abline (0 ,1)
varImpPlot(rf.ml_data)

## Boosting
set.seed(1)
train = sample(1:nrow(ml_data), nrow(ml_data)/2)
boost.invoice=gbm(CYCLE_TIME~.,data=ml_data[train,],distribution="gaussian",n.trees=5000, interaction.depth=4, shrinkage=0.2, verbose=F)

invoice.train=ml_data[train ,"CYCLE_TIME"]
yhat_train.boost=predict(boost.invoice,newdata=ml_data[train,], n.trees=5000)
mean((yhat_train.boost-invoice.train)^2)

invoice.test=ml_data[-train ,"CYCLE_TIME"]
yhat.boost=predict(boost.invoice,newdata=ml_data[-train,], n.trees=5000)
mean((yhat.boost-invoice.test)^2)
	MSE
	[1] 41.5347 / lambda = 0.001
	[1] 35.83138 / lambda = 0.01
	[1] 33.31209 / lambda = 0.2
	[1] 55.13242 / lambda = 1.0
summary(boost.invoice)


## Simple decision tree
tree.invoice=tree(CYCLE_TIME~INVOICE_AMOUNT_USD + ORG_ID + HOLD_PRE_RELEASE_REASON + CNT_VENDOR,ml_data, subset=train, control=tree.control(nrow(ml_data)/2, mincut = 5, minsize = 10, mindev = 0.0005))
summary(tree.invoice)

