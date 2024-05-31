# Script of useful functions to be able to load the datasets either for kaggle 
# or spotify

library(httr)
library(readr)
library(utils)
library(archive)

#=============================================================================== 
# Kaggle ----
#===============================================================================

#' Load a dataset from the downloaded csv file in data directory
#'
#' @param final are we considering the inital dataset found on kaggle 
#' or the one reated by this project an uploaded to kaggle ?
#'
#' @return the dataset variable
load_kaggle_dataset_from_file <- function(final){
  datasets <- list() 
  
  directory <- here::here("data", ifelse(!final,"raw", "derived"))

  # List all files in the specified directory
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

#=============================================================================== 
# Spotify ----
#===============================================================================

#-------------------------------------------------------------------------------
##  Get music features ---- 
#-------------------------------------------------------------------------------

#' Find the id of a song thanks to spotify API
#'
#' @param artist the name of the artist we are looking for
#' @param track_title the title of the song we are looking for
#' @param access_token to have access to spotify API
#'
#' @return the id of the track ( or NULL if not found )
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

#' Get the music features with spotify API thanks to track ids
#'
#' @param kaggle_dataset_chunk a chunk of the initial kaggle dataset that holds 
#' the necessary info to get the ids of each song and that needs to be completed
#' @param access_token to have access to spotify API
#'
#' @return the completed kaggle_dataset_chunk with music features
load_spotify_tracks <- function(kaggle_dataset_chunk, access_token){
  
  # Get track ids
  track_ids <- apply(kaggle_dataset_chunk[, c("artist", "title")], 1, function(x) {
    Sys.sleep(0.05)
    find_id_track(x[1], x[2], access_token)
  })
  track_ids_str_list <- paste(track_ids, collapse = ",")
  
  # Get track features based on track ids
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

#-------------------------------------------------------------------------------
##  Get artists genres ---- NOT USED YET
#-------------------------------------------------------------------------------

#' Find the artist's genre thanks to spotify API
#'
#' @param artist_name 
#' @param access_token 
#'
#' @return the genre of the artist
find_genres_artist <- function(artist_name, access_token){
  search_url <- paste0('https://api.spotify.com/v1/search?q=', URLencode(artist_name), '&type=artist')
  search_response <- GET(search_url, add_headers(Authorization = paste('Bearer', access_token)))
  
  if (status_code(search_response) == 200) {
    search_data <- fromJSON(content(search_response, as = "text", encoding = "UTF-8"))
    
    if (length(search_data$artists$items) > 0) {
      genres <- search_data$artists$items$genres[[1]]
      if (length(genres) == 0) {
        return(NULL)
      } else {
        return(paste(genres, collapse = ", "))
      }
    } else {
      return(NULL)
    }
  } else if (status_code(search_response) == 400){ 
    return(NULL)
  } else {
    cat("Error : ", status_code(search_response) )
    return("STOP")
  } 
}

#' Load the genres corresponding to the artists in kaggle_dataset_chunk
#'
#' @param kaggle_dataset_chunk the chunk of data that we need to get genres for
#' @param access_token 
#'
#' @return kaggle_dataset_chunk updated
load_spotify_genre <- function(kaggle_dataset_chunk, access_token){
  
  #Apply the function to each row in the dataset
  artist_genres <- apply(kaggle_dataset_chunk, 1, function(x) {
    find_genres_artist(x[1], access_token)
  })
  
  if ("STOP" %in% artist_genres) {
    return(data.frame())
  }
  
  artist_genres <- lapply(artist_genres, function(x) if (is.null(x)) NA else x)
  
  genres_df <- data.frame(genres = unlist(artist_genres), stringsAsFactors = FALSE)
  
  # Step 2: Create a new data frame with artists and their genres
  kaggle_dataset_chunk$genres = genres_df$genre
  
  return(kaggle_dataset_chunk)
}


