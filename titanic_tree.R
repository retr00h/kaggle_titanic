library(RWeka)
data <- read.csv(file = '.\\data\\train.csv', header = T,
                 sep = ',', stringsAsFactors = F)
training_data <- data[-c(1,4,9,11)]
training_data[which(training_data[1,] == 1)] <- T
training_data[which(training_data[1,] == 0)] <- F
model <- J48(Survived ~ ., data = training_data)

training_data[which(training_data[3,] == 'male')] <- 0
training_data[which(training_data[3,] == 'female')] <- 1

plot(training_data[['Age']], training_data[['Survived']])

model <- glm(Survived ~ Age, family = 'binomial', data = training_data)
x <- seq(min(training_data[['Age']]), max(training_data[['Age']]), 0.1)
x <- data.frame(x)
colnames(x) <- c('Age')
y <- predict(model, x)
lines(x[[1]], y)

threshold <- sum(training_data[['Survived']]) / length(training_data[[1]])
abline(h = threshold)
