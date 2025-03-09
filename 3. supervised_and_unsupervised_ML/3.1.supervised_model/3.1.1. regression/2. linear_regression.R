# Load necessary libraries
library(readxl)       # For reading Excel files
library(ggplot2)      # For creating visualizations
library(dplyr)        # For data manipulation
library(reshape2)     # For reshaping data (e.g., melt function)
library(RColorBrewer) # For color palettes in visualizations

# Load the dataset
file_path <- "C:\\Users\\clob9\\Desktop\\NCI60_dataset.xlsx"
df <- read_excel(file_path)
head(df)

# Focus on a subset of cancer types for classification
selected_cancers <- c("NSCLC", "RENAL", "MELANOMA", "BREAST", "COLON", "OVARIAN", "CNS", "PROSTATE")
df <- df[df$CancerType %in% selected_cancers, ]

# -----------------------------------
# Regression Analysis on the full dataset
# -----------------------------------

# Select only the predictor variables
features <- df[, c("G4701", "G4700")]  # Keep only G4701 and G4700

# Convert CancerType to a factor
df$CancerType <- as.factor(df$CancerType)

# Create a one-hot encoded matrix of CancerType
target <- model.matrix(~ CancerType - 1, data = df)

# Train the multinomial logistic regression model
model <- lm(target ~ G4701 + G4700, data = df)
coef(model)

# Predict probabilities for all cancer types
predicted_probabilities <- predict(model, newdata = df, type = "probs")

# Combine actual CancerType with predicted probabilities
df_results <- cbind(df$CancerType, predicted_probabilities)
colnames(df_results)[1] <- "Actual_CancerType"

# Print the first few rows
head(df_results)

# Convert the predicted probabilities into a data frame
df_pred <- data.frame(df$CancerType, predicted_probabilities)

# Rename the actual cancer type column
colnames(df_pred)[1] <- "Actual_CancerType"

# Reshape data for ggplot (long format)
df_long <- melt(df_pred, id.vars = "Actual_CancerType")

# Rename columns for better readability
colnames(df_long) <- c("Actual_CancerType", "Predicted_CancerType", "Probability")

# Print first few rows to check structure
head(df_long)

# -----------------------------------
# Visualization: Heatmap of Predicted Probabilities
# -----------------------------------

ggplot(df_long, aes(x = Predicted_CancerType, y = Actual_CancerType, fill = Probability)) +
  geom_tile(color = "white") +  # Add white borders between tiles
  scale_fill_gradient(low = "lightblue", high = "darkblue") +  # Gradient color
  labs(title = "Heatmap of Predicted Probabilities for Cancer Types",
       x = "Predicted Cancer Type",
       y = "Actual Cancer Type",
       fill = "Probability") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# -----------------------------------
# Visualization: Scatter Plot with Regression Line
# -----------------------------------

ggplot(df, aes(x = G4701, y = G4700)) +
  geom_point(color = "blue", alpha = 0.6, size = 5) +  # Scatter plot with transparency
  geom_smooth(method = "lm", color = "red", se = TRUE, linetype = "dashed") +  # Linear regression line
  labs(
    title = "Linear Regression Between G4701 and G4700",
    subtitle = "Regression line with confidence interval",
    x = "G4701 Expression",
    y = "G4700 Expression"
  ) +
  theme_minimal(base_size = 14) +  # Clean minimal theme
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),  # Center and bold the title
    plot.subtitle = element_text(hjust = 0.5, size = 14),  # Center the subtitle
    axis.text.x = element_text(size = 12),  # Adjust x-axis text size
    axis.text.y = element_text(size = 12),  # Adjust y-axis text size
    panel.grid.major = element_line(color = "gray85"),  # Lighten major grid lines
    panel.grid.minor = element_blank()  # Remove minor grid lines
  )

# -----------------------------------
# Visualization: Scatter Plot with Regression Line colored by Cancer type
# -----------------------------------
ggplot(df, aes(x = G4701, y = G4700, color = CancerType)) +
  geom_point(alpha = 0.8, size = 5) +  # Scatter points with transparency
  geom_smooth(method = "lm", color = "black", se = TRUE, linetype = "dashed") +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Relationship Between G4701 and G4700",
    subtitle = "Colored by Cancer Type with Regression Line",
    x = "G4701 Expression",
    y = "G4700 Expression",
    color = "Cancer Type",
    caption = "Data source: NCI60 dataset"
  ) +
  theme_minimal(base_size = 14) +  # Clean and modern theme
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 14),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    panel.grid.major = element_line(color = "gray85"),
    panel.grid.minor = element_blank()
  )


# -----------------------------------
# Regression Analysis spliting into training and testing sets
# -----------------------------------
selected_cancers <- c("NSCLC", "RENAL", "MELANOMA", "BREAST", "COLON", "OVARIAN", "CNS", "PROSTATE")
df <- df[df$CancerType %in% selected_cancers, ]

# Convert CancerType to a factor
df$CancerType <- as.factor(df$CancerType)

# Split the dataset into training and testing sets (80% training, 20% testing)
set.seed(123)  # For reproducibility

# Create a training set with 80% of each cancer type
train_data <- df %>%
  group_by(CancerType) %>%
  sample_frac(0.8) %>%
  ungroup()

# Create a testing set with the remaining 20% of each cancer type
test_data <- df %>%
  anti_join(train_data, by = "CelLines")  # Assuming "CellLine" is a unique identifier

# Check if all cancer types are present in the testing set
print("Cancer types in testing set:")
print(unique(test_data$CancerType))

# Select only the predictor variables (G4701 and G4700)
train_features <- train_data[, c("G4701", "G4700")]
test_features <- test_data[, c("G4701", "G4700")]

# Create a one-hot encoded matrix of CancerType for training and testing
train_target <- model.matrix(~ CancerType - 1, data = train_data)
test_target <- model.matrix(~ CancerType - 1, data = test_data)

# Train the multinomial logistic regression model on the training set
model <- lm(train_target ~ G4701 + G4700, data = train_data)
coef(model)

# Predict probabilities for all cancer types on the testing set
predicted_probabilities <- predict(model, newdata = test_data, type = "probs")

# Combine actual CancerType with predicted probabilities
df_results <- cbind(test_data$CancerType, predicted_probabilities)
colnames(df_results)[1] <- "Actual_CancerType"

# Print the first few rows
head(df_results)

# Convert the predicted probabilities into a data frame
df_pred <- data.frame(test_data$CancerType, predicted_probabilities)

# Rename the actual cancer type column
colnames(df_pred)[1] <- "Actual_CancerType"

# Reshape data for ggplot (long format)
df_long <- melt(df_pred, id.vars = "Actual_CancerType")

# Rename columns for better readability
colnames(df_long) <- c("Actual_CancerType", "Predicted_CancerType", "Probability")

# Print first few rows to check structure
head(df_long)


# -----------------------------------
# Visualization: Heatmap of Predicted Probabilities (Testing Set)
# -----------------------------------
ggplot(df_long, aes(x = Predicted_CancerType, y = Actual_CancerType, fill = Probability)) +
  geom_tile(color = "white") +  # Add white borders between tiles
  scale_fill_gradient(low = "lightblue", high = "darkblue") +  # Gradient color
  labs(title = "Heatmap of Predicted Probabilities for Cancer Types (Testing Set)",
       x = "Predicted Cancer Type",
       y = "Actual Cancer Type",
       fill = "Probability") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# -----------------------------------
# Visualization: Scatter Plot with Regression Line (G4701 vs. G4700) on the testing set
# -----------------------------------
ggplot(test_data, aes(x = G4701, y = G4700)) +
  geom_point(color = "blue", alpha = 0.6, size = 5) +
  geom_smooth(method = "lm", color = "red", se = TRUE, linetype = "dashed") +
  labs(
    title = "Linear Regression Between G4701 and G4700 (Testing Set)",
    subtitle = "Regression line with confidence interval",
    x = "G4701 Expression",
    y = "G4700 Expression"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 14),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_line(color = "gray85"),
    panel.grid.minor = element_blank()
  )

# -----------------------------------
# Visualization: Scatter plot with regression line (colored by CancerType) on the testing set
# -----------------------------------
ggplot(test_data, aes(x = G4701, y = G4700, color = CancerType)) +
  geom_point(alpha = 0.8, size = 5) +
  geom_smooth(method = "lm", color = "black", se = TRUE, linetype = "dashed") +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Relationship Between G4701 and G4700 (Testing Set)",
    subtitle = "Colored by Cancer Type with Regression Line",
    x = "G4701 Expression",
    y = "G4700 Expression",
    color = "Cancer Type",
    caption = "Data source: NCI60 dataset"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 14),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    panel.grid.major = element_line(color = "gray85"),
    panel.grid.minor = element_blank()
  )