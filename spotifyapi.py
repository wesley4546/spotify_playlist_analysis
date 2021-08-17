import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import pandas as pd

"""
This code is a little messy but here is the overall process:

- Get my yearly playlists
- Get the audio features from each playlist
- Output to .csv

"""

# Credentials for API
sp = spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials(client_id="",
                                                                         client_secret=""))
user = sp.user_playlists(user="wgengland11")

num_playlists = len(user['items'])

# Empty lists/dict to fill in later
yearly_playlists = []
yearly_playlists_id = []
yearly_playlist_contents = {}
year_2020_playlist = []
year_2019_playlist = []
year_2018_playlist = []
year_2017_playlist = []
year_2016_playlist = []
big_playlist = {}

# Grab the playlists from the user (only my top ones)

print("Grabbing playlists...")
for i in range(num_playlists):

    playlist = user['items'][i]

    if playlist['name'] == '2018' \
            or playlist['name'] == '2019' \
            or playlist['name'] == '2020' \
            or playlist['name'] == '2017' \
            or playlist['name'] == '2016':
        yearly_playlists.append(playlist)

yearly_playlist_length = len(yearly_playlists)

print("Extracting song IDs from playlist...")

# Grab the songs from the playlists
for i in range(yearly_playlist_length):
    yearly_playlists_id.append(yearly_playlists[i]['id'])

print("Grabbing songs...")

# Appends the songs to the playlist
for i in range(yearly_playlist_length):
    yearly_playlist_contents[yearly_playlists[i]['name']] = sp.playlist_items(yearly_playlists_id[i])

for i in range(yearly_playlist_contents.__len__()):

    p_name = list(yearly_playlist_contents.keys())[i]
    num_songs = yearly_playlist_contents[p_name]['items'].__len__()
    playlist_track_ids = []

    for i in range(0, 100):
        playlist_track_ids.append(yearly_playlist_contents[p_name]['items'][i]['track']['id'])

    big_playlist[p_name] = playlist_track_ids

print("Grabbing audio features...")

for i in range(0, 100):
    year_2020_playlist.append(sp.audio_features(big_playlist['2020'][i]))
    year_2019_playlist.append(sp.audio_features(big_playlist['2019'][i]))
    year_2018_playlist.append(sp.audio_features(big_playlist['2018'][i]))
    year_2017_playlist.append(sp.audio_features(big_playlist['2017'][i]))
    year_2016_playlist.append(sp.audio_features(big_playlist['2016'][i]))


def output_to_csv(pl, file_name):
    df_playlist = pd.DataFrame(pl)
    df_playlist.to_csv(file_name)
    print(f"Saving ", file_name)


# Output to csv
output_to_csv(year_2020_playlist, "2020_playlist.csv")
output_to_csv(year_2019_playlist, "2019_playlist.csv")
output_to_csv(year_2018_playlist, "2018_playlist.csv")
output_to_csv(year_2017_playlist, "2017_playlist.csv")
output_to_csv(year_2016_playlist, "2016_playlist.csv")


