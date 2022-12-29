library(caret)
library(nnet)
library(pROC)

remove_invalid <- function(data) {
  for (i in 1:8) {
    indexes_to_remove <- which(is.na(data[[i]]))
    if (length(indexes_to_remove) != 0) {
      data <- data[-indexes_to_remove,]
    }
  }
  return(data)
}

train <- read.csv(file = '.\\data\\train.csv', header = T)
train$Survived <- ifelse(train$Survived == 1, 'Yes', 'No')
train <- train[-c(1,4,9,11)]

prevalence <- length(which(train[['Survived']] == 'Yes')) / length(train[['Survived']])
train <- remove_invalid(train)
prevalence <- length(which(train[['Survived']] == 'Yes')) / length(train[['Survived']])

set.seed(100)
ctrl <- trainControl(method = 'cv', number = 10,
                     summaryFunction = twoClassSummary,
                     classProbs = T, savePredictions = T)
nnGrid <- expand.grid(size = seq(1, 10), decay = seq(0, 0.5, 0.1))

Sys.time()
neural_network <- train(Survived ~ ., data = train,
                        method = 'nnet', maxit = 50000, tuneGrid = nnGrid,
                        trace = F, trControl = ctrl, metric = 'ROC')
Sys.time()

test <- read.csv(file = '.\\data\\test.csv', header = T)
test <- test[-c(3,8,10)]
test$Age <- replace(test$Age, is.na(test$Age), mean(test$Age[which(!is.na(test$Age))]))
test$Fare <- replace(test$Fare, is.na(test$Fare), mean(test$Fare[which(!is.na(test$Fare))]))

predictions <- predict(neural_network, newdata = test)
results <- data.frame(test[1], predictions)
colnames(results) <- c('PassengerId', 'Survived')
results$Survived <- ifelse(results$Survived == 'Yes', 1, 0)
write.csv(results, file = '.\\results.csv', row.names = FALSE)
