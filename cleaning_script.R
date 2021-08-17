library(tidyverse)

playlist_2016 <- read_csv(here::here("data", "2016_playlist.csv")) |>
rename(number = X1, features = `0`)

df_1 <- playlist_2018 |>
mutate(features = gsub("\\{|\\}|\\'| ", "", features))

wide_data <- data.frame(
  x = str_split(df_1$features, ",")
)

names <- c(paste0("song_", 1:99))
colnames(wide_data) <- names


structured_wide_data <- t(wide_data) |> as_tibble()

structured_wide_data <- structured_wide_data |>
mutate(song = row_number())


long_data <- structured_wide_data |>
group_by(song) |>
pivot_longer(
  cols = -song,
  names_to = "songs",
  values_to = "features"
)

long_data <- long_data |>
select(-songs)

sep_long_data <-
  long_data|>
  separate(col = features, into = c("feature", "score"), sep = ":") |>
  mutate(playlist = 2016)

write_csv(sep_long_data, here::here("data", "clean_2016_playlist.csv"))
