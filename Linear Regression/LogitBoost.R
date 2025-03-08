# Load necessary libraries
library(readxl)
library(LogitBoost)
library(ggplot2)
library(pROC)
library(caret)
library(dplyr)
library(tidyr)

# Load the dataset
file_path <- "C:\\Users\\clob9\\Desktop\\NCI60_dataset.xlsx"
df <- read_excel(file_path)
head(df)

# Remove the CellLine column (not needed for modeling)
df <- df[, -1]

# Convert CancerType to factor (required for classification)
df$CancerType <- as.factor(df$CancerType)

# Separate the target variable (CancerType) from the features
Label <- df$CancerType  # Target variable
Data <- df[, -ncol(df)]  # Features (all columns except the last one)

# Reduce the number of features by selecting the top N most variable genes
N <- 50  # Select the top 50 features (you can adjust this number)
feature_variance <- apply(Data, 2, var)  # Calculate variance for each feature
top_features <- order(feature_variance, decreasing = TRUE)[1:N]  # Select top N features
Data_reduced <- Data[, top_features]  # Keep only the top N features

# Convert the reduced feature data to a numeric matrix
Data_reduced <- as.matrix(Data_reduced)

# Train the LogitBoost model on the reduced dataset
model <- LogitBoost(Data_reduced, Label)

# Predict on the same dataset (to check model fit)
Lab_prob <- predict(model, Data_reduced, type = "raw")  # Get probabilities for each class
Lab <- colnames(Lab_prob)[max.col(Lab_prob)]  # Get the class with the highest probability

# Create a data frame to compare predictions with actual values
results <- data.frame(
  CellLine = row.names(df),  # Add cell line identifiers
  Actual = df$CancerType,    # Actual cancer types
  Predicted = Lab            # Predicted cancer types
)

# Print the results
print(results)

# Evaluate performance
conf_matrix <- table(results$Actual, results$Predicted)
print("Confusion Matrix:")
print(conf_matrix)

# Calculate accuracy
accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix)
print(paste("Accuracy:", accuracy))

# --------------------------
# 1. Extract Coefficients (Feature Importance)
# --------------------------
# LogitBoost does not provide coefficients directly, so we use feature importance
feature_importance <- data.frame(
  Feature = colnames(Data_reduced),
  Importance = apply(Data_reduced, 2, var)  # Use variance as a proxy for importance
)

# Sort features by importance
feature_importance <- feature_importance[order(feature_importance$Importance, decreasing = TRUE), ]

# Print the top 20 features
print("Top 20 Features by Importance:")
print(feature_importance[1:20, ])

# --------------------------
# 2. Calculate RMSE
# --------------------------
# Convert actual labels to binary indicators
actual_binary <- model.matrix(~ Actual - 1, data = results)

# Calculate RMSE
rmse <- sqrt(mean((as.numeric(actual_binary) - as.numeric(Lab_prob))^2))
print(paste("RMSE:", rmse))

# --------------------------
# 3. Confusion Matrix
# --------------------------
# Convert confusion matrix to a data frame for ggplot
conf_matrix_df <- as.data.frame(conf_matrix)
colnames(conf_matrix_df) <- c("Actual", "Predicted", "Freq")

# Plot the confusion matrix as a heatmap
ggplot(conf_matrix_df, aes(x = Actual, y = Predicted, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = Freq), color = "white", size = 5) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Confusion Matrix",
       x = "Actual Cancer Type",
       y = "Predicted Cancer Type",
       fill = "Frequency") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# --------------------------
# 4. Fancy AUC Graph (Multiclass ROC Curve)
# --------------------------
# Calculate multiclass ROC curve
roc_curve <- multiclass.roc(results$Actual, as.numeric(factor(results$Predicted)))
roc_curve
