# Path to the kaggle.json file
kaggle_json_path <- "~/.kaggle/kaggle.json"

# Read the JSON file
if (file.exists(kaggle_json_path)) {
  kaggle_credentials <- jsonlite::fromJSON(kaggle_json_path)
  Sys.setenv(KAGGLE_USERNAME = kaggle_credentials$username)
  Sys.setenv(KAGGLE_KEY = kaggle_credentials$key)
} else {
  warning("kaggle.json file not found!")
}

