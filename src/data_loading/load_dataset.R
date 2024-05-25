library(httr)
library(readr)
library(utils)
library(archive)

load_dataset <- function(){
  datasets <- list() 
  
  # List all files in the data/raw directory
  csv_files <- list.files(here::here("data", "raw"), pattern = "\\.csv$")

  for (csv_file in csv_files) {
    # Read the CSV file into a variable
    if (length(csv_file) > 0) {
      print(csv_file)
      dataset <- read_csv(here::here("data", "raw", csv_file))
      # Add the dataset to the list with a name based on the file name
      dataset_name <- gsub(".csv$", "", basename(csv_file))
      datasets[[dataset_name]] <- dataset
    } else {
      warning("No CSV file found for", csv_file)
    }
  }
  
  return(datasets)
}

