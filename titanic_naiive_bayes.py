import numpy as np
import pandas as pd
from sklearn.naive_bayes import CategoricalNB

# Read data
train_data = pd.read_csv('.\\data\\train.csv')
test_data = pd.read_csv('.\\data\\test.csv')

# Separate dependent variable from dependent variables
# Create dummy indicators of multinomial features
y = train_data["Survived"]
features = ["Pclass", "Sex", "SibSp", "Parch"]
X = pd.get_dummies(train_data[features])
X_test = pd.get_dummies(test_data[features])

# Create and fit model, make predictions
model = CategoricalNB()
model.fit(X, y)
print(X)
print(X_test)
predictions = model.predict(X_test)

# Write results to csv
output = pd.DataFrame({'PassengerId' : test_data.PassengerId, 'Survived' : predictions})
output.to_csv('results_naiive_bayes.csv', index = False)
