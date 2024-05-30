library(httr)
library(readr)
library(utils)
library(archive)
library(spotifyr)
library(dplyr)

api_authentification <-function(API_type){
  
  if(API_type == "Kaggle") {
    
    # Get Kaggle API credentials from environment variables
    username <- Sys.getenv("KAGGLE_USERNAME")
    key <- Sys.getenv("KAGGLE_KEY")
  }
  else {
    username <- Sys.getenv("SPOTIFY_CLIENT_ID")
    key <- Sys.getenv("SPOTIFY_CLIENT_SECRET")
  }
  
  if (username == "" || key == "") {
    warning("Spotify credentials are not set!")
  }
  
  if(API_type == "Kaggle") {
    # Set up the authentication
    auth <- authenticate(user = username, password = key)
  }
  else {
    auth <- spotifyr::get_spotify_access_token()
  }
  
  print("authentification API set up")
  
  return(auth)
}
