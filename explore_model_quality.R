#Exploratory R analysis of a logistic regression for NCAA tournament
#We will split 2002-2015 and 2016, then try to predict 2016 from the previous years model.

setwd('/Users/cshartrand/Documents/Python/NCAA-March-Madness/data')
data <- read.csv('full-tourney-data-0216.csv')

train_set <- data[1:911,]
test_set <- data[912:978,]

train_reg <- glm(Win~Efficiency.Margin+Offensive.Efficiency+Defensive.Efficiency+Tempo+Luck
                 +Strength.of.Schedule+Opponent.Offense+Opponent.Defense+Non.Conference.Strength.of.Schedule,
                 family = binomial(link = "logit"), data=train_set)

summary(train_reg) #the coefficient on luck is large but the standard error is not too bad considering the other standard errors
#in a sense we would expect a metric to gauge luck to be a large factor in determining winning for the NCAA tournament. Luck
#happens to move teams on time and time again.

table(train_set$Luck,train_set$Win) #looks okay, luck is not completely in line with winning

train_reg$fitted.values
#################################################################################################################
#Look at some validation

train_reduced <- glm(Win~+Tempo+Luck+Strength.of.Schedule+Opponent.Offense+Opponent.Defense,
                  family = binomial(link = "logit"), data=train_set)

train_null <-glm(Win~1,family = binomial(link = "logit"), data=train_set)

anova(train_reduced,train_reg,test="Chisq") #full model is better at 2.2e-16
anova(train_null,train_reg,test='Chisq') #full model is better than null at 2.2e-16

#Check out a plot based on the combination of the two most significant predictors
attach(train_set)
plot(Luck,Tempo,pch=(Win+1),col=(Win+1))
legend(-0.22,15,c("Win 0","Win 1"),col=c(1,2),pch=c(1,2))
detach(train_set)

#Pseudo R^2
library(pscl)
pR2(train_reg) #.7433750 from the McFadden statistic. Seems like the model has some predictive strength

#Hosmer-Lemeshow Statistic
library(MKmisc)
HLgof.test(fit = fitted(train_reg), obs = train_set$Win)
#not enough evidence to reject null hypothesis that current model is good

#Importance of the Variables
library(caret)
varImp(train_reg) #absolute 't-statistic' values for the model

#Classification Rate for the training model
pred = predict(train_reg, newdata=test_set,typ='response')
pred_win = rep(0,67)
for (i in 1:67){
  if (pred[i] >= 0.50){
    pred_win[i] = 1
  }
}
win_2016 = test_set$Win
accuracy <- table(pred_win, win_2016)
sum(diag(accuracy))/sum(accuracy)


#Some k-fold cross validation
ctrl <- trainControl(method = "repeatedcv", number = 10, savePredictions = TRUE)

modcv_fit <- train(Win~Efficiency.Margin+Offensive.Efficiency+Defensive.Efficiency+Tempo+Luck
                 +Strength.of.Schedule+Opponent.Offense+Opponent.Defense+Non.Conference.Strength.of.Schedule,  
                 data=train_set, method="glm", family="binomial",
                 trControl = ctrl, tuneLength = 5)

pred = predict(modcv_fit, newdata=test_set)
pred_win = rep(0,67)
for (i in 1:67){
  if (pred[i] >= 0.50){
    pred_win[i] = 1
  }
}
confusionMatrix(pred_win, win_2016) #sensitivity and specificity are (.714,.956)
#Let's see how this changes when we up from 10 to 50

ctrl50 <- trainControl(method = "repeatedcv", number = 50, savePredictions = TRUE)

modcv_fit50 <- train(Win~Efficiency.Margin+Offensive.Efficiency+Defensive.Efficiency+Tempo+Luck
                   +Strength.of.Schedule+Opponent.Offense+Opponent.Defense+Non.Conference.Strength.of.Schedule,  
                   data=train_set, method="glm", family="binomial",
                   trControl = ctrl50, tuneLength = 5)

pred = predict(modcv_fit50, newdata=test_set)
pred_win = rep(0,67)
win_2016 = test_set$Win
for (i in 1:67){
  if (pred[i] >= 0.50){
    pred_win[i] = 1
  }
}
confusionMatrix(pred_win, win_2016) #sensitivity and specificity are (.714,.956), remains unchanged

#################################################################################################################
#Let's Load in the 2017 data for testing, add 2016 to training and compare the results
data_2 = read.csv('full-tourney-data-0217.csv')

train_2 <- data_2[1:978,]
test_2 <- data_2[979:1045,]

train_reg2 <- glm(Win~Efficiency.Margin+Offensive.Efficiency+Defensive.Efficiency+Tempo+Luck
                 +Strength.of.Schedule+Opponent.Offense+Opponent.Defense+Non.Conference.Strength.of.Schedule,
                 family = binomial(link = "logit"), data=train_2)

summary(train_reg2) #this model looks slightly better as the coefficient of luck is slightly reduced as is it's standard error
#it is more than probable that the more years I add to the model with data, the less the relative luckiness will matter to the model's
#understanding of how the tournament works

#Let's run the cross validation with 2016 included and check out the confusion matrix
ctrl2 <- trainControl(method = "repeatedcv", number = 10, savePredictions = TRUE)

modcv_fit2 <- train(Win~Efficiency.Margin+Offensive.Efficiency+Defensive.Efficiency+Tempo+Luck
                   +Strength.of.Schedule+Opponent.Offense+Opponent.Defense+Non.Conference.Strength.of.Schedule,  
                   data=train_2, method="glm", family="binomial",
                   trControl = ctrl2, tuneLength = 5)

pred = predict(modcv_fit2, newdata=test_2)
pred_win = rep(0,67)
for (i in 1:67){
  if (pred[i] >= 0.50){
    pred_win[i] = 1
  }
}
win_2017 = test_2$Win
confusionMatrix(pred_win, win_2017) #slightly better sensitivity and slightly worse specificity (.823,.920)

#How will cv change if I up the values from 10 to 50? Let's see
ctrl250 <- trainControl(method = "repeatedcv", number = 50, savePredictions = TRUE)

modcv_fit250 <- train(Win~Efficiency.Margin+Offensive.Efficiency+Defensive.Efficiency+Tempo+Luck
                    +Strength.of.Schedule+Opponent.Offense+Opponent.Defense+Non.Conference.Strength.of.Schedule,  
                    data=train_2, method="glm", family="binomial",
                    trControl = ctrl250, tuneLength = 5)

pred = predict(modcv_fit250, newdata=test_2)
pred_win = rep(0,67)
for (i in 1:67){
  if (pred[i] >= 0.50){
    pred_win[i] = 1
  }
}
win_2017 = test_2$Win
confusionMatrix(pred_win, win_2017) #sensitivity and specificity are (.824,.920), remains unchanged



#To this end, lets train with 2017 added in just because I'm curious

train_reg3 <- glm(Win~Efficiency.Margin+Offensive.Efficiency+Defensive.Efficiency+Tempo+Luck
                  +Strength.of.Schedule+Opponent.Offense+Opponent.Defense+Non.Conference.Strength.of.Schedule,
                  family = binomial(link = "logit"), data=data_2)

summary(train_reg3) #here again, the estimate on luck was reduced as was it's standard error
