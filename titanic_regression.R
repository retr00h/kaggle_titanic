data <- read.csv(file = '.\\data\\train.csv', header = FALSE, sep = ',', stringsAsFactors = FALSE)
col_names <- data[1,]
data <- data[-1,]
colnames(data) <- col_names
remove(col_names)

clean_data <- function(data, test) {
  passenger_gender <- array()
  for (p in data[['Sex']]) {
    if (p == 'male') {
      passenger_gender <- append(passenger_gender, 0)
    } else {
      passenger_gender <- append(passenger_gender, 1)
    }
  }
  passenger_gender <- passenger_gender[-1]
  data['Sex'] <- passenger_gender
  
  if (!test) {
    data <- data[-c(3, 4, 6, 7, 8, 9, 11, 12)]
    data[1] <- as.numeric(data[[1]])
    data[2] <- as.numeric(data[[2]])
    data[3] <- as.numeric(data[[3]])
    data[4] <- as.numeric(data[[4]])
  } else {
    data <- data[-c(2, 3, 5, 6, 7, 8, 10, 11)]
    data[1] <- as.numeric(data[[1]])
    data[2] <- as.numeric(data[[2]])
    data[3] <- as.numeric(data[[3]])
  }
  
  return(data)
}

data <- clean_data(data, FALSE)
cor.test(data[['Survived']], data[['Sex']], alternative = 'greater', method = 'pearson') # p value = 2.2e-16
cor.test(data[['Survived']], data[['Fare']], alternative = 'greater', method = 'pearson') # p value = 1.578e-13

model_with_outliers <- lm(data[['Survived']] ~ data[['Sex']] + data[['Fare']])
summary(model_with_outliers)$r.squared # 0.3197
shapiro.test(model_with_outliers$residuals) # p value = 2.2e-16

# remove_outliers <- function(x1, x2, y) {
#   while (TRUE) {
#     m <- lm(y ~ x1 + x2)
#     distances <- cooks.distance(m)
#     if (max(distances) < (4 / length(y))) { break }
#     index_to_remove <- which.max(distances)
#     x1 <- x1[-index_to_remove]
#     x2 <- x2[-index_to_remove]
#     y <- y[-index_to_remove]
#   }
#   return (list(x1, x2, y))
# }
# 
# l <- remove_outliers(data[['Sex']], data[['Fare']], data[['Survived']])
# data_sex_without_outliers <- l[[1]]
# data_fare_without_outliers <- l[[2]]
# data_survived_without_outliers <- l[[3]]
# remove(l)
# 
# model_without_outliers <- lm(data_survived_without_outliers ~ data_sex_without_outliers + data_fare_without_outliers)
# summary(model_without_outliers)$r.squared # 0.3393
# shapiro.test(model_without_outliers$residuals) # p value = 2.2e-16

# remove(data_fare_without_outliers)
# remove(data_sex_without_outliers)
# remove(data_survived_without_outliers)
# remove(model_with_outliers)
remove(data)


test_data <- read.csv(file = '.\\data\\test.csv', header = FALSE, sep = ',', stringsAsFactors = FALSE)
col_names <- test_data[1,]
test_data <- test_data[-1,]
colnames(test_data) <- col_names
remove(col_names)

test_data <- clean_data(test_data, TRUE)
intercept <- model_with_outliers$coefficients[[1]]
sex_coefficient <- model_with_outliers$coefficients[[2]]
fare_coefficient <- model_with_outliers$coefficients[[3]]

df <- data.frame(PassengerId = c(), Survived = c())

for (i in 1:length(test_data[[1]])) {
  passenger_id <- test_data[i,1]
  sex <- test_data[i,2]
  fare <- test_data[i,3]
  if (is.na(sex)) { sex <- 0 }
  if (is.na(fare)) { fare <- 0 }
  survived <- intercept +
    (sex_coefficient * sex) +
    (fare_coefficient * fare) > 0.5
  if (survived) {
    # write passenger_id, 1
    df <- rbind(df, data.frame(PassengerId = c(passenger_id), Survived = c(1)))
  } else {
    # write passenger_id
    df <- rbind(df, data.frame(PassengerId = c(passenger_id), Survived = c(0)))
  }
}
write.csv(df, file = '.\\results.csv', row.names = FALSE)
