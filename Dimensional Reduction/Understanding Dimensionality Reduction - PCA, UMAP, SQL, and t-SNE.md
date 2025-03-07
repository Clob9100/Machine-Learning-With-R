# Dimensionality Reduction Techniques Explained

This document provides an overview of four key dimensionality reduction techniques: SQL, PCA, UMAP, and t-SNE. Each method is explained in detail, along with its use cases, advantages, limitations, and references to relevant papers and resources. Figures are included to illustrate the results of each technique.

---

## 1. SQL (Statistical Quantile Learning)
- **Description**: SQL is a dimensionality reduction technique designed for large, nonlinear, and additive latent variable models. It uses statistical quantile learning to project high-dimensional data into a lower-dimensional space while preserving the underlying structure.
- **Use Cases**: High-dimensional data analysis, nonlinear dimensionality reduction, latent variable modeling.
- **Advantages**: Handles nonlinear relationships, scalable to large datasets, robust to noise.
- **Limitations**: Requires tuning of hyperparameters, computationally intensive for very large datasets.
- **Reference**: 
  - **Paper**: Bodelet, J., Blanc, G., Shan, J., Terrera, G.M., and Chén, O.Y., 2020. *Statistical Quantile Learning for Large, Nonlinear, and Additive Latent Variable Models*. arXiv preprint arXiv:2003.13119.
  - **GitHub**: [SQL GitHub Repository](https://github.com/jbodelet/SQL/tree/main/sql)

---

## 2. PCA (Principal Component Analysis)
- **Description**: PCA is a linear dimensionality reduction technique that transforms high-dimensional data into a lower-dimensional space while preserving the maximum variance.
- **Use Cases**: Data visualization, noise reduction, feature extraction.
- **Advantages**: Simple, interpretable, computationally efficient.
- **Limitations**: Assumes linear relationships, may not capture complex structures.

---

## 3. UMAP (Uniform Manifold Approximation and Projection)
- **Description**: UMAP is a non-linear dimensionality reduction technique that preserves both local and global structures in the data.
- **Use Cases**: Clustering, visualization, exploratory data analysis.
- **Advantages**: Captures complex structures, scalable, works well with high-dimensional data.
- **Limitations**: Requires tuning of hyperparameters (e.g., `n_neighbors`, `min_dist`).

---

## 4. t-SNE (t-Distributed Stochastic Neighbor Embedding)
- **Description**: t-SNE is a non-linear dimensionality reduction technique that focuses on preserving local structures in the data.
- **Use Cases**: Visualization of high-dimensional data, clustering.
- **Advantages**: Captures local relationships, effective for visualization.
- **Limitations**: Computationally expensive, sensitive to hyperparameters (e.g., `perplexity`).

---

## Conclusion
Each dimensionality reduction technique has its strengths and weaknesses, and the choice of method depends on the specific use case and dataset. SQL is ideal for nonlinear and additive latent variable models, PCA is suitable for linear data, while UMAP and t-SNE excel at capturing non-linear structures.

---

## References
1. Bodelet, J., Blanc, G., Shan, J., Terrera, G.M., and Chén, O.Y., 2020. *Statistical Quantile Learning for Large, Nonlinear, and Additive Latent Variable Models*. arXiv preprint arXiv:2003.13119.
2. [SQL GitHub Repository](https://github.com/jbodelet/SQL/tree/main/sql)