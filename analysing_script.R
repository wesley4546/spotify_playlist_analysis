library(tidyverse)
library(ggdist)
library(patchwork)


# Combining ---------------------------------------------------------------

playlist_2016 <- read_csv(here::here("data", "clean_2016_playlist.csv"))
playlist_2017 <- read_csv(here::here("data", "clean_2017_playlist.csv"))
playlist_2018 <- read_csv(here::here("data", "clean_2018_playlist.csv"))
playlist_2019 <- read_csv(here::here("data", "clean_2019_playlist.csv"))
playlist_2020 <- read_csv(here::here("data", "clean_2020_playlist.csv"))

bad_features <- c("type", "id", "uri", "track_href", "analysis_url")


all_playlists <-
  playlist_2020 |>
  bind_rows(
    playlist_2019,
    playlist_2018,
    playlist_2017,
    playlist_2016
  ) |>
  filter(!(feature %in% bad_features)) |>
  mutate(score = as.numeric(score)) |>
  mutate(playlist = as.factor(playlist))


wider_all_playlists <-
  all_playlists |>
  pivot_wider(
    names_from = feature,
    values_from = score
  )

# Analysis ----------------------------------------------------------------

# Looking at the difference in valence 2018 vs 2020
wider_all_playlists |>
  ggplot() +
  aes(x = valence, fill = playlist) +
  geom_density(alpha = 0.5, position = "identity")


# Separating things
wide_2020 <- wider_all_playlists |> filter(playlist == "2020")
wide_2019 <- wider_all_playlists |> filter(playlist == "2019")
wide_2018 <- wider_all_playlists |> filter(playlist == "2018")
wide_2017 <- wider_all_playlists |> filter(playlist == "2017")
wide_2016 <- wider_all_playlists |> filter(playlist == "2016")

# T Test
t.test(x = wide_2020$valence, y = wide_2018$valence)

means <-
  wider_all_playlists |>
  group_by(playlist) |>
  summarize(
    across(
      danceability:duration_ms,
      ~ mean(.x, na.rm = T)
    )
  )


audio_feature_graph <- function(data, audio_feature) {
  
  # For passing in columns into function
  feature <- sym(audio_feature)
  
  plot <- data |>
    ggplot() +
    aes(x = !!feature, y = playlist, color = playlist, fill = playlist)
  
  plot <-
    plot +
    stat_slab(
      size = .5,
      alpha = .2
    ) +
    stat_halfeye(fill = "transparent")
  
  plot <-
    plot +
    theme_minimal() +
    labs(y = "") +
    theme(
      legend.position = "none",
      plot.title = element_text(hjust = 0.5)
    )
  
  return(plot)
}

# colnames(wider_all_playlists) |>
#   datapasta::vector_paste()


all_audio_features <- c(
  "danceability", "energy", "loudness", "speechiness",
  "acousticness", "liveness",
  "valence", "tempo", "duration_ms"
)

all_plots <- all_audio_features |>
  map(~ audio_feature_graph(wider_all_playlists, .x))

all_plots <-
  wrap_plots(all_plots) +
  plot_annotation(
    title = "Yearly Playlist Summary by Audio Feature",
    subtitle = "Distribution of Audio Feature score by yearly 'Your top 100 songs 20XX'",
    caption = "Data: My account via Spotify's API"
  )

all_plots


# Correlation analysis ----------------------------------------------------

library(correlation)
library(ggraph)

results <- correlation(
  wider_all_playlists,
  select = all_audio_features
)

results |>
  plot() +
  geom_node_text(label = all_audio_features, color = "black") +
  labs(
    title = "Gaussian Graphical Model of Audio Features",
    caption = "Data: My account via Spotify's API"
  )
