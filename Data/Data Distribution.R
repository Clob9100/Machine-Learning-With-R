install.packages("readxl") # Package to read Excel file
install.packages("ggplot2") # Package to create plots
install.packages("RColorBrewer") # Package to create color palettes

library(readxl)
library(ggplot2)
library(RColorBrewer)

## Replace by your file path
file_path <- "C:\\Users\\clob9\\Desktop\\NCI60_dataset.xlsx"

## Read the Data
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
