# Personality-Disorders-and-music
Analyzing correlations between individuals with Mental Disorders (such as borderline, bipolar, depression, anxiety, panic, ptsd) and their music tastes, using a dataset extracted from Twitter and accessible on Kaggle, combined with music features extracted from Spotify.

Source of the Kaggle dataset : https://www.kaggle.com/datasets/rrmartin/twitter-mental-disorder-tweets-and-musics

To complete this dataset with useful information of each music and artist, I used the Spotify API and retrived the features of all the accessible musics present on the original Kaggle dataset.

Here are the three main objectives of this exploratory data analysis :

- Find the tendances and popularity of artists of each disorder group, leading to correlations between disorders

- Visualize the links between disorders and music taste in terms of genre of music

- Visualize the links between disorders and the tempo, danceability and other features of musics


WARNING : To be able to reproduce this analysis from scratch, the most time-consuming step will be to retreive the data from Spotify API, so the final combined dataset has been uploaded in Kaggle and it is this one that will be loaded into R at the start of the scripts (see section on data folder and dataset creation folder).

## Structure of this project

This project is organized as follows : 
  - The "analysis" folder contains the three main analysis steps (core of the project);
  - The "src" folder contains some useful functions used to load and analyse the datasets;
  - The "data" folder do not contains any data as they are too heavy to be pushed on git hub. You will need to set up API keys for Kaggle to retrieve it.
  - The "dataset creation" folder contains the scripts previously used to create the combined dataset used in this project.
  - The "output" folder contains plots resulting from the analysis;
  - The "reports" folder contains the final report explaining all the steps of the analysis.

### data

The data/raw folder is intentionally empty as the dataset needed is really heavy for github to support it. 

To re-create from scratch the dataset I used, you would need to download and/or load the first dataset available from Kagle and complete it by fetching the features of each song thanks to Spotify API. The script used for this - and explaining the steps of it - is in the folder "dataset creation" of the project.
A subset of this dataset is present in data/example folder.

But since downloading the necessary dataset using Spotify API for all the data points present in the Kaggle datasets is really long and cumbersome, I uploaded this newly constructed dataset into Kaggle. It is this one that is by default loaded into R at the start of the analysis, thanks to Kaggle API.

For this you therefore will need to set up Kaggle API credentials into .Rprofile at the source of your project. (see section on "How to run the project")

### dataset creation

This folder is made of the scripts used to create the dataset used in the analysis. 
There is no need to run this script at any point since I uploaded the final new dataset on Kaggle. 

### analysis

This folder is used to perform the three different EDAs described in the beginning of the README, one folder for each analysis.

Running the scripts in each of those three folder will create and download the plots useful (in the "outputs" folder) for the final report of this dataset.

### reports

This is the final output product of this project : an in-depth analysis of the different visualizations of this dataset and what can be inferred from it.

## How to run the project

### STEP 1 : Setting Up Kaggle Credentials

This guide will help you create a Kaggle account, obtain your API credentials, and configure your R environment to use these credentials by setting environment variables in the `.Rprofile` file.

1. **Create a Kaggle Account:**
   - Go to the [Kaggle website](https://www.kaggle.com/).
   - Sign up using your Google, Facebook, or LinkedIn account, or use an email address and password to create a new account.
   - If you signed up using an email address, check your inbox for a verification email from Kaggle and follow the instructions to verify your account.

2. **Obtain the Kaggle API Key:**
   - Log in to your Kaggle account.
   - Click on your profile picture in the top right corner and select "My Account" from the dropdown menu.
   - Scroll down to the "API" section.
   - Click on the "Create New API Token" button. This will download a file named `kaggle.json` to your computer. This file contains your Kaggle username and API key.

3. **Locate the `kaggle.json` File:**
   - The `kaggle.json` file should be in your default download directory. Open this file with a text editor to view its contents. It will look something like this:
     ```json
     {
       "username": "your_kaggle_username",
       "key": "your_kaggle_key"
     }
     ```

4. **Edit Your `.Rprofile` File:**
   - The `.Rprofile` file is used to customize the R environment and is executed each time R starts. You need to add the Kaggle credentials to this file.
   - If you don't have an `.Rprofile` file in your home directory or at the source of the project, you can create one.
   - Add the following lines to the `.Rprofile` text file, replacing `"your_kaggle_username"` and `"your_kaggle_key"` with the actual values from the `kaggle.json` file:
     ```r
     Sys.setenv(KAGGLE_USERNAME = "your_kaggle_username")
     Sys.setenv(KAGGLE_KEY = "your_kaggle_key")
     ```

   Alternatively, if you prefer to read these values directly from the `kaggle.json` file, you can add the following R code to your `.Rprofile`:
     ```r
     # Load the jsonlite package to read JSON files
     if (!requireNamespace("jsonlite", quietly = TRUE)) {
       install.packages("jsonlite")
     }

     # Read the Kaggle credentials from the JSON file
     kaggle_creds <- jsonlite::fromJSON("path/to/your/kaggle.json")

     # Set the environment variables
     Sys.setenv(KAGGLE_USERNAME = kaggle_creds$username)
     Sys.setenv(KAGGLE_KEY = kaggle_creds$key)
     ```
     
5. **Restart R:**
   - Close your current R session and start a new one to ensure that the changes to the `.Rprofile` file are loaded.


### OPTIONAL STEP (time-consuming) : creation of the dataset from scratch

To re-create the dataset from scratch by collecting features of data found in the initial Kaggle dataset, you will have to set up Spotify API credentials and then run the necessary scripts.

Although, this step is heavily time-consuming, and would clearly need to be optimized.

#### 1. Setting Up Spotify API Keys

This guide will help you create a Spotify Developer account, obtain your API credentials, and configure your R environment to use these credentials by setting environment variables in the `.Rprofile` file.

1. **Create a Spotify Developer Account:**
   - Go to the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/).
   - Click on the "Log In" button. If you don't have a Spotify account, you will need to create one.
   - Once logged in, click on the "Create an App" button.

2. **Create a New App:**
   - Provide an App name and description, and agree to the terms.
   - Click on the "Create" button to create the app.

3. **Obtain the API Keys:**
   - After creating the app, you will be redirected to the app's dashboard.
   - Here you will find your "Client ID" and "Client Secret". These are your API credentials.

4. **Edit Your `.Rprofile` File:**
   - Open the `.Rprofile` file where you added the Kaggle credentials in a text editor and add the following lines, replacing `"your_client_id"` and `"your_client_secret"` with the actual values from your Spotify Developer Dashboard:
     ```r
     Sys.setenv(SPOTIFY_CLIENT_ID = "your_client_id")
     Sys.setenv(SPOTIFY_CLIENT_SECRET = "your_client_secret")
     ```
     
5. **Restart R:**
   - Close your current R session and start a new one to ensure that the changes to the `.Rprofile` file are loaded.
   
#### 2. Run script to create the dataset

After setting up the spotify API credentials, you can run the script on the folder 'dataset creation'. Although, as the Spotify credentials are available only for one hour you will most surely get the error "401". 
Once you have this error, you can click on "rotate client secret" in your spotify app credentials settings, an update the client secret of your `.Rprofile`.

The dataset will be loaded into your 'data/derived' folder and updated each time you run the script and the error occur or the dataset has been entirely read.

### STEP 2 : Run the analysis



### Running analysis

One analysis at a time