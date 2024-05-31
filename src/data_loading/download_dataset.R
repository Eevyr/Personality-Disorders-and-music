# Script to download (from distant APIs) or write datasets into data directory

library(httr)
library(readr)
library(utils)
library(archive)

#=============================================================================== 
# Downloads ----
#===============================================================================

#' Download and extract (multiple) datasets from a kaggle url
#'
#' @param auth the authentificator needed to have the right to access on kaggle
#' @param url the url of the kaggle dataset
#' @param final are we considering the inital dataset found on kaggle 
#' or the one reated by this project an uploaded to kaggle ?
#'
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


#=============================================================================== 
# Writings ----
#===============================================================================


#' Write a dataset in the data directory
#'
#' @param dataset the dataset we want to write in a csv file
#' @param folder the name of the folder we want to write it in 
#' (either "derived" or "raw")
#' @param file the name of the csv file we are writting in
#'

#' @examples
#' write_csv(spotify_dataset, "derived", "example.csv")
write_csv <-function(dataset, folder, file){
  write.csv(dataset, here::here("data", folder, file))
}


