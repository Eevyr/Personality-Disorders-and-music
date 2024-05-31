# Script to load the datasets from distant APIs

source(here::here(".Rprofile"))
source(here::here("src", "data_loading","download_dataset.R"))
source(here::here("src", "data_loading","load_dataset_from_API.R"))
source(here::here("src", "data_loading","connect_to_API.R"))

#=============================================================================== 
# Loading Kaggle dataset ----
#===============================================================================

#' Load a dataset thanks to Kaggle API
#'
#' @param url the url to the desired dataset in kaggle
#' @param final are we considering the inital dataset found on kaggle 
#' or the one reated by this project an uploaded to kaggle ?
#'
#' @return kaggle dataset
load_kaggle_dataset <- function(url, final = FALSE){
  auth <- api_authentification("Kaggle")
  download_dataset(auth, url, final)
  kaggle_datasets <- load_kaggle_dataset_from_file(final)
  
  return(kaggle_datasets)
}

#=============================================================================== 
# Loading Spotify dataset ----
#===============================================================================

#' Load a dataset thanks to Spotify API
#'
#' @param dataset_to_be_updated the dataset we are creating and want to update 
#' (empty first time running the function) 
#' @param chunks_list list of chunks of 100 rows of the dataset containing the 
#' informations about artists and titles
#' @param genre if we are considering fetching genre of music instead of music 
#' features
#'
#' @return updated dataset
load_spotify_playlist <- function(dataset_to_be_updated, chunks_list, genre = FALSE) {
  
  # authentify
  access_token <- api_authentification("Spotify")
  
  # Loop through each chunk 
  chunk_number <- 1
  while (length(chunks_list) != 0) {
    
    chunk = chunks_list[[1]]
    
    # Fetch the necessary datas
    if(!genre)
      chunk_df <- load_spotify_tracks(chunk, access_token)
    else
      chunk_df <- load_spotify_genre(chunk, access_token)
    
    # If error in the process (api connection failed for example)
    if(ncol(dataset_to_be_updated) != 0 && ncol(chunk_df) != ncol(dataset_to_be_updated)){
      cat("chunk number ", chunk_number ," could not be loaded")
      return(dataset_to_be_updated)
    }
    
    dataset_to_be_updated <- rbind(dataset_to_be_updated, chunk_df)
    cat("chunk number ", chunk_number ," loaded into spotify dataset")
    
    # Update the list of data chunks already looked at
    chunks_list <- chunks_list[-1]
    chunk_number <- chunk_number+1
  }
  return(dataset_to_be_updated)
}
