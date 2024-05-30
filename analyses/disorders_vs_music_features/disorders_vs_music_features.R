source(here::here("src", "data_loading", "load_datasets.R"))

library("ggplot2")                     
library("GGally")
library("tidyverse")
library(ggnewscale)
library(tidyverse)
library(ggplot2)
library(RColorBrewer)
library(corrplot)
library(colorspace)
library(ggplot2)
library(dplyr)
library(corrplot)
library(lubridate)

url_final <- "https://www.kaggle.com/api/v1/datasets/download/chlobon/mental-disorders-and-music-features?datasetVersionNumber=1"
music_features_df <- load_kaggle_dataset(url_final, TRUE)$combined_features_disorder

music_features_df <- music_features_df %>%
  select(artist, lyric, title, user_id, disorder, danceability, energy, key, loudness, mode, speechiness, tempo)

# Setting color palettes
lajoli_palette <- brewer.pal(n = 10, name = "Set3")

lajoli_palette_transparent <- colorspace::adjust_transparency(
  col = lajoli_palette,
  alpha = 0.6)


# Path to save the plots
file_path <- here::here("outputs", "disorders_vs_music_features")

# Correlation heatmap
numerical_vars <- music_features_df %>%
  select(danceability, energy, loudness, speechiness, tempo)

cor_matrix <- cor(numerical_vars, use = "complete.obs")

my_colors <- colorRampPalette(c("black", lajoli_palette[1]))(100)

corrplot(cor_matrix, method = "color", type = "upper", tl.col = "black", tl.srt = 45, col = my_colors)


# Pairsplot
music_numerical_df <- music_features_df %>%
  select(danceability, energy, loudness, speechiness, tempo, disorder)

anxiety_column_names = c("anxiety", "bipolar", "borderline", "control")
bipolar_column_names = c("control", "depression", "panic", "ptsd")

music_numerical_df_anxiety <- music_numerical_df %>%
  filter(disorder %in% anxiety_column_names)

music_numerical_df_bipolar <- music_numerical_df %>%
  filter(disorder %in% bipolar_column_names )

# Define color mapping
color_mapping_anxiety <- setNames(c(lajoli_palette_transparent[1:4]),anxiety_column_names)

color_mapping_bipolar <- setNames(c(lajoli_palette_transparent[4:7]),bipolar_column_names)

pairs_plot2 <- ggpairs(music_numerical_df_anxiety, mapping = aes(col = disorder)) +
  scale_colour_manual(values = color_mapping_anxiety) +
  scale_fill_manual(values = color_mapping_anxiety) +
  theme_minimal() + 
  theme(axis.text = element_text(size = 6))

pairs_plot1 <- ggpairs(music_numerical_df_bipolar, mapping = aes(col = disorder)) +
  scale_colour_manual(values = color_mapping_bipolar) +
  scale_fill_manual(values = color_mapping_bipolar) +
  theme_minimal() + 
  theme(axis.text = element_text(size = 6))

ggsave(filename = here::here(file_path,"pairs_plot1.png") , height = 10, width = 12, plot = pairs_plot1, device = "png")
ggsave(filename = here::here(file_path,"pairs_plot2.png") , height = 10, width = 12, plot = pairs_plot2, device = "png")



# Density plot for energy
ggplot(music_features_df, aes(x = energy, fill = disorder)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Density Plot of energy", x = "energy", y = "Density")

# Density plot for tempo
ggplot(music_features_df, aes(x = tempo, fill = disorder)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Density Plot of tempo", x = "tempo", y = "Density")

# Boxplot of danceability by disorder
ggplot(music_features_df, aes(x = disorder, y = danceability, fill = disorder)) +
  geom_violin() +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Boxplot of Danceability by Disorder", x = "Disorder", y = "Danceability")

# Boxplot of key by disorder
ggplot(music_features_df, aes(x = disorder, y = key, fill = disorder)) +
  geom_boxplot() +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Boxplot of key by Disorder", x = "Disorder", y = "key")

# Violinplot of energy by disorder
ggplot(music_features_df, aes(x = disorder, y = energy, fill = disorder)) +
  geom_violin() +
  theme_minimal() +
  scale_fill_manual(values = lajoli_palette) +
  labs(title = "Boxplot of energy by Disorder", x = "Disorder", y = "energy")
