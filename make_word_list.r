library(genius)
library(gtools)
library(tidytext)
library(tidyverse)

ARTIST = "Taylor Swift"
ALBUMS = c(
  "Taylor Swift", "Fearless", "Speak Now","Red",
  "1989", "Reputation", "Lover", "Folklore", "Evermore")

# Read each album and concat into df of all the lyrics.
lyric_df = NULL
for (album in ALBUMS) {
  print(album)
  lyric_df = genius_album(artist = ARTIST, album = album) %>%
    select(lyric) %>%
    distinct() %>%
    bind_rows(lyric_df)
}

# Clean:
# - Replace "/"s with " "s
# - Remove punctuation
# - Convert to lower case
# - De-dupe at a line-level-- this will make the next step faster
cleaned = lyric_df %>% 
  mutate_if(is.character, str_replace_all,
            pattern = "/", replacement = " ") %>%
  mutate_if(is.character, str_replace_all,
             pattern = "[[:punct:]]", replacement = "") %>%
  mutate_if(is.character, tolower) %>%
  distinct()

# Replace odd characters
clean_up = function(x) {
  asced = as.integer(asc(x))
  asced[asced < 97 | asced > 122] = 32
  chred = chr(asced)
  stuck = paste(chred, collapse = "")
  return(stuck)
}
replaced = mutate(cleaned,
                  lyric = apply(X = cleaned, MARGIN = 1, FUN = clean_up))

# Split out words into their own rows, and de-dupe
word_df = NULL
for (i in 1:nrow(replaced)) {
  word_df = replaced %>%
    slice(i) %>%
    unlist(., use.names = FALSE) %>%
    strsplit(" ") %>%
    unlist() %>%
    as.tibble() %>%
    bind_rows(word_df) %>%
    distinct()
}

# Save
write_csv(word_df %>% arrange(-nchar(value)), "word_list.csv")
