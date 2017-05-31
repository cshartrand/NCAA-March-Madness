#Exploratory R analysis of a logistic regression for NCAA tournament
#We will split 2002-2015 and 2016, then try to predict 2016 from the previous years model.
data <- full_tourney_data_0216

train_set <- data[1:911,]
test_set <- data[912:978,]

train_reg <- glm(Win~`Efficiency Margin`+`Offensive Efficiency`+`Defensive Efficiency`+`Tempo`+`Luck`
                 +`Strength of Schedule`+`Opponent Offense`+`Opponent Defense`+`Non-Conference Strength of Schedule`,
                 family = binomial(link = "logit"), data=train_set)

summary(train_reg) #the coefficient on luck is large but the standard error is not too bad considering the other standard errors
#in a sense we would expect a metric to gauge luck to be a large factor in determining winning for the NCAA tournament. Luck
#happens to move teams on time and time again.

table(train_set$Luck,train_set$Win) #looks okay, luck is not completely in line with winning

train_reg$fitted.values
#####
#Look at some validation

train_reduced <- glm(Win~+Tempo+Luck+`Strength of Schedule`+`Opponent Offense`+`Opponent Defense`,
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


##Still to come k-fold cross validation


