# Script to make some first exploratory data analyses

source(here::here("analyses", "disorders_vs_music_popularity", "load_datasets.R"))

library("ggplot2")                     
library("GGally")
library("tidyverse")
library(ggnewscale)
library(tidyverse)
library(ggplot2)
library(RColorBrewer)
library(corrplot)
library(colorspace)

# load dataset
datasets <- load_disorder_musics()

control_dataset = datasets$"anon_control_musics"
disorder_dataset = datasets$"anon_disorder_musics"

# Path to save the plots
file_path <- here::here("outputs", "disorders_vs_music_popularity")


# Setting color palettes
lajoli_palette <- brewer.pal(n = 10, name = "Set3")

# Define gradient colors for the control dataset
control_palette <- colorRampPalette(c("darkturquoise", "black"))(7)

# Define gradient colors for the disorder dataset
disorder_palette <- colorRampPalette(c("orange", "black"))(7) 


# Count the number of different disorders and their frequencies
disorder_counts <- disorder_dataset %>%
  count(disorder) %>%
  arrange(desc(n))

# 1. Plot the counts of mentionned disorders
countplot <- ggplot(disorder_counts, aes(x = reorder(disorder, n), y = n, fill = disorder)) +
  geom_bar(stat = "identity", size = 1.1, aes(color = "border")) + 
  geom_bar(stat = "identity", show.legend = FALSE) +
  coord_flip() +
  scale_fill_manual(values = lajoli_palette) +
  scale_color_manual(values = "black", guide = FALSE) + 
  labs(title = "Counts of Mentioned Disorders",
       x = "Disorder",
       y = "Counts") +
  theme_minimal()

ggsave(filename = here::here(file_path,"bar_plot_count.png") , plot = countplot, device = "png")


# 2. Plot the mentions of the top 7 artists for control dataset AND disorder dataset

# Count the number of different artists and their frequencies
artist_frequencies <- disorder_dataset %>%
  count(artist) %>%
  mutate(frequency = n / sum(n)) %>%
  arrange(desc(frequency))

# Filter to get only the top 7 artists
top_n <- 7
top_artists_disorder <- artist_frequencies %>%
  top_n(top_n, frequency)


# Count the number of different artists and their frequencies
artist_frequencies <- control_dataset %>%
  count(artist) %>%
  mutate(frequency = n / sum(n)) %>%
  arrange(desc(frequency))

# Filter to get only the top 7 artists
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
  
  # Adding aesthetics
  coord_flip() +
  # Remove intermediate colors from legend
  labs(title = "Top 7 Artists by Number of Mentions in Tweets (Control vs Disorder)",
       x = "Popularity Proportion",
       y = "Artist") +
  theme_minimal() +
  theme(axis.text.x = element_blank()) 

ggsave(filename = here::here(file_path,"podium_plot.png") , plot = podium_plot, device = "png")




# 3. Pairs plot to see the influence of each disorders and their correlations

# Count the number of different artists and their frequencies
artist_counts <- disorder_dataset %>%
  count(artist) %>%
  arrange(desc(n))


# Spread the data so each disorder becomes a column
disorder_data <- disorder_dataset %>%
  count(artist, disorder) %>%
  spread(key = disorder, value = n, fill = 0)

# Calculate proportions
disorder_data <- disorder_data %>%
  mutate_at(vars(-artist), ~./sum(.))

# Define popularity levels
popularity_levels <- c("Very Popular", "Popular","Other")

# Create a new column for popularity level
artist_counts <- artist_counts %>%
  arrange(desc(n)) %>%
  mutate(popularity_level = cut(row_number(), 
                                breaks = c(0, 3, 9, Inf), 
                                labels = popularity_levels,
                                include.lowest = TRUE))

merged_data <- merge(disorder_data, artist_counts, by = "artist", all.x = TRUE)

disorder_data$popularity <- merged_data$popularity_level

colours <- adjust_transparency(c("#FDB462", "#FB8072","#80B1D3"), alpha = 0.8)


pairsplot <- ggpairs(disorder_data, columns = 2:ncol(disorder_data), aes(color = popularity)) +
  theme_minimal() + 
  scale_color_manual(values = colours) +
  scale_fill_manual(values = colours) +
  theme(axis.text = element_text(size = 7)) 

ggsave(filename = here::here(file_path,"pairs_plot.png") , plot = pairsplot, device = "png")


##Positive Correlation: If the points tend to rise together, it indicates that higher counts of one disorder tend to be associated with higher counts of another disorder.
##Negative Correlation: If the points tend to fall together, it indicates that higher counts of one disorder tend to be associated with lower counts of another disorder.


# 4. Bar Plot of Disorder Counts by Artist

data_long <- pivot_longer(disorder_data, cols = -artist, names_to = "disorder", values_to = "count")

barplot <- ggplot(data_long, aes(x = reorder(artist, -count), y = count, fill = disorder)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = lajoli_palette) +
  labs(title = "Disorder Counts by Artist",
       x = "Artist",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(filename = here::here(file_path,"bar_plot.png") , plot = barplot, device = "png")


# 5. Plot top 7 artists for each disorder in percentage

# Count the occurrences of each artist for each disorder
artist_counts <- disoder_dataset %>%
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
artistsperdisorder <- ggplot(top_artists, aes(x = reorder(artist, percentage), y = percentage, fill = percentage)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "darkturquoise", high = "#1D0B14") + 
  facet_wrap(~ disorder, scales = "free") +
  labs(title = "Top 7 Artists for Each Disorder (Percentage)",
       x = "Artist",
       y = "Percentage",
       fill = "Artist") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")+
  ylim(0, 50)

ggsave(filename = here::here(file_path,"7_artists_per_disorder_plot.png") , plot = artistsperdisorder, device = "png")


# 6. Violin Plot of Disorder Counts

violinplot <- ggplot(data_long, aes(x = disorder, y = count, fill = disorder)) +
  geom_violin() +
  labs(title = "Violin Plot of Disorder Counts",
       x = "Disorder",
       y = "Count") +
  theme_minimal() +
  scale_fill_manual(values = lajoli_palette) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(filename = here::here(file_path,"violin_plot.png") , plot = violinplot, device = "png")

