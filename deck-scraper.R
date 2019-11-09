library(tidyverse)
library(rvest)
library(jsonlite)
url <- 'https://deckstats.net/decks/search/?lng=en&search_title=&search_format=10&search_season=0&search_cards_commander%5B%5D=Syr+Konrad%2C+the+Grim&search_cards_commander%5B%5D=&search_price_min=&search_price_max=200&search_number_cards_main=&search_number_cards_sideboard=&search_cards%5B%5D=&search_tags=&search_age_max_days=0&search_age_max_days_custom=&search_order=updated%2Cdesc&utf8=%E2%9C%94'
path <- '//*[@id="deck_search_results"]/div/div[2]/table' # table path
# table info, no urls
konrad <- read_html(url) %>% 
  html_node(xpath = path) %>% 
  html_table()

pg <- read_html(url)
# deck search urls
pg %>% 
  html_nodes("table") %>% 
  html_nodes("tr") %>% 
  html_node("a") %>% # NODE
  html_attr("href") -> deck_urls
# deck search urls w/ user URLs
pg %>% 
  html_nodes("table") %>% 
  html_nodes("tr") %>% 
  html_nodes("a") %>% # NODES
  html_attr("href")
# just gets first url
pg %>% 
  html_node("td a") %>% 
  html_attr("href")

# gettning user and deck ids
deck_urls[-1] %>% 
  str_extract("decks/\\d{4,9}") %>% 
  str_remove("decks/")
# reading api jsons
# use user and deck codes
read_html("https://deckstats.net/api.php?action=get_deck&id_type=saved&owner_id=24472&id=1126678&response_type=json") %>% 
  html_text()

