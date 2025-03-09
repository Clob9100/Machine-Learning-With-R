# Load necessary libraries
library(readxl)
library(caTools)
library(ggplot2)
library(pROC)
library(caret)
library(dplyr)
library(tidyr)

# Load the dataset
file_path <- "C:\\Users\\clob9\\Desktop\\NCI60_dataset.xlsx"
df <- read_excel(file_path)
head(df)

# Focus on a subset of cancer types for classification
selected_cancers <- c("NSCLC", "RENAL", "MELANOMA", "BREAST", "COLON", "OVARIAN", "CNS", "PROSTATE")
df <- df[df$CancerType %in% selected_cancers, ]

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

# Bar plot of feature importance
library(ggplot2)

# Create the bar plot
ggplot(feature_importance[1:20, ], aes(x = reorder(Feature, Importance), y = Importance, fill = Importance)) +
  geom_bar(stat = "identity", width = 0.8) +  # Use a gradient fill based on importance
  geom_text(aes(label = round(Importance, 2)), hjust = 1.1, color = "white", size = 4) +  # Add value labels
  coord_flip() +  # Flip coordinates for horizontal bars
  scale_fill_gradient(low = "lightblue", high = "darkblue") +  # Gradient fill for bars
  labs(
    title = "Top 20 Features by Importance",
    subtitle = "Features ranked by their variance in the dataset",
    x = "Feature",
    y = "Importance (Variance)",
    caption = "Data source: NCI60 dataset"
  ) +
  theme_minimal(base_size = 14) +  # Use a minimal theme with larger base font size
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Rotate x-axis labels
    axis.text.y = element_text(size = 12),  # Adjust y-axis label size
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),  # Center and bold the title
    plot.subtitle = element_text(size = 14, hjust = 0.5),  # Center the subtitle
    plot.caption = element_text(size = 10, hjust = 1, color = "gray50"),  # Add a caption
    panel.grid.major.y = element_blank(),  # Remove horizontal grid lines
    panel.grid.minor.y = element_blank(),  # Remove minor grid lines
    legend.position = "none"  # Remove the legend (since fill is self-explanatory)
  )

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

# Create Confusion Matrix as heatmap
ggplot(conf_matrix_df, aes(x = Actual, y = Predicted, fill = Freq)) +
  geom_tile(color = "white", size = 0.5) +  # Add white borders to tiles
  geom_text(aes(label = Freq), color = "white", size = 5, fontface = "bold") +  # Add bold text labels
  scale_fill_gradient(low = "lightblue", high = "darkblue", name = "Frequency") +  # Gradient fill for tiles
  labs(
    title = "Confusion Matrix",
    subtitle = "Comparison of Actual vs. Predicted Cancer Types",
    x = "Actual Cancer Type",
    y = "Predicted Cancer Type",
    caption = "Data source: NCI60 dataset"
  ) +
  theme_minimal(base_size = 14) +  # Use a minimal theme with larger base font size
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Rotate x-axis labels
    axis.text.y = element_text(size = 12),  # Adjust y-axis label size
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),  # Center and bold the title
    plot.subtitle = element_text(size = 14, hjust = 0.5),  # Center the subtitle
    plot.caption = element_text(size = 10, hjust = 1, color = "gray50"),  # Add a caption
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    legend.position = "right",  # Move the legend to the right
    legend.title = element_text(size = 12),  # Adjust legend title size
    legend.text = element_text(size = 10)  # Adjust legend text size
  )

# --------------------------
# 4. AUC Evaluation
# --------------------------
# Calculate multiclass ROC curve
roc_curve <- multiclass.roc(results$Actual, as.numeric(factor(results$Predicted)))
roc_curve

# Plot the ROC curve
plot(roc_curve$rocs[[1]], col = rainbow(length(unique(results$Actual))), lwd = 2, main = "Multiclass ROC Curve")


# --------------------------
# 4. TRAINING AND TESTING
# --------------------------

# Split data into training and testing sets
set.seed(123)  # For reproducibility
train_index <- createDataPartition(Label, p = 0.8, list = FALSE)
Data_train <- Data_reduced[train_index, ]
Label_train <- Label[train_index]
Data_test <- Data_reduced[-train_index, ]
Label_test <- Label[-train_index]

# Train the LogitBoost model on the training set
model <- LogitBoost(Data_train, Label_train)

# Predict on the test set
Lab_prob <- predict(model, Data_test, type = "raw")  # Get probabilities for each class

# Evaluate performance on the test set
Lab <- colnames(Lab_prob)[max.col(Lab_prob)]  # Get the class with the highest probability

# Create a data frame to compare predictions with actual values
results_test <- data.frame(
  CellLine = row.names(df)[-train_index],  # Add cell line identifiers
  Actual = df$CancerType[-train_index],    # Actual cancer types
  Predicted = Lab                         # Predicted cancer types
)

# Print the results
print(results_test)

# Evaluate performance
conf_matrix_test <- table(results_test$Actual, results_test$Predicted)

# Calculate accuracy
accuracy_test <- sum(diag(conf_matrix_test)) / sum(conf_matrix_test)
print(paste("Accuracy on Test Set:", accuracy_test))

# Calculate multiclass ROC curve for the test set
roc_curve_test <- multiclass.roc(results_test$Actual, as.numeric(factor(results_test$Predicted)))
roc_curve_test

# -----------------------------------
# 5. Feature Importance on Test Set
# -----------------------------------
# Extract feature importance on the test set
feature_importance_test <- data.frame(
  Feature = colnames(Data_test),
  Importance = apply(Data_test, 2, var)  # Use variance as a proxy for importance
)

# Sort features by importance
feature_importance_test <- feature_importance_test[order(feature_importance_test$Importance, decreasing = TRUE), ]

# Print the top 20 features
print("Top 20 Features by Importance on Test Set:")
print(feature_importance_test[1:20, ])


# Bar plot of feature importance on the test set
ggplot(feature_importance_test[1:20, ], aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "skyblue", width = 0.8) +  # Use a solid fill color
  geom_text(aes(label = round(Importance, 2)), hjust = 1.1, color = "white", size = 4, fontface = "bold") +  # Add value labels
  coord_flip() +  # Flip coordinates for horizontal bars
  labs(
    title = "Top 20 Features by Importance on Test Set",
    subtitle = "Features ranked by their importance in the test set",
    x = "Feature",
    y = "Importance",
    caption = "Data source: NCI60 dataset"
  ) +
  theme_minimal(base_size = 14) +  # Use a minimal theme with larger base font size
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Rotate x-axis labels
    axis.text.y = element_text(size = 12),  # Adjust y-axis label size
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),  # Center and bold the title
    plot.subtitle = element_text(size = 14, hjust = 0.5),  # Center the subtitle
    plot.caption = element_text(size = 10, hjust = 1, color = "gray50"),  # Add a caption
    panel.grid.major.y = element_blank(),  # Remove horizontal grid lines
    panel.grid.minor.y = element_blank()  # Remove minor grid lines
  )

# -----------------------------------
# 6. Confusion Matrix on Test Set
# -----------------------------------
# Convert confusion matrix to a data frame for ggplot
conf_matrix_test_df <- as.data.frame(conf_matrix_test)
colnames(conf_matrix_test_df) <- c("Actual", "Predicted", "Freq")

# Create confusion matrix as a heatmap for the test set
library(ggplot2)

# Create the plot
ggplot(conf_matrix_test_df, aes(x = Actual, y = Predicted, fill = Freq)) +
  geom_tile(color = "white", size = 0.5) +  # Add white borders to tiles
  geom_text(aes(label = Freq), color = "white", size = 5, fontface = "bold") +  # Add bold text labels
  scale_fill_gradient(low = "lightblue", high = "darkblue", name = "Frequency") +  # Gradient fill for tiles
  labs(
    title = "Confusion Matrix on Test Set",
    subtitle = "Comparison of Actual vs. Predicted Cancer Types",
    x = "Actual Cancer Type",
    y = "Predicted Cancer Type",
    caption = "Data source: NCI60 dataset"
  ) +
  theme_minimal(base_size = 14) +  # Use a minimal theme with larger base font size
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Rotate x-axis labels
    axis.text.y = element_text(size = 12),  # Adjust y-axis label size
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),  # Center and bold the title
    plot.subtitle = element_text(size = 14, hjust = 0.5),  # Center the subtitle
    plot.caption = element_text(size = 10, hjust = 1, color = "gray50"),  # Add a caption
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    legend.position = "right",  # Move the legend to the right
    legend.title = element_text(size = 12),  # Adjust legend title size
    legend.text = element_text(size = 10)  # Adjust legend text size
  )

##########









