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
  select(danceability, energy, loudness, speechiness, tempo, key)

cor_matrix <- cor(numerical_vars, use = "complete.obs")

# Redefine gradient colors
my_colors <- colorRampPalette(c("black", lajoli_palette[1]))(100)

png(filename = here::here(file_path, "corrplot.png"))  # Open a PNG device
corrplot(cor_matrix, method = "color", type = "upper", tl.col = "black", tl.srt = 45, col = my_colors)
dev.off()  # Close the PNG device


#=============================================================================== 
# Global pairs-plots ----
#===============================================================================


# define variables for the two distinct pairs-plot
music_numerical_df <- music_features_df %>%
  select(danceability, energy, loudness, speechiness, tempo, disorder)

column_names1 = c("anxiety", "bipolar", "borderline", "control")
column_names2 = c("control", "depression", "panic", "ptsd")

# Select columns for the two distinct datasets
music_numerical_df1 <- music_numerical_df %>%
  filter(disorder %in% column_names1)
music_numerical_df2 <- music_numerical_df %>%
  filter(disorder %in% column_names2 )

# Define color mapping
color_mapping1 <- setNames(c(lajoli_palette_transparent[1:4]),column_names1)
color_mapping2 <- setNames(c(lajoli_palette_transparent[4:7]),column_names2)

# Pairs-plots 
pairs_plot1 <- ggpairs(music_numerical_df1, mapping = aes(col = disorder)) +
  scale_colour_manual(values = color_mapping1) +
  scale_fill_manual(values = color_mapping1) +
  theme_minimal() + 
  theme(axis.text = element_text(size = 6))

pairs_plot2 <- ggpairs(music_numerical_df2, mapping = aes(col = disorder)) +
  scale_colour_manual(values = color_mapping2) +
  scale_fill_manual(values = color_mapping2) +
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
  labs(title = "Density Plot of Energy", x = "energy", y = "Density")

save_plot(energy_density, file_path, "energy_density.png")

# Violinplot of energy by disorder
energy_violinplot <- ggplot(music_features_df, aes(x = disorder, y = energy, fill = disorder)) +
  geom_violin() +
  theme_minimal() +
  scale_fill_manual(values = lajoli_palette) +
  labs(title = "Violin Plot of energy by Disorder", x = "Disorder", y = "energy")

save_plot(energy_violinplot, file_path, "energy_violinplot.png")

#-------------------------------------------------------------------------------
## Tempo and danceability plots ---- 
#-------------------------------------------------------------------------------

# Density plot for tempo
tempo_density <- ggplot(music_features_df, aes(x = tempo, fill = disorder)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Density Plot of Tempo", x = "tempo", y = "Density")

save_plot(tempo_density, file_path, "tempo_density.png")

# Violin plot of danceability by disorder
danceability_violinplot <- ggplot(music_features_df, aes(x = disorder, y = danceability, fill = disorder)) +
  geom_violin() +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Violin Plot of Danceability by Disorder", x = "Disorder", y = "Danceability")

save_plot(danceability_violinplot, file_path, "danceability_violinplot.png")

# Density plot for danceability, centered on borderline
danceability_density <- ggplot(music_numerical_df1, aes(x = danceability, fill = disorder)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Density Plot of Danceability", x = "Danceability", y = "Density")

save_plot(danceability_density, file_path, "danceability_density.png")

#-------------------------------------------------------------------------------
## Key plot ---- 
#-------------------------------------------------------------------------------

# Boxplot of key by disorder
key_boxplot <- ggplot(music_features_df, aes(x = disorder, y = key, fill = disorder)) +
  geom_boxplot() +
  scale_fill_manual(values = lajoli_palette) +
  theme_minimal() +
  labs(title = "Boxplot of Key by Disorder", x = "Disorder", y = "key")

save_plot(key_boxplot, file_path, "key_boxplot.png")

