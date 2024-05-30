library(httr)
library(readr)
library(utils)
library(archive)

load_kaggle_dataset_from_file <- function(final){
  datasets <- list() 
  
  directory <- here::here("data", ifelse(!final,"raw", "derived"))

  # List all files in the data/raw directory
  csv_files <- list.files(directory, pattern = "\\.csv$")

  for (csv_file in csv_files) {
    # Read the CSV file into a variable
    if (length(csv_file) > 0) {
      print(csv_file)
      dataset <- read_csv(here::here( directory, csv_file))
      # Add the dataset to the list with a name based on the file name
      dataset_name <- gsub(".csv$", "", basename(csv_file))
      datasets[[dataset_name]] <- dataset
    } else {
      warning("No CSV file found for", csv_file)
    }
  }
  
  return(datasets)
}

find_id_track <- function(artist,track_title, access_token){
  
  # Construct the search query
  query <- paste0("artist:", artist, " track:", track_title)

    # Make the request to Spotify API
  response <- GET(
    url = "https://api.spotify.com/v1/search",
    query = list(
      q = query,
      type = "track",
      limit = 1
    ),
    add_headers(
      Authorization = paste("Bearer", access_token)
    )
  )
  
  # Check if the request was successful
  if (status_code(response) == 200) {
    # Extract track ID from the response
    data <- content(response, "parsed")
    if (length(data$tracks$items) > 0) {
      track_id <- data$tracks$items[[1]]$id
    } else {
      return(NULL)
    }
  } else {
    cat("Error:", status_code(response))
    if(status_code(response) == 400){
      return(NULL)
    }
  }

  return(track_id)
}

load_spotify_tracks <- function(kaggle_dataset_chunk, access_token){
  
  #Apply the function to each row in the dataset
  track_ids <- apply(kaggle_dataset_chunk[, c("artist", "title")], 1, function(x) {
    Sys.sleep(0.05)
    find_id_track(x[1], x[2], access_token)
  })
  
  track_ids_str_list <- paste(track_ids, collapse = ",")
  track_features_list <- get_track_audio_features(track_ids_str_list)
  
  # Combine the features into a single data frame
  track_df <- cbind(track_features_list)
  kaggle_dataset_chunk$danceability <- track_df$danceability
  kaggle_dataset_chunk$energy <- track_df$energy
  kaggle_dataset_chunk$key <- track_df$key
  kaggle_dataset_chunk$loudness <- track_df$loudness
  kaggle_dataset_chunk$mode <- track_df$mode
  kaggle_dataset_chunk$speechiness <- track_df$speechiness
  kaggle_dataset_chunk$tempo <- track_df$tempo
  
  return(kaggle_dataset_chunk)
}

