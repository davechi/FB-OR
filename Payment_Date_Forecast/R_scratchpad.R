> length(invoice.paid[,invoice_dates[7]] + rowSums(invoice.paid[col_forecast[7:length(col_forecast)]]))
[1] 71962
> nrow(invoice.paid[is.na(invoice.paid$ESTIMATED_DATEL_9),])
[1] 71145

> nrow(invoice.paid[!is.na(invoice.paid$ESTIMATED_DATE_1),])
[1] 71962
> nrow(invoice.paid[!is.na(invoice.paid$ESTIMATED_DATE_2),])
[1] 71520
> nrow(invoice.paid[!is.na(invoice.paid$ESTIMATED_DATE_3),])
[1] 71962
> nrow(invoice.paid[!is.na(invoice.paid$ESTIMATED_DATE_4),])
[1] 11981
> nrow(invoice.paid[!is.na(invoice.paid$ESTIMATED_DATE_5),])
[1] 11981
> nrow(invoice.paid[!is.na(invoice.paid$ESTIMATED_DATE_6),])
[1] 66601
> nrow(invoice.paid[!is.na(invoice.paid$ESTIMATED_DATE_7),])
[1] 66601
> nrow(invoice.paid[!is.na(invoice.paid$ESTIMATED_DATE_8),])
[1] 817
> nrow(invoice.paid[!is.na(invoice.paid$ESTIMATED_DATE_9),])
[1] 817


head(as.POSIXct(invoice.paid$LATEST_DATE, format="%d-%b-%y %I:%M %p", usetz=FALSE))

summary(model_list[[4]])


cols<-c(1,3,5,8,9,10,13,14,15)
ml_data_hold <- ml_data[cols]
ml_data_hold$HOLD_PRE_HOLD_REASON = as.character(ml_data_hold$HOLD_PRE_HOLD_REASON)
x <- count(ml_data_hold$HOLD_PRE_HOLD_REASON)
x[x$freq>25,]
nrow(x[x$freq>25,])
reason_list <- x[x$freq>25,]
reason_list <- c(sapply(reason_list$x, as.character))
reason_list
test <- ml_data_hold[which(ml_data_hold$HOLD_PRE_HOLD_REASON %in% reason_list) ,]
test$HOLD_PRE_HOLD_REASON = as.factor(test$HOLD_PRE_HOLD_REASON)
str(test)

tree_hold = tree(CYCLE_TIME~., test)

ml_data_hold$HOLD_PRE_HOLD_REASON = as.factor(ml_data_hold$HOLD_PRE_HOLD_REASON)
str(ml_data_hold)

HOLD_PRE_CNT                                 HOLD_PRE_CNT 56.855551456
HOLD_PRE_HOLD_REASON                 HOLD_PRE_HOLD_REASON 28.515747837
ORG_ID                                             ORG_ID  3.970185907
CYCLE_TIME_RECEIVED_ENTRY       CYCLE_TIME_RECEIVED_ENTRY  2.206386664
CNT_COSTCENTER                             CNT_COSTCENTER  1.962037501
CNT_VENDOR                                     CNT_VENDOR  1.848070164
CYCLE_TIME_ENTRY_HOLD               CYCLE_TIME_ENTRY_HOLD  1.562287677
CYCLE_TIME_INVOICE_RECEIVED   CYCLE_TIME_INVOICE_RECEIVED  1.465333929