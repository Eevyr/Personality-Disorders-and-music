# Script to create the "final" dataset thanks to Spotify API

source(here::here("src", "data_loading", "load_datasets.R"))
library(jsonlite)
library(tidyr)  


#=============================================================================== 
# Create dataset disorder VS music features ----
#===============================================================================

#-------------------------------------------------------------------------------
## Load disorder and control kaggle dataset if not yet loaded ---- 
#-------------------------------------------------------------------------------

if (!exists("spotify_dataset")) {
  
  url <- "https://www.kaggle.com/api/v1/datasets/download/rrmartin/twitter-mental-disorder-tweets-and-musics?datasetVersionNumber=1"
  kaggle_datasets <- load_kaggle_dataset(url)
  
  control_dataset = kaggle_datasets$"anon_control_musics"
  disorder_dataset = kaggle_datasets$"anon_disorder_musics"
  
  combined_dataset <- rbind(disorder_dataset, control_dataset)
  
  #-------------------------------------------------------------------------------
  ## Create chunks of 100 data points of this weighted dataset ---- 
  #-------------------------------------------------------------------------------
  
  # Create the list of chunks of 100 data points
  num_chunks <- ceiling(nrow(combined_dataset) / 100)
  chunks_list <- list()
  
  for (i in 1:num_chunks) {
    start <- (i - 1) * 100 + 1
    end <- min(i * 100, nrow(combined_dataset))
    chunks_list[[i]] <- combined_dataset[start:end, , drop = FALSE]
  }
  # Initialise final dataset
  spotify_dataset <- data.frame()
  
} else {
  
  print("spotify_dataset already exists in the environment, continuing loading into the existing dataset.")
}

#-------------------------------------------------------------------------------
## Load dataset using spotify API ---- 
#-------------------------------------------------------------------------------

# Load dataset with Spotify API
spotify_dataset <- load_spotify_playlist(spotify_dataset, chunks_list)
  
# Write the dataset to a CSV file
write_csv(spotify_dataset, "derived","combined_features_disorder_with_NA.csv")

#-------------------------------------------------------------------------------
## Dataset wrangling ---- 
#-------------------------------------------------------------------------------

# Define the columns representing music features
music_features <- c("danceability", "energy", "key", "loudness", "mode", "speechiness", "tempo")

# Create a condition to check if all music features are NA
all_na_condition <- rowSums(is.na(spotify_dataset[music_features])) == length(music_features)

# Filter the dataset into two separate datasets
dataset_all_na <- spotify_dataset %>% filter(all_na_condition)
dataset_with_features <- spotify_dataset %>% filter(!all_na_condition)

# Write the cleaned dataset to a CSV file
write_csv(dataset_all_na, "derived","combined_features_disorder_only_NA.csv")
write_csv(dataset_with_features, "derived","combined_features_disorder.csv")


#=============================================================================== 
# Create dataset disorder VS artists genres ----
#===============================================================================

#-------------------------------------------------------------------------------
## Create weighted dataset of counts of disorder users per artists mentioned ---- 
#-------------------------------------------------------------------------------

if (!exists("weighted_disorder_data")) {
  
  num_mentions <- nrow(combined_dataset)
  
  # Calculate proportions of each disorder
  disorder_proportions <- combined_dataset %>%
    group_by(disorder) %>%
    summarize(proportion = n() / num_mentions)
  
  
  # Merge proportions with the disorder data
  weighted_disorder_dataset <- combined_dataset %>%
    inner_join(disorder_proportions, by = "disorder") %>%
    mutate(weight = 1 / proportion)
  
  # Spread the data so each disorder becomes a column
  weighted_disorder_data <- weighted_disorder_dataset %>%
    count(artist, disorder, wt = weight) %>%
    spread(key = disorder, value = n, fill = 0)
  
  #-------------------------------------------------------------------------------
  ## Create chunks of 100 data points of this weighted dataset ---- 
  #-------------------------------------------------------------------------------
  
  # Create the list of chunks of 100 data points
  num_chunks <- ceiling(nrow(weighted_disorder_data) / 100)
  chunks_list <- list()
  
  for (i in 1:num_chunks) {
    start <- (i - 1) * 100 + 1
    end <- min(i * 100, nrow(weighted_disorder_data))
    chunks_list[[i]] <- weighted_disorder_data[start:end, , drop = FALSE]
  }
  
  # Initialise final dataset
  genre_dataset <- data.frame()
} else {
  
  print("weighted_disorder_data already exists in the environment, continuing loading into the existing dataset.")
}

#-------------------------------------------------------------------------------
## Load dataset using spotify API ---- 
#-------------------------------------------------------------------------------

genre_dataset <- load_spotify_playlist(genre_dataset, chunks_list, genre = TRUE)

write_csv(genre_dataset, "derived","combined_genres_disorder.csv")