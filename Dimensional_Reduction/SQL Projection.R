## Install the Required Packages
install.packages("readxl")
install.packages("openxlsx")
devtools::install_github("jbodelet/SQL/sql") ## For SQL Projection

## Load the Required Libraries
library(readxl)
library(sql)
library(openxlsx)

## Replace by your file path
file_path <- "C:\\Users\\clob9\\Desktop\\NCI60_dataset.xlsx"
data <- read_excel(file_path)
head(data)

## Filter the dataset for selected cancer types
selected_cancers <- c("NSCLC", "RENAL", "MELANOMA", "BREAST", "COLON", "OVARIAN", "CNS", "PROSTATE")
filtered_data <- data[data$CancerType %in% selected_cancers, ]

## Exclude the CancerType column and convert to a numeric matrix
data_numeric <- as.matrix(filtered_data[, -ncol(filtered_data)])
storage.mode(data_numeric) <- "double"  # Ensure efficient storage as double precision

## Run SQL Projection on the filtered dataset
q <- 4  # Number of factors for projection / You can increase the number of factors for more detailed analysis
d <- 4  # Reduce rank for faster computation
sql_result <- SQL(data_numeric, q = q, d = d)

## Create a data frame for visualization
sql_df <- data.frame(
  Factor1 = sql_result$factor[, 2],
  Factor2 = sql_result$factor[, 4],
  CancerType = filtered_data$CancerType
)

## SQL Projection Plot using ggplot2
ggplot(sql_df, aes(x = Factor1, y = Factor2, fill = CancerType)) +  # Use fill for the color inside the points
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
    title = "SQL Projection of Cancer Types",
    x = "Factor 2",
    y = "Factor 4",
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