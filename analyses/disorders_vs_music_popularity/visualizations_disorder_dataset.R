# Script for the first exploratory data analyses

source(here::here("src", "data_loading", "load_datasets.R"))
source(here::here("src", "data_visualizations", "save_plots.R"))
library(ggnewscale)
library(tidyverse)
library(ggplot2)
library(RColorBrewer)
library(corrplot)
library(colorspace)
library(patchwork)

#=============================================================================== 
# Load the dataset needed and useful variables ----
#===============================================================================

# load dataset
url <- "https://www.kaggle.com/api/v1/datasets/download/rrmartin/twitter-mental-disorder-tweets-and-musics?datasetVersionNumber=1"
datasets <- load_kaggle_dataset(url)

control_dataset = datasets$"anon_control_musics"
disorder_dataset = datasets$"anon_disorder_musics"

combined_dataset <- rbind(disorder_dataset, control_dataset)

# Path to save the plots
file_path <- here::here("outputs", "disorders_vs_music_popularity")

# Setting color palette
lajoli_palette <- brewer.pal(n = 10, name = "Set3")

# Define gradient colors for the control dataset
control_palette <- colorRampPalette(c("#80B1D3", "black"))(7)

# Define gradient colors for the disorder dataset
disorder_palette <- colorRampPalette(c("#FDB462", "black"))(7) 


#=============================================================================== 
# Counting plots ----
#===============================================================================

#-------------------------------------------------------------------------------
##  Count unique users for each disorder ---- 
#-------------------------------------------------------------------------------

num_unique_users <- n_distinct(combined_dataset$user_id)

disorder_counts_unique_users <- combined_dataset %>%
  group_by(disorder) %>%
  summarize(unique_users = n_distinct(user_id))

# Calculate proportions of each disorder
disorder_unique_users_proportions <- combined_dataset %>%
  group_by(disorder) %>%
  summarize(proportion = n_distinct(user_id) / num_unique_users)

# Plot the number of unique users for each disorder
count_plot_unique_users <- ggplot(disorder_counts_unique_users, aes(x = reorder(disorder, -unique_users), y = unique_users, fill = disorder)) +
  geom_bar(stat = "identity", size = 0.5) +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Number of Unique Users for Each Disorder",
       x = "Disorder",
       y = "Number of Unique Users") +
  geom_text(data = disorder_unique_users_proportions, 
          aes(x = reorder(disorder, -proportion), 
              y = disorder_counts_unique_users$unique_users, 
              label = paste0(round(proportion * 100, 1), "%")), 
          vjust = -0.5 , size = 4)

save_plot(count_plot_unique_users, file_path, "bar_plot_count_unique.png")

#-------------------------------------------------------------------------------
##  Count number of mentions for each disorder ---- 
#-------------------------------------------------------------------------------

num_mentions <- nrow(combined_dataset)

disorder_counts <- combined_dataset %>%
  count(disorder)

# Calculate proportions of each disorder
disorder_proportions <- combined_dataset %>%
  group_by(disorder) %>%
  summarize(proportion = n() / num_mentions)

# Plot the number of mentions for each disorder
count_plot <- ggplot(disorder_counts, aes(x = reorder(disorder, -n), y = n, fill = disorder)) +
  geom_bar(stat = "identity", size = 0.5) +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Number of Mentions for Each Disorder",
       x = "Disorder",
       y = "Number of Mentions") +
  geom_text(data = disorder_proportions_combined, 
            aes(x = reorder(disorder, -proportion), 
                y = disorder_counts$n, 
                label = paste0(round(proportion * 100, 1), "%")), 
            vjust = -0.5 , size = 4)

save_plot(count_plot, file_path, "bar_plot_count.png")

#=============================================================================== 
# Top 7 artists popularity ----
#===============================================================================

#-------------------------------------------------------------------------------
##  Plot the mentions of top 7 artists for control and disorder dataset ---- 
#-------------------------------------------------------------------------------

top_n <- 7

# Filter to get only the top 7 artists for disorder dataset 
artist_frequencies <- disorder_dataset %>%
  count(artist) %>%
  mutate(frequency = n / sum(n)) %>%
  arrange(desc(frequency))

top_artists_disorder <- artist_frequencies %>%
  top_n(top_n, frequency)


# Filter to get only the top 7 artists for for control dataset
artist_frequencies <- control_dataset %>%
  count(artist) %>%
  mutate(frequency = n / sum(n)) %>%
  arrange(desc(frequency))

top_artists_control <- artist_frequencies %>%
  top_n(top_n, frequency)

# Add a column to determine the color and position of the text for disorder dataset
top_artists_disorder <- top_artists_disorder %>%
  mutate(text_color = ifelse(frequency > max(frequency) / 2, "white", "black"),
         hjust_value = ifelse(frequency > max(frequency) / 2, 1, -0.2))

# Add a column to determine the color and position of the text for control dataset
top_artists_control <- top_artists_control %>%
  mutate(text_color = ifelse(frequency > max(frequency) / 2, "white", "black"),
         hjust_value = ifelse(frequency > max(frequency) / 2, -0.2, 1))

# Create a podium plot combining both datasets
podium_plot <- ggplot() +
  
  # Disorder dataset podium
  geom_bar(data = top_artists_disorder, aes(x = frequency, y = reorder(artist, frequency), fill = interaction(factor(rank(-frequency)), "disorder")), 
           stat = "identity", color = "black", orientation = "y") +
  scale_fill_manual("Popularity amongst Disorder Dataset", values = disorder_palette, label = c("Most popular", "", "", "", "", "", "7th most popular")) +
  new_scale_fill() +
  
  # Control dataset podium
  geom_bar(data = top_artists_control, aes(x = -frequency, y = reorder(artist, -frequency), fill = interaction(factor(rank(-frequency)), "control")), 
           stat = "identity", color = "black", orientation = "y") +
  scale_fill_manual("Popularity amongst Control Dataset", values = control_palette, label = c("Most popular", "", "", "", "", "", "7th most popular")) +
  
  # Adding podium labels
  geom_text(data = top_artists_control[1, ], aes(x = -frequency/2, y = 1, label = "Control Dataset"),
            hjust = -0.2, color = "black", size = 5, vjust = -0.5) +
  
  geom_text(data = top_artists_disorder[1, ], aes(x = frequency, y = 13, label = "Disorder Dataset"),
            hjust = 1.2, color = "black", size = 5, vjust = 1.5) +
  
  # Adding artist names at the end of each bar
  geom_text(data = top_artists_disorder, aes(x = frequency, y = artist, label = artist),
            hjust = top_artists_disorder$hjust_value, 
            color = top_artists_disorder$text_color, 
            size = 3, vjust = 0.5, angle = 90) +
  
  geom_text(data = top_artists_control, aes(x = -frequency, y = artist, label = artist),
            hjust = top_artists_control$hjust_value, 
            color = top_artists_control$text_color, 
            size = 3, vjust = 0.5, angle = 90) +
  
  coord_flip() +
  labs(title = "Top 7 Artists by Number of Mentions in Tweets (Control vs Disorder)",
       x = "Popularity Proportion",
       y = "Artist") +
  theme_minimal() +
  theme(axis.text.x = element_blank()) 

save_plot(podium_plot, file_path, "podium_plot.png", width = 10)


#-------------------------------------------------------------------------------
##  Plot top 7 artists for each disorder in percentage ---- 
#-------------------------------------------------------------------------------

# Count the occurrences of each artist for each disorder
artist_counts <- disorder_dataset %>%
  count(disorder, artist) %>%
  arrange(disorder, desc(n))

# Filter to get the top 7 artists for each disorder
top_artists <- artist_counts %>%
  group_by(disorder) %>%
  top_n(7, n) %>%
  ungroup()

# Calculate total count for each disorder
top_artists <- top_artists %>%
  group_by(disorder) %>%
  mutate(total_count = sum(n))

# Calculate percentage for each artist
top_artists <- top_artists %>%
  mutate(percentage = (n / total_count) * 100)

# Plot top 7 artists for each disorder in percentage
artistsperdisorder <- list()

for (i in 1:6) {
  artistsperdisorder[[i]] <- ggplot(subset(top_artists, disorder == unique(top_artists$disorder)[i]), 
                                    aes(x = reorder(artist, percentage), y = percentage, fill = percentage)) +
    geom_bar(stat = "identity") +
    scale_fill_gradient(low = "black", high = lajoli_palette[i]) +
    labs(title = paste(unique(top_artists$disorder)[i], "top 7 artists"),
         x = "",
         y = "",
         fill = "Artist") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = "none") +
    ylim(0, 50)
}

# Facetting
artistsperdisorder <- wrap_plots(artistsperdisorder, nrow = 3)

save_plot(artistsperdisorder, file_path, "7_artists_per_disorder_plot.png", height = 10)


#=============================================================================== 
# Correlation between disorders ----
#===============================================================================

#-------------------------------------------------------------------------------
##  Pairs plot to see the influence between disorders ---- 
#-------------------------------------------------------------------------------

# Merge proportions with the disorder data
weighted_disorder_dataset <- combined_dataset %>%
  inner_join(disorder_proportions, by = "disorder") %>%
  mutate(weight = 1 / proportion)

# Spread the data so each disorder becomes a column
weighted_disorder_data <- weighted_disorder_dataset %>%
  count(artist, disorder, wt = weight) %>%
  spread(key = disorder, value = n, fill = 0)

# Define popularity levels
popularity_levels <- c("Very Popular", "Popular", "Other")

# Create a new column for popularity level
artist_counts <- artist_counts %>%
  arrange(desc(n)) %>%
  mutate(popularity_level = cut(row_number(), 
                                breaks = c(0, 3, 9, Inf), 
                                labels = popularity_levels,
                                include.lowest = TRUE))

# Merge popularity levels with the disorder data
merged_data <- merge(weighted_disorder_data, artist_counts, by = "artist", all.x = TRUE)

weighted_disorder_data$popularity <- merged_data$popularity_level

colours <- adjust_transparency(c("#FDB462", "#FB8072","#80B1D3"), alpha = 0.8)

# Plot pairs plot with weighted data
pairsplot <- ggpairs(weighted_disorder_data, 
                     columns = 2:(ncol(weighted_disorder_data) - 1), 
                     aes(color = popularity)) + 
  theme_minimal() + 
  scale_color_manual(values = colours) +
  scale_fill_manual(values = colours) +
  theme(axis.text = element_text(size = 7)) 

save_plot(pairsplot, file_path, "pairs_plot.png", width = 10)

#-------------------------------------------------------------------------------
##  Bar Plot of Disorder Counts by Artist (3 most famous) ---- 
#-------------------------------------------------------------------------------

top_n <- 3

# Filter to get only the top 7 artists for disorder dataset 
artist_frequencies <- combined_dataset %>%
  count(artist) %>%
  mutate(frequency = n / sum(n)) %>%
  arrange(desc(frequency))

top_artists_combined <- artist_frequencies %>%
  top_n(top_n, frequency)

top_artists <- top_artists_combined %>% pull(artist)


# Calculer la somme des valeurs pour chaque artiste
artist_totals <- weighted_disorder_data %>%
  mutate(total = rowSums(select(., -artist, -popularity)))

# Calculer les proportions
weighted_disorder_data_prop <- artist_totals %>%
  mutate(across(-c(artist, total), ~ . / total)) %>%
  select(-total)

filtered_weighted_disorder_data <- weighted_disorder_data_prop %>%
  filter(artist %in% top_artists)

data_long <- pivot_longer(filtered_weighted_disorder_data, cols = !c(artist, popularity), names_to = "disorder", values_to = "count")

barplot <- ggplot(data_long, aes(x = reorder(artist, -count), y = count, fill = disorder)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = lajoli_palette) +
  labs(title = "Disorder Weighted Percentages by Artist",
       x = "Artist",
       y = "Percentage") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

save_plot(barplot, file_path, "bar_plot.png")