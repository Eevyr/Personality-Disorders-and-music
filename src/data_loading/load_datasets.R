# Script to load the datasets from distant APIs

source(here::here(".Rprofile"))
source(here::here("src", "data_loading","download_dataset.R"))
source(here::here("src", "data_loading","load_dataset_from_API.R"))
source(here::here("src", "data_loading","connect_to_API.R"))

load_kaggle_dataset <- function(url, final = FALSE){
  auth <- api_authentification("Kaggle")
  download_dataset(auth, url, final)
  kaggle_datasets <- load_kaggle_dataset_from_file(final)
  
  return(kaggle_datasets)
}

load_spotify_playlist <- function(spotify_dataset, chunks_list) {
  
  access_token <- api_authentification("Spotify")
  
  chunk_number <- 1
  
  # Loop through each chunk 
  while (length(chunks_list) != 0) {
    
    chunk = chunks_list[[1]]
    
    chunk_df <- load_spotify_tracks(chunk, access_token)
    spotify_dataset <- rbind(spotify_dataset, chunk_df)
    
    cat("chunk number ", chunk_number ," loaded into spotify dataset")
    
    chunks_list <- chunks_list[-1]
    chunk_number <- chunk_number+1
  }
  return(spotify_dataset)
}
