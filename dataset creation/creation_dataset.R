source(here::here("analyses", "data_loading", "load_datasets.R"))

if (!exists("spotify_dataset")) {
  kaggle_datasets <- load_kaggle_musics()
  
  control_dataset = kaggle_datasets$"anon_control_musics"
  disorder_dataset = kaggle_datasets$"anon_disorder_musics"
  
  combined_dataset <- rbind(disorder_dataset, control_dataset)
  
  num_chunks <- ceiling(nrow(combined_dataset) / 100)
  
  chunks_list <- list()
  
  # Loop through each chunk and create a dataframe
  for (i in 1:num_chunks) {
    start <- (i - 1) * 100 + 1
    end <- min(i * 100, nrow(combined_dataset))
    chunks_list[[i]] <- combined_dataset[start:end, , drop = FALSE]
  }
  
  spotify_dataset <- data.frame()
} else {
  
  print("spotify_dataset already exists in the environment, continuing loading into the existing dataset.")
}

load_spotify_playlist(spotify_dataset, chunks_list)
  
# Write the dataset to a CSV file
write.csv(spotify_dataset, here::here("data", "derived","combined_features_disorder_with_NA.csv"))

# Define the columns representing music features
music_features <- c("danceability", "energy", "key", "loudness", "mode", "speechiness", "tempo")

# Create a condition to check if all music features are NA
all_na_condition <- rowSums(is.na(spotify_dataset[music_features])) == length(music_features)

# Filter the dataset into two separate datasets
dataset_all_na <- spotify_dataset %>% filter(all_na_condition)
dataset_with_features <- spotify_dataset %>% filter(!all_na_condition)

# Check the first few rows of each dataset
head(dataset_all_na)
head(dataset_with_features)

# Write the dataset to a CSV file
write.csv(dataset_all_na, here::here("data", "derived","combined_features_disorder_only_NA.csv"))
write.csv(dataset_with_features, here::here("data", "derived","combined_features_disorder.csv"))

