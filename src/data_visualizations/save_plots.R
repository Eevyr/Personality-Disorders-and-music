# Script to save plots

save_plot <- function(plot_name, file_path, file_name, height = NA, width = NA) {
  # Ensure height and width are properly handled
  if (is.na(height) && is.na(width)) {
    ggsave(filename = here::here(file_path, file_name), plot = plot_name, device = "png")
  } else if (is.na(height)) {
    ggsave(filename = here::here(file_path, file_name), width = width, plot = plot_name, device = "png")
  } else if (is.na(width)) {
    ggsave(filename = here::here(file_path, file_name), height = height, plot = plot_name, device = "png")
  } else {
    ggsave(filename = here::here(file_path, file_name), height = height, width = width, plot = plot_name, device = "png")
  }
}

