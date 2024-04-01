#!/bin/bash

# Parse the file playlistdata.edi with bash and add to the database by sending a POST HTTP request to the backend end point for adding songs.
# Make sure the backend end point is configurable by using environment variables.

# The json format in which your need to post the data has to look like this:
# { 
#     "artist": "Toto",
#     "title": "Africa",
#     "year": 1982,
#     "cover": "https://i.scdn.co/image/ab67616d00001e024a052b99c042dc15f933145b",
# }

