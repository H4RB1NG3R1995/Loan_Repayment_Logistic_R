#Logistic Regression Case Study 2
install.packages("moments", dependencies = TRUE)
#calling libraries
library(caret)# LOGISTIC MODEL
library(ggplot2)# VISUALIZATION
library(MASS)# VIF CALCULATION
library(car)# VIF CALCULATION
library(mlogit)# LOGISTIC MODEL
library(sqldf)#WOE & IV
library(Hmisc)#WOE & IV
library(aod)#WALD TEST
library(BaylorEdPsych)#R-SQUARE
library(ResourceSelection)#HOSMER LEMESHOW TEST
library(pROC)#ROC CURVE
library(ROCR)#ROC CURVE
library(caTools)#TRAIN AND TEST SPLIT
library(moments)
#setting working directory
Path<-"E:/IVY PRO SCHOOL/R/05 PREDICTIVE ANALYTICS PROJECTS/03 LOGISTIC REGRESSION/CASE STUDY2/02DATA"
setwd(Path)
getwd()

#reading the dataset
data<-read.csv("loans_imputed.csv", header = TRUE)
data1<-data
str(data1)
summary(data1)

#checking missing values
as.data.frame(colSums(is.na(data1)))


#conversion to factor variables
names<-c("credit.policy" ,"purpose" ,"not.fully.paid")
data1[,names]<-lapply(data1[,names], factor)
str(data1)
summary(data1)

#Removing outliers by quantile method
boxplot(data1$revol.bal, horizontal = T)
quantiles1=quantile(data1$revol.bal,c(0.95,0.96,0.963,0.965,0.97,0.98,0.99,0.995,0.996,0.997,0.998,0.999,0.9991,0.9992,0.9993,0.9994,0.9995,0.9996,0.9997,0.9998,0.9999,1))
quantiles1
max(data1$revol.bal)
quantiles_final1=quantile(data1$revol.bal,0.998)
quantiles_final1
data1$revol.bal = ifelse(data1$revol.bal > quantiles_final1 , quantiles_final1, data1$revol.bal)

#proportion of loans in the dataset not paid in full
8045/(8045+1533)

#splitting data into train and test
set.seed(145)#This is used to produce reproducible results, everytime we run the model

spl = sample.split(data1, 0.7)
train = subset(data1, spl == TRUE)
str(train)
dim(train)


test = subset(data1, spl == FALSE)
str(test)
dim(test)

#logistic regression model building on train dataset
#iteration 1
options(scipen = 999)
model0<-glm(not.fully.paid~., data = train, family = binomial())
summary(model0)

#iteration 2: dropping days.with.cr.line
model1<-glm(not.fully.paid~.-days.with.cr.line, data = train, family = binomial())
summary(model1)

#iteration 3: dropping dti
model2<-glm(not.fully.paid~.-days.with.cr.line-dti, data = train, family = binomial())
summary(model2)

#iteration 4: fixing classes
model3<-glm(not.fully.paid~credit.policy+I(purpose == "credit_card")+I(purpose == "debt_consolidation")+I(purpose == "small_business")+I(purpose == "major_purchase")+installment+int.rate+log.annual.inc+fico+revol.bal+revol.util+inq.last.6mths+delinq.2yrs+pub.rec, data = train, family = binomial())
summary(model3)

#iteration 5: dropping int.rate
model4<-glm(not.fully.paid~credit.policy+I(purpose == "credit_card")+I(purpose == "debt_consolidation")+I(purpose == "small_business")+I(purpose == "major_purchase")+installment+log.annual.inc+fico+revol.bal+revol.util+inq.last.6mths+delinq.2yrs+pub.rec, data = train, family = binomial())
summary(model4)

#iteration 6: dropping delinq.2yrs
model5<-glm(not.fully.paid~credit.policy+I(purpose == "credit_card")+I(purpose == "debt_consolidation")+I(purpose == "small_business")+I(purpose == "major_purchase")+installment+log.annual.inc+fico+revol.bal+revol.util+inq.last.6mths+pub.rec, data = train, family = binomial())
summary(model5)

#iteration 7: dropping pub.rec
model6<-glm(not.fully.paid~credit.policy+I(purpose == "credit_card")+I(purpose == "debt_consolidation")+I(purpose == "small_business")+I(purpose == "major_purchase")+installment+log.annual.inc+fico+revol.bal+revol.util+inq.last.6mths, data = train, family = binomial())
summary(model6) 

#iteration 8: dropping purpose == major_purchase
model7<-glm(not.fully.paid~credit.policy+I(purpose == "credit_card")+I(purpose == "debt_consolidation")+I(purpose == "small_business")+installment+log.annual.inc+fico+revol.bal+revol.util+inq.last.6mths, data = train, family = binomial())
summary(model7) #FINAL TRAIN MODEL

#checking VIF:
as.data.frame(vif(model7))

#CHECKING OVERALL FITNESS
wald.test(b=coef(model7), Sigma= vcov(model7), Terms=1:10)

#predicting power of model
PseudoR2(model7)

#lackfit deviance
residuals(model7) # deviance residuals
residuals(model7, "pearson") # pearson residuals

sum(residuals(model7, type = "pearson")^2)
deviance(model7)

#########Larger p value indicate good model fit
1-pchisq(deviance(model7), df.residual(model7)) #p-value=1

# Variable Importance of the model
varImp(model7)

# Predicted Probabilities
prediction1 <- predict(model7,newdata = train,type="response")
prediction1
max(prediction1)
min(prediction1)

rocCurve1   <- roc(response = train$not.fully.paid, predictor = prediction1, 
                  levels = rev(levels(train$not.fully.paid)))

#Metrics - Fit Statistics

predclass1 <-ifelse(prediction1>coords(rocCurve1,"best", transpose = TRUE)[1],1,0)
Confusion1 <- table(Predicted = predclass1,Actual = train$not.fully.paid)
AccuracyRate1 <- sum(diag(Confusion1))/sum(Confusion1)
Gini1 <-2*auc(rocCurve1)-1

AUCmetric1 <- data.frame(c(coords(rocCurve1,"best", transpose = TRUE),AUC=auc(rocCurve1),AccuracyRate=AccuracyRate1,Gini=Gini1))
AUCmetric1 <- data.frame(rownames(AUCmetric1),AUCmetric1)
rownames(AUCmetric1) <-NULL
names(AUCmetric1) <- c("Metric","Values")
AUCmetric1

#Confusion Matrix
Confusion1 
plot(rocCurve1)


#testing model on test dataset################################

modeltest0<-glm(not.fully.paid~credit.policy+I(purpose == "credit_card")+I(purpose == "debt_consolidation")+I(purpose == "small_business")+installment+log.annual.inc+fico+revol.bal+revol.util+inq.last.6mths, data = test, family = binomial())
summary(modeltest0)

#dropping revol.util
modeltest1<-glm(not.fully.paid~credit.policy+I(purpose == "credit_card")+I(purpose == "debt_consolidation")+I(purpose == "small_business")+installment+log.annual.inc+fico+revol.bal+inq.last.6mths, data = test, family = binomial())
summary(modeltest1)

#dropping credit_policy
modeltest2<-glm(not.fully.paid~I(purpose == "credit_card")+I(purpose == "debt_consolidation")+I(purpose == "small_business")+installment+log.annual.inc+fico+revol.bal+inq.last.6mths, data = test, family = binomial())
summary(modeltest2) #FINAL TEST MODEL

#checking VIF:
as.data.frame(vif(modeltest2))

#CHECKING OVERALL FITNESS
wald.test(b=coef(modeltest2), Sigma= vcov(modeltest2), Terms=1:8)

#predicting power of model
PseudoR2(modeltest2)

#lackfit deviance
residuals(modeltest2) # deviance residuals
residuals(modeltest2, "pearson") # pearson residuals

sum(residuals(modeltest2, type = "pearson")^2)
deviance(modeltest2)

#########Larger p value indicate good model fit
1-pchisq(deviance(modeltest2), df.residual(modeltest2)) #p-value=1

# Variable Importance of the model
varImp(modeltest2)

# Predicted Probabilities
prediction2 <- predict(modeltest2,newdata = test,type="response")
prediction2
max(prediction2)
min(prediction2)

rocCurve2   <- roc(response = test$not.fully.paid, predictor = prediction2, 
                  levels = rev(levels(test$not.fully.paid)))

#Metrics - Fit Statistics

predclass2 <-ifelse(prediction2>coords(rocCurve2,"best", transpose = TRUE)[1],1,0)
Confusion2 <- table(Predicted = predclass2,Actual = test$not.fully.paid)
AccuracyRate2 <- sum(diag(Confusion2))/sum(Confusion2)
Gini2 <-2*auc(rocCurve2)-1

AUCmetric2 <- data.frame(c(coords(rocCurve2,"best", transpose = TRUE),AUC=auc(rocCurve2),AccuracyRate=AccuracyRate2,Gini=Gini2))
AUCmetric2 <- data.frame(rownames(AUCmetric2),AUCmetric2)
rownames(AUCmetric2) <-NULL
names(AUCmetric2) <- c("Metric","Values")
AUCmetric2

#Confusion Matrix
Confusion2 
plot(rocCurve2)

