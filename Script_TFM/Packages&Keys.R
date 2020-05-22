### PACKAGES ###
library(devtools)
library(httr)
library(rjson)
library(bit64)
library(dplyr)
library(rtweet)
library(ggplot2)
library(tidyverse)
library(lubridate)
library(hrbrthemes)
library(igraph)
library(networkD3)
library(htmlwidgets)
library(htmltools)
library(plotly)
library(xts)
library(dygraphs)

### KEYS AND TOKENS ###
Mashape_key = " "
consumer_key <- " "
consumer_secret <-" "
access_token <- " "
access_secret <- " " 
myapp = oauth_app("twitter", key=consumer_key, secret=consumer_secret)
sig = sign_oauth1.0(myapp, token=access_token, token_secret=access_secret)
token <- create_token(
  app = " ",
  consumer_key = consumer_key,
  consumer_secret = consumer_secret,
  access_token = access_token,
  access_secret = access_secret)  
get_token()

