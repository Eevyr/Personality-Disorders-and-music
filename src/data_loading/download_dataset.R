library(httr)
library(readr)
library(utils)
library(archive)

download_dataset <- function(auth, url, final){
  
  folder <- ifelse(!final, "raw", "derived")
  
  # Check if there are already files in the data/raw directory
  if (length(list.files(here::here("data", folder))) > 0) {
    cat("Files already exist in data/", folder, "directory. Skipping download.\n")
    return(NULL)
  }
  
  directory <- ifelse(!final, tempdir(), here::here("data", "derived"))
  
  # Download the dataset file to a temporary location
  temp_file <- tempfile(fileext = ".zip")
  response <- GET(url, auth, write_disk(temp_file, overwrite = TRUE))
  
  if (status_code(response) == 200) {
    print("Archive downloaded from kaggle")
    
    # Extract all files from the ZIP archive
    unzip(temp_file, exdir = directory)
    
    if(!final){
      # Identify and decompress .tar.xz files
      tar_files <- list.files(directory, pattern = "musics\\.tar\\.xz$", full.names = TRUE)
      
      for (tar_file in tar_files) {
        # Extract the contents of each .tar.xz file to data raw directory 
        extracted_files <- archive_extract(tar_file, dir = here::here("data", "raw"))
      }
    }
    
    print("Dataset extracted into data folder")
    
    # Clean up temporary file
    unlink(temp_file)
    
  } else {
      
    stop("Failed to download dataset. Status code: ", status_code(response))
  }
}


