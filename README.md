# Comprehensive Data Analysis Dashboard
Welcome to the Comprehensive Data Analysis Dashboard, a powerful tool designed to help you gain insights from your datasets, whether you are a data scientist, analyst, or business decision-maker. This dashboard offers a range of features, including summary statistics, cluster analysis, principal component analysis (PCA), and data visualisation. In this README, we'll guide you through using the dashboard step by step.


## Introduction
Imagine you have a dataset, and you want to understand it better, identify patterns, and extract meaningful information. This dashboard is here to assist you in achieving that goal.

## Getting Started
To use the Comprehensive Data Analysis Dashboard, follow these steps:


1. **Upload Your Data**: Start by clicking the "Upload your Excel or CSV file" button. This is where you'll provide the dataset you want to analyse. Ensure your data is in either Excel (.xlsx, .xls) or CSV (.csv) formats. Feel free to use the `Example_Business-Operations-2022` as a template dataset to navigate.


2. **Set the Number of Clusters (Optional)**: If you're interested in cluster analysis, you can specify the number of clusters you want the data to be divided into using the "Number of Clusters" input. If you're not sure, you can keep the default value.


3. **Generate Summary**: After uploading your data and optionally setting the number of clusters, click the "Generate Summary" button. The dashboard will then analyze your data and provide insights.


4. **Requirements**:  Ensure you have R and the required R packages installed. The project relies on packages such as Shiny, dplyr, tidyr, DT, readxl, factoextra, and FactoMineR.


5. **Explore Insights** : Explore the various tabs of the dashboard to access different types of analysis and visualisations, including cluster analysis and principal component analysis.


## Guidelines

Make sure your data meets these requirements for optimal analysis:

- Data should be in either Excel (.xlsx, .xls) or CSV (.csv) formats.
- The first row must contain column headers.
- Each subsequent row should represent a single record.
- For k-means and PCA, the dataset should contain at least some numerical columns.
- Data should not contain any constant or zero columns, as it will break PCA.

## Dashboard Features

### Summary Statistics
The dashboard provides you with summary statistics, including mean, median, minimum, and maximum values for each numerical variable in your dataset. This helps you quickly understand your data's central tendencies and variability.


### Box Plots
Box plots offer a visual representation of the data's distribution. They show the median, quartiles, and potential outliers for each variable in your dataset. Colour is used to indicate the median value, with blue representing a lower median and red representing a higher median.


### Cluster Analysis
If you specified the number of clusters, the dashboard will perform k-means clustering on your data. It will group similar data points into clusters, making it easier to identify patterns and trends within your dataset.


### PCA Analysis
Principal Component Analysis (PCA) is used to reduce the dimensionality of your dataset while retaining most of the original variance. The dashboard provides interactive plots that help you explore the relationships between variables and their contributions to principal components.

### Data Visualization
Interactive plots are available to provide graphical representations of your dataset's distribution and cluster groupings, making it easier to visualize the relationships between variables.

### Correlation with Principal Components
Understand how each variable is associated with the principal components. This feature helps you identify which variables contribute the most to the variance in your data.


## Conclusion

The Comprehensive Data Analysis Dashboard is a valuable tool for data exploration and analysis. It's designed to assist you in making data-driven decisions by providing insights into your datasets. Whether you're exploring survey data, business operations, or any other dataset, this dashboard is your ally in the world of data analysis.

I hope you find this tool useful, and  encourage you to explore your data and discover insights that can drive your projects and decisions forward.
