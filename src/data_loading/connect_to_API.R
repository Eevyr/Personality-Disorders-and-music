library(httr)
library(readr)
library(utils)
library(archive)

api_authentification <-function(){
  
  # Get Kaggle API credentials from environment variables
  kaggle_username <- Sys.getenv("KAGGLE_USERNAME")
  kaggle_key <- Sys.getenv("KAGGLE_KEY")
  
  # Set up the authentication
  auth <- authenticate(user = kaggle_username, password = kaggle_key)
  
  print("authentification API set up")
  
  return(auth)
}

