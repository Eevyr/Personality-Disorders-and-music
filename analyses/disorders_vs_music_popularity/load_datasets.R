# Script to load the datasets from distant APIs

source(here::here("analyses", "data_wrangling", ".Rprofile"))
source(here::here("src", "data_loading","download_dataset.R"))
source(here::here("src", "data_loading","load_dataset.R"))
source(here::here("src", "data_loading","connect_to_API.R"))

load_disorder_musics <- function(){
  auth <- api_authentification()
  download_dataset(auth)
  datasets <- load_dataset()
  
  return(datasets)
}
