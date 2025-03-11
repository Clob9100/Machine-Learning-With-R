## Install the required Packages
# install.packages("readxl") # Package to read Excel file
# install.packages("ggplot2") # Package to create plots
# install.packages("RColorBrewer") # Package to create color palettes
# install.packages("GGally") ## Package to create pairs plots
# install.packages("dplyr")

## Download the required  Librairies
library(readxl)
library(ggplot2)
library(RColorBrewer)
library(GGally)

library(dplyr)
# ragg

## Replace by your file path where is located your Dataset
file_path <- "NCI60_dataset.xlsx"


## Read the Dataset
data <- read_excel(file_path)
head(data)

## Define the cancer types on which we will focus
selected_cancers <- c("NSCLC", "RENAL", "MELANOMA", "BREAST",
                      "COLON", "OVARIAN", "CNS", "PROSTATE")
selected_cancers

## Filter the dataset to include only the selected cancer types
filtered_data <- data[data$CancerType %in% selected_cancers, ]

## Count the number of samples per cancer type
cancer_counts <- as.data.frame(table(filtered_data$CancerType))
colnames(cancer_counts) <- c("CancerType", "Count")

## Sort cancer types by frequency (descending order)
cancer_counts <- cancer_counts[order(-cancer_counts$Count), ]

## Create a barplot using ggplot2
ggplot(cancer_counts, aes(x = reorder(CancerType, -Count), y = Count, fill = CancerType)) +
  geom_bar(stat = "identity") +  # Create barplot
  labs(title = "Distribution of Selected Cancer Types in NCI60 Dataset",
       x = "Cancer Types",
       y = "Number of Samples") +
  theme_minimal() +  # Use a minimal theme
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),  # Center and style the title
        axis.title = element_text(size = 12),  # Adjust axis title size
        axis.text = element_text(size = 10)) +  # Adjust axis text size
  scale_fill_brewer(palette = "Set3")  # Use a color palette from RColorBrewer

## Create the pairs plot
xggpairs(pairs_data,
        columns = 2:ncol(pairs_data),  # Use all feature columns
        mapping = aes(color = CancerType),  # Color by cancer type
        diag = list(continuous = wrap("densityDiag", alpha = 0.7, fill = "gray70")),  # Use density plots for the diagonal
        lower = list(continuous = wrap("points", alpha = 0.7, size = 1.5)),  # Use scatterplots for the lower triangle
        upper = list(continuous = wrap("blank")),  # Remove correlation coefficients
        title = "Pairs Plot of Selected Cancer Types") +
  theme_minimal() +  # Use a minimal theme
  theme(
    plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),  # Center and style the title
    axis.text = element_text(size = 10),  # Adjust axis text size
    axis.title = element_text(size = 12),  # Adjust axis title size
    strip.text = element_text(size = 12, face = "bold"),  # Customize facet labels
    legend.position = "right",  # Move legend to the right
    legend.title = element_text(size = 12, face = "bold"),  # Customize legend title
    legend.text = element_text(size = 10)  # Customize legend text
  ) +
  scale_color_brewer(palette = "Set1") +  # Use a fancy color palette for CancerType
  guides(color = guide_legend(override.aes = list(size = 4, alpha = 1)))  # Customize the legend


