# Install required packages
install.packages("openxlsx")
install.packages("ggplot2")

# Load libraries
library(openxlsx)
library(ggplot2)
library(dplyr)

# Define the file path
file_path <- "C:\\Users\\clob9\\Desktop\\NCI60_dataset.xlsx"

# Read the dataset
data <- read.xlsx(file_path)
head(data)

# Get the names of numeric columns
numeric_columns <- sapply(data, is.numeric)
numeric_names <- colnames(data)[numeric_columns]

# Subset the dataframe using the names
data_numeric <- as.matrix(data[, numeric_names])

# Check for missing or non-numeric values
sum(is.na(data_numeric))  # Should be 0
sum(!is.numeric(data_numeric))  # Should be 0

# Perform PCA
pca_result <- prcomp(data_numeric, scale. = TRUE)  # Scale the data for PCA

# Summary of PCA
summary(pca_result)

# Create a data frame for visualization
# Principal Component can be changed to any other component
pca_df <- data.frame(
  PC1 = pca_result$x[, 1],  # First principal component
  PC2 = pca_result$x[, 2],  # Second principal component
  CancerType = data$CancerType  # Add CancerType for coloring
)

# PCA Projection Plot using ggplot2
ggplot(pca_df, aes(x = PC1, y = PC2, fill = CancerType)) +
  geom_point(size = 6, alpha = 0.8, shape = 21, color = "black", stroke = 0.8) +  # Round marks with black border
  scale_fill_manual(values = c(
    "NSCLC" = "#1F77B4",  # Muted blue
    "RENAL" = "#FF7F0E",  # Safety orange
    "MELANOMA" = "#2CA02C",  # Cooked asparagus green
    "BREAST" = "#D62728",  # Brick red
    "COLON" = "#9467BD",  # Muted purple
    "OVARIAN" = "#8C564B",  # Chestnut brown
    "CNS" = "#E377C2",  # Raspberry yogurt pink
    "PROSTATE" = "#7F7F7F"  # Middle gray
  )) +  # Modern and visually appealing colors
  labs(
    title = "PCA of Cancer Types",
    x = "Principal Component 1 (PC2)",
    y = "Principal Component 2 (PC4)",
    fill = "Cancer Type"  # Update legend title to reflect fill
  ) +
  theme_minimal() +  # Use a minimal theme
  theme(
    plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),  # Center and style the title
    axis.title = element_text(size = 16),  # Adjust axis title size
    axis.text = element_text(size = 14),  # Adjust axis text size
    legend.title = element_text(size = 16, face = "bold"),  # Customize legend title
    legend.text = element_text(size = 14),  # Customize legend text
    legend.position = "right",  # Move legend to the right
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    panel.background = element_rect(fill = "white", color = "black")  # Add a border around the plot
  ) +
  guides(fill = guide_legend(override.aes = list(size = 6, alpha = 1)))  # Customize legend point size