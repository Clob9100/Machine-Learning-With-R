# Install required packages
install.packages("openxlsx")
install.packages("umap")  # For UMAP projection
install.packages("ggplot2")

# Load libraries
library(openxlsx)
library(umap)
library(ggplot2)
library(dplyr)


## Replace by your file path
file_path <- "C:\\Users\\clob9\\Desktop\\NCI60_dataset.xlsx"
data <- read_excel(file_path)
head(data)

# Get the names of numeric columns
numeric_names <- colnames(data)[numeric_columns]

# Subset the dataframe using the names
data_numeric <- as.matrix(data[, numeric_names])

# Check for missing or non-numeric values
sum(is.na(data_numeric))  # Should be 0
sum(!is.numeric(data_numeric))  # Should be 0

# Perform UMAP projection
umap_result <- umap(data_numeric, n_components = 4)  # Reduce to 4 dimensions


# Create a data frame for visualization
umap_df <- data.frame(
  UMAP1 = umap_result$layout[, 2],  # First UMAP dimension
  UMAP2 = umap_result$layout[, 4],  # Second UMAP dimension
  CancerType = data$CancerType  # Add CancerType for coloring
)

# Fancy Plot using ggplot2
ggplot(umap_df, aes(x = UMAP1, y = UMAP2, fill = CancerType)) +
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
    title = "UMAP Projection of Cancer Types",
    x = "UMAP Dimension 2",
    y = "UMAP Dimension 4",
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

