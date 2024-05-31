# Script for the second exploratory data analyses

source(here::here("src", "data_loading", "load_datasets.R"))
source(here::here("src", "data_visualizations", "save_plots.R"))
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

#=============================================================================== 
# Load the dataset needed and useful variables ----
#===============================================================================

# load dataset
url_final <- "https://www.kaggle.com/api/v1/datasets/download/chlobon/mental-disorders-and-music-features?datasetVersionNumber=1"
music_features_df <- load_kaggle_dataset(url_final, TRUE)$combined_features_disorder

# keep only necessary features
music_features_df <- music_features_df %>%
  select(artist, lyric, title, user_id, disorder, danceability, energy, key, loudness, mode, speechiness, tempo)

# Setting color palettes
lajoli_palette <- brewer.pal(n = 10, name = "Set3")

lajoli_palette_transparent <- colorspace::adjust_transparency(
  col = lajoli_palette,
  alpha = 0.6)

# Path to save the plots
file_path <- here::here("outputs", "disorders_vs_music_features")


#=============================================================================== 
# Correlation plot of music features ----
#===============================================================================


# Correlation heatmap
numerical_vars <- music_features_df %>%
  select(danceability, energy, loudness, speechiness, tempo)

cor_matrix <- cor(numerical_vars, use = "complete.obs")

# Redefine gradient colors
my_colors <- colorRampPalette(c("black", lajoli_palette[1]))(100)

coorplot <- corrplot(cor_matrix, method = "color", type = "upper", tl.col = "black", tl.srt = 45, col = my_colors)



#=============================================================================== 
# Global pairs-plots ----
#===============================================================================


# define variables for the two distinct pairs-plot
music_numerical_df <- music_features_df %>%
  select(danceability, energy, loudness, speechiness, tempo, disorder)

anxiety_column_names = c("anxiety", "bipolar", "borderline", "control")
bipolar_column_names = c("control", "depression", "panic", "ptsd")

# Select columns for the two distinct datasets
music_numerical_df_anxiety <- music_numerical_df %>%
  filter(disorder %in% anxiety_column_names)
music_numerical_df_bipolar <- music_numerical_df %>%
  filter(disorder %in% bipolar_column_names )

# Define color mapping
color_mapping_anxiety <- setNames(c(lajoli_palette_transparent[1:4]),anxiety_column_names)
color_mapping_bipolar <- setNames(c(lajoli_palette_transparent[4:7]),bipolar_column_names)

# Pairs-plots 
pairs_plot1 <- ggpairs(music_numerical_df_bipolar, mapping = aes(col = disorder)) +
  scale_colour_manual(values = color_mapping_bipolar) +
  scale_fill_manual(values = color_mapping_bipolar) +
  theme_minimal() + 
  theme(axis.text = element_text(size = 6))

pairs_plot2 <- ggpairs(music_numerical_df_anxiety, mapping = aes(col = disorder)) +
  scale_colour_manual(values = color_mapping_anxiety) +
  scale_fill_manual(values = color_mapping_anxiety) +
  theme_minimal() + 
  theme(axis.text = element_text(size = 6))

save_plot(pairs_plot1, file_path, "pairs_plot1.png", height = 10, width = 12)
save_plot(pairs_plot2, file_path, "pairs_plot2.png", height = 10, width = 12)

#=============================================================================== 
# Refined plots ----
#===============================================================================

#-------------------------------------------------------------------------------
## Energy plots ---- 
#-------------------------------------------------------------------------------

# Density plot for energy
energy_density <- ggplot(music_features_df, aes(x = energy, fill = disorder)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Density Plot of energy", x = "energy", y = "Density")

save_plot(energy_density, file_path, "energy_density.png")

# Violinplot of energy by disorder
energy_violinplot <- ggplot(music_features_df, aes(x = disorder, y = energy, fill = disorder)) +
  geom_violin() +
  theme_minimal() +
  scale_fill_manual(values = lajoli_palette) +
  labs(title = "Boxplot of energy by Disorder", x = "Disorder", y = "energy")

save_plot(energy_violinplot, file_path, "energy_violinplot.png")

#-------------------------------------------------------------------------------
## Tempo and danceability plots ---- 
#-------------------------------------------------------------------------------

# Density plot for tempo
tempo_density <- ggplot(music_features_df, aes(x = tempo, fill = disorder)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Density Plot of tempo", x = "tempo", y = "Density")

save_plot(tempo_density, file_path, "tempo_density.png")

# Boxplot of danceability by disorder
danceability_boxplot <- ggplot(music_features_df, aes(x = disorder, y = danceability, fill = disorder)) +
  geom_violin() +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Boxplot of Danceability by Disorder", x = "Disorder", y = "Danceability")

save_plot(danceability_boxplot, file_path, "danceability_boxplot.png")

#-------------------------------------------------------------------------------
## Key plot ---- 
#-------------------------------------------------------------------------------

# Boxplot of key by disorder
key_boxplot <- ggplot(music_features_df, aes(x = disorder, y = key, fill = disorder)) +
  geom_boxplot() +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Boxplot of key by Disorder", x = "Disorder", y = "key")

save_plot(key_boxplot, file_path, "key_boxplot.png")

