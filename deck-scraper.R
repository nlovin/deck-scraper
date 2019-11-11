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

# getting user and deck ids
deck_urls[-1] %>% 
  str_extract("decks/\\d{4,9}") %>% 
  str_remove("decks/") %>% 
  enframe() %>% 
  select(-1) %>% 
  rename(user_id = 1)-> user_id

deck_urls[-1] %>% 
  str_extract("\\d{4,9}-") %>% 
  str_remove("-") %>% 
  enframe() %>% 
  select(-1) %>% 
  rename(deck_id = 1) -> deck_id

konrad <- bind_cols(konrad, deck_id)
konrad <- bind_cols(konrad, user_id)


list <- list()
pb <- txtProgressBar(0, nrow(konrad), style = 3)
for (i in 1:nrow(konrad)) {
  
  tmp <- read_html(paste0("https://deckstats.net/api.php?action=get_deck&id_type=saved&owner_id=", konrad$user_id[i], "&id=", konrad$deck_id[i], "&response_type=json")) %>% 
    html_text()
  
  list <- c(list, list(tmp))
  
  names(list)[i] <- paste0("deck_", i)
  
  Sys.sleep(sample(seq(1,3,0.5), 1))
  setTxtProgressBar(pb, i)
}



# list to json list
json_list <- map(list, fromJSON)

# Convert each list to a data.table

tb_list <- map(json_list, as.data.table)

dt <- rbindlist(tb_list, fill = TRUE)

dt <- rbindlist(dt_list, fill = TRUE)
rbind_list(json_list)

test <- json_list[["deck_1"]][["sections"]][["cards"]][[1]] %>% 
  as_tibble() %>% 
  select(1:2)

tb_list <- map(json_list, as_tibble)










# reading api jsons
# use user and deck codes
test <- read_html("https://deckstats.net/api.php?action=get_deck&id_type=saved&owner_id=24472&id=1126678&response_type=json") %>% 
  html_text()

tmp %>% 
  html_text()
