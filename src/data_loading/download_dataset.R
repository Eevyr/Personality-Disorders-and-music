library(httr)
library(readr)
library(utils)
library(archive)

download_dataset <- function(auth){
  # Check if there are already files in the data/raw directory
  if (length(list.files(here::here("data", "raw"))) > 0) {
    print("Files already exist in data/raw directory. Skipping download.")
    return(NULL)
  }
  
  # Kaggle API URL for dataset file download
  url <- "https://www.kaggle.com/api/v1/datasets/download/rrmartin/twitter-mental-disorder-tweets-and-musics?datasetVersionNumber=1"
  
  # Download the dataset file to a temporary location
  temp_file <- tempfile(fileext = ".zip")
  response <- GET(url, auth, write_disk(temp_file, overwrite = TRUE))
  
  print("Dataset downloaded from kaggle into temporary location")
  
  if (status_code(response) == 200) {
    # List the files in the ZIP archive
    file_list <- unzip(temp_file, list = TRUE)

    # Extract all files from the ZIP archive to a temporary directory
    temp_dir <- tempdir()
    unzip(temp_file, exdir = temp_dir)
    
    # Identify and decompress .tar.xz files
    tar_files <- list.files(temp_dir, pattern = "musics\\.tar\\.xz$", full.names = TRUE)
    
    for (tar_file in tar_files) {
      # Extract the contents of each .tar.xz file to data raw directory 
      extracted_files <- archive_extract(tar_file, dir = here::here("data", "raw"))

    }
    
    # Clean up temporary file
    unlink(temp_file)
    
  } else {
    
    stop("Failed to download dataset. Status code: ", status_code(response))
  }
}

