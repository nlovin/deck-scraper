library(tidyverse)
library(rvest)
library(jsonlite)
url <- 'https://deckstats.net/decks/search/?lng=en&search_title=&search_format=10&search_season=0&search_cards_commander%5B%5D=Syr+Konrad%2C+the+Grim&search_cards_commander%5B%5D=&search_price_min=&search_price_max=200&search_number_cards_main=&search_number_cards_sideboard=&search_cards%5B%5D=&search_tags=&search_age_max_days=0&search_age_max_days_custom=&search_order=updated%2Cdesc&utf8=%E2%9C%94'
path <- '//*[@id="deck_search_results"]/div/div[2]/table' # table path
# table info, no urls
konrad <- read_html(url) %>% 
  html_node(xpath = path) %>% 
  html_table() %>% 
  select(-1)

pg <- read_html(url)
# deck search urls
pg %>% 
  html_nodes("table") %>% 
  html_nodes("tr") %>% 
  html_node("a") %>% # NODE
  html_attr("href") -> deck_urls


tmp = as_tibble(deck_urls[-1])

konrad <- bind_cols(konrad, tmp) %>% 
  rename(urls = value)

rm(tmp)

# Extract deck and user ids
# alt code in notes
konrad <- konrad %>% 
  mutate(user_id = str_extract(urls, "decks/\\d{4,9}"),
         user_id = str_remove(user_id, "decks/"),
         deck_id = str_extract(urls, "\\d{4,9}-"),
         deck_id = str_remove(deck_id, "-"))
  
tmp <- read_html("https://deckstats.net/api.php?action=get_deck&id_type=saved&owner_id=126427&id=1461216&response_type=json") %>%
  html_text()

list <- list()
pb <- txtProgressBar(0, nrow(konrad), style = 3)
for (i in 1:nrow(konrad)) {
  
  tmp <- read_html(paste0("https://deckstats.net/api.php?action=get_deck&id_type=saved&owner_id=", konrad$user_id[i], "&id=", konrad$deck_id[i], "&response_type=json")) %>% 
    html_text()
  #"https://deckstats.net/api.php?action=get_deck&id_type=saved&owner_id=126427&id=1461216&response_type=json"
  list <- c(list, list(tmp))
  
  names(list)[i] <- paste0("deck_", i)
  
  Sys.sleep(sample(seq(1,3,0.5), 1))
  #setTxtProgressBar(pb, i)
}



# list to json list
json_list <- map(list, fromJSON)

# Convert each list to a data.table

card_list <- json_list %>% 
  map(~ bind_rows(.x[["sections"]][["cards"]])) %>% 
  map(~ select(.x, 1:2)) %>% 
  map(as_tibble)

# keeps dfs separate
imap(card_list, ~mutate(.x, deck = .y))


deck_lists <- bind_rows(card_list, .id = "deck")

##### Combining All the Data #####
konrad <- konrad %>% 
  mutate(deck = paste0("deck_", seq(1,nrow(konrad))))

deck_lists %>% 
  left_join(konrad, by = 'deck') -> konrad_deck_lists

konrad_deck_lists <- konrad_deck_lists %>% 
  janitor::clean_names()

write_csv(konrad_deck_lists, path = "data/konrad_deck_lists.csv")

