install.packages("readxl") # Package to read Excel file
install.packages("DT") # Package to opan an  interactive table

library(readxl)
library(DT)

## Replace by your file path
file_path <- "C:\\Users\\clob9\\Desktop\\NCI60_dataset.xlsx"

data <- read_excel(file_path)
head(data)