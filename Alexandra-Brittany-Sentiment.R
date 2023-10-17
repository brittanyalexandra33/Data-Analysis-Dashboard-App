library(shiny)
library(dplyr)
library(tidyr)
library(DT)
library(readxl)
library(factoextra)
library(FactoMineR)
library(plotly)
library(shinythemes)


# UI

ui <- fluidPage(
  # Include the Slate theme
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.min.css")
  ),
  titlePanel(" "),
  sidebarLayout(
    sidebarPanel(
      h3("Data Upload & Settings"),
      fileInput("data_upload", "Upload your Excel or CSV file"),
      actionButton("submit_button", "Generate Summary"),
      numericInput("n_clusters", "Number of Clusters:", min = 2, value = 3)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Information",
                 div(
                   class = "info-container",
                   h2("Comprehensive Data Analysis Dashboard"),
                   p("This interactive dashboard provides a comprehensive analysis of your uploaded dataset, offering insights through a range of statistical metrics, cluster analysis, and principal component analysis."),
                   h3("Advantages of Exploring the Data"),
                   p("This dashboard could be advantageous for:"),
                   tags$ul(
                     tags$li("Identifying natural groupings within your data."),
                     tags$li("Reducing the dimensionality of your data for further analysis."),
                     tags$li("Quickly summarizing and visualizing key statistics of your dataset.")
                   ),
                   h3("Features of the Dashboard"),
                   tags$ul(
                     tags$li(HTML("<strong><span style='color:blue'>Summary Statistics</span></strong>: Get an immediate understanding of your dataset through calculated mean, median, min, and max values.")),
                     tags$li(HTML("<strong><span style='color:blue'>Cluster Analysis</span></strong>: Use k-means clustering to identify natural groupings within your dataset.")),
                     tags$li(HTML("<strong><span style='color:blue'>Principal Component Analysis</span></strong>: Reduce the dimensionality of your dataset while retaining most of the original variance.")),
                     tags$li(HTML("<strong><span style='color:blue'>Data Visualization</span></strong>: Interactive plots provide a graphical representation of your dataset's distribution and cluster groupings.")),
                     tags$li(HTML("<strong><span style='color:blue'>Correlation with Principal Components</span></strong>: Understand how each variable is associated with the principal components."))
                   )
                 )
        ),
        
        tabPanel("Summary",
                 verbatimTextOutput("upload_status"),
                 h3("Summary Statistics", align = "center"),
                 p("This table provides the summary statistics for each numerical column in the dataset."),
                 DTOutput("summary_table"),
                 tags$hr(),  # Horizontal line as a divider
                 div(class="card",
                     h3("Total Records", class="card-title"),
                     p(textOutput("total_records"), class="card-text")),
                 plotOutput("statisticPlot", height = "400"),
                 helpText("Note: In the boxplot, the color indicates the median value for each variable. Blue represents a lower median, and red represents a higher median.")),
        tabPanel("Cluster Analysis",
                 fluidRow(
                   column(12,
                          selectInput("selected_cluster", "Select Cluster:", choices = c("All", 1, 2, 3), selected = "All")
                   )
                 ),
                 plotOutput("clusterPlot"),
                 DTOutput("clusterTable")
        ),
        tabPanel("PCA Analysis",
                 plotlyOutput("biplot"),
                 DTOutput("corTable")),
        tabPanel("Guidelines",
                 h2("Data Upload Guidelines"),
                 p("Ensure your data meets the following requirements for optimal analysis:"),
                 tags$ul(
                   tags$li("Data should be in either Excel (.xlsx, .xls) or CSV (.csv) formats."),
                   tags$li("The first row must contain column headers."),
                   tags$li("Each subsequent row should represent a single record."),
                   tags$li("For k-means and PCA, the dataset should contain at least some numerical columns."),
                   tags$li("Data should not contain any constant/zero columns, as it will break PCA.")
                 )
        )
      )
    )
  )
)

# Server
server <- function(input, output) {
  
  uploaded_data <- reactive({
    req(input$data_upload)
    inFile <- input$data_upload
    if (tolower(tools::file_ext(inFile$name)) %in% c("xlsx", "xls")) {
      read_excel(inFile$datapath)
    } else if (tolower(tools::file_ext(inFile$name)) == "csv") {
      read.csv(inFile$datapath)
    }
  })
  
  observeEvent(input$submit_button, {
    data <- uploaded_data()
    
    if (!is.null(data)) {
      output$upload_status <- renderText({
        paste("Uploaded file:", input$data_upload$name)
      })
      
      numeric_cols <- data %>% select_if(is.numeric)
      
      summary_stats <- numeric_cols %>%
        summarise(across(everything(), list(Mean = ~mean(.), Median = ~median(.), Min = ~min(.), Max = ~max(.))))
      
      summary_stats <- summary_stats %>%
        pivot_longer(cols = everything(),
                     names_to = c(".value", "Stat"),
                     names_sep = "_")
      
      output$summary_table <- renderDT({
        datatable(summary_stats,
                  rownames = FALSE,
                  options = list(scrollX = TRUE, 
                                 class = 'table table-striped table-bordered'))
      })
      
      
      output$statisticPlot <- renderPlot({
        medians <- apply(numeric_cols, 2, median)
        color_scheme <- colorRampPalette(c("blue", "red"))(length(medians))
        sorted_colors <- color_scheme[order(medians)]
        boxplot(numeric_cols, main="Boxplot of Summary Statistics",
                xlab="Variables", ylab="Values", col=sorted_colors, 
                las=2,  # Rotate axis labels to vertical
                cex.axis=0.8,  # Font size for axis labels
                mar=c(12, 5, 4, 2) + 0.1)  # Increase bottom margin
      })
      
      # Perform k-means clustering
      set.seed(123)
      clusters <- kmeans(numeric_cols, centers=input$n_clusters)
      cluster_data <- data %>% mutate(Cluster = clusters$cluster)
      
      # Reactive expression to filter the data based on the selected cluster
      filtered_cluster_data <- reactive({
        if (input$selected_cluster == "All") {
          return(cluster_data)
        } else {
          return(cluster_data %>% filter(Cluster == as.numeric(input$selected_cluster)))
        }
      })
      
      # Update the cluster table based on the selected cluster
      output$clusterTable <- renderDT({
        datatable(dplyr::select(filtered_cluster_data(), Cluster, dplyr::everything()), 
                  rownames = FALSE,
                  options = list(scrollX = TRUE))
      })
      
      # Update the cluster plot based on the selected cluster
      output$clusterPlot <- renderPlot({
        # You can adjust this to your plotting function
        fviz_cluster(clusters, data = filtered_cluster_data() %>% select_if(is.numeric))
      })
      
      # PCA and biplot
      pca_result <- prcomp(numeric_cols, scale = TRUE)
      output$biplot <- renderPlotly({
        fviz_pca_biplot(pca_result, geom = "arrow", invisible = "ind")  # Modify this line
      })
      
      # Correlations with the first principal component
      cor_first_pc <- as.data.frame(pca_result$rotation[, 1])
      colnames(cor_first_pc) <- c("Correlation")
      cor_first_pc$Variable <- rownames(cor_first_pc)
      
      output$corTable <- renderDT({
        datatable(cor_first_pc, rownames = FALSE, options = list(scrollX = TRUE))
      })
    }
  })
}

# Run the app
shinyApp(ui, server)

