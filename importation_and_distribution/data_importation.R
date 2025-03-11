# install.packages("readxl") # Package to read Excel file
#  setwd('./Data Importation and Distribution/')
library(readxl)

## Replace by your file path
file_path <- "NCI60_dataset.xlsx"
data <- read_excel(file_path)

