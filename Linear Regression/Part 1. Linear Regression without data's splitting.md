
# Cancer Type Classification Using LogitBoost

## Overview
This project focuses on classifying cancer types using gene expression data from the **NCI60 dataset**. The NCI60 dataset contains gene expression profiles for 60 cancer cell lines derived from 9 different cancer types. The goal is to build a classification model that can predict the cancer type based on gene expression data.

We use the **LogitBoost algorithm**, a boosting method for classification, to train the model. The project includes:
- Feature selection to reduce dimensionality.
- Model training and evaluation.
- Visualization of results, including feature importance, confusion matrix, and ROC curves.

---

## Dataset
The dataset contains:
- **Rows**: 60 cancer cell lines.
- **Columns**:
  - `CellLine`: Unique identifier for each cell line.
  - `CancerType`: The type of cancer (e.g., BREAST, CNS, COLON, etc.).
  - Gene expression data for thousands of genes.

The target variable is `CancerType`, and the features are the gene expression values.

---

## Methodology

### 1. Data Preprocessing
- **Removed the `CellLine` column**: This column is not needed for modeling.
- **Converted `CancerType` to a factor**: Required for classification tasks.
- **Separated features and target variable**:
  - Features: All columns except `CancerType`.
  - Target: `CancerType`.

### 2. Feature Selection
To reduce the dimensionality of the dataset, we selected the **top 50 features** (genes) based on their **variance**. Genes with higher variance are more likely to be informative for distinguishing between cancer types.

```R
# Calculate variance for each feature
feature_variance <- apply(Data, 2, var)

# Select the top 50 features with the highest variance
top_features <- order(feature_variance, decreasing = TRUE)[1:50]
Data_reduced <- Data[, top_features]
```

### 3. Model Training
We trained a **LogitBoost model** on the reduced dataset. LogitBoost is a boosting algorithm that combines weak classifiers to create a strong classifier.

```R
model <- LogitBoost(Data_reduced, Label)
```

### 4. Model Evaluation
Since we did not split the dataset into training and testing sets, we evaluated the model on the entire dataset. This approach has limitations (see **Limitations** below).

#### Metrics:
- **Accuracy**: The proportion of correctly classified samples.
- **Confusion Matrix**: A table showing the actual vs. predicted cancer types.
- **RMSE (Root Mean Squared Error)**: Measures the difference between predicted probabilities and actual binary indicators.
- **AUC (Area Under the Curve)**: Evaluates the model's ability to distinguish between classes.

---

## Results

### 1. Feature Importance
We calculated the importance of each feature based on its variance.


### 2. Confusion Matrix
The confusion matrix shows the model's performance in classifying each cancer type.


### 3. ROC Curve
The multiclass ROC curve visualizes the model's performance across all classes.


### 4. Metrics
- **Accuracy**: 100% (1.0)
- **RMSE**: 1.02e-07
- **AUC**: 1.0

---

## Limitations

### 1. Overfitting
Since we trained and tested the model on the **entire dataset**, the results are likely overfitted. Overfitting occurs when a model performs well on the training data but poorly on unseen data. To address this, the dataset should be split into **training** and **testing sets** (e.g., 80% training, 20% testing).

### 2. Feature Selection
We selected the top 50 features based on variance. While this reduces dimensionality, it may exclude some informative genes. Alternative feature selection methods (e.g., recursive feature elimination or correlation analysis) could be explored.

### 3. Model Interpretability
LogitBoost does not provide coefficients like linear models, making it harder to interpret the contribution of each feature. Feature importance was approximated using variance, but this is not as precise as coefficients.

---

## Metrics Explanation

### 1. Accuracy
Accuracy measures the proportion of correctly classified samples. In this case, the model achieved 100% accuracy, but this is likely due to overfitting.

### 2. RMSE (Root Mean Squared Error)
RMSE measures the difference between predicted probabilities and actual binary indicators. A lower RMSE indicates better performance. Here, the RMSE is very low (1.02e-07), but this is also a result of overfitting.

### 3. AUC (Area Under the Curve)
AUC measures the model's ability to distinguish between classes. An AUC of 1.0 indicates perfect classification, but this is unrealistic and likely due to overfitting.

---

## Future Work
- **Split the dataset**: Use a proper training/testing split to evaluate the model's performance on unseen data.
- **Explore other models**: Try alternative algorithms like Random Forest, SVM, or XGBoost.
- **Feature selection**: Experiment with other feature selection methods to identify the most informative genes.
- **Cross-validation**: Use k-fold cross-validation to obtain a more reliable estimate of model performance.

---

## How to Run the Code
1. Clone the repository.
2. Install the required R packages:
   ```R
   install.packages(c("readxl", "LogitBoost", "ggplot2", "pROC", "caret", "dplyr", "tidyr"))
   ```
3. Run the R script (`script.R`).

---

## Conclusion
This project demonstrates the use of LogitBoost for cancer type classification using gene expression data. While the model achieved perfect accuracy and AUC, these results are likely due to overfitting. Future work should focus on proper dataset splitting, alternative models, and robust evaluation techniques.