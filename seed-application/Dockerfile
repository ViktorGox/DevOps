FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /app

# Install curl
RUN apt-get update && apt-get install -y curl dos2unix

# Copy the script and data file into the container
COPY add_tracks.sh ./add_tracks.sh
COPY playlistdata.edi ./playlistdata.edi

# Convert line separators to UNIX format
RUN dos2unix ./add_tracks.sh

# Make the script executable
RUN chmod +x ./add_tracks.sh

# Define the command to execute when the container starts
CMD ["/bin/bash", "-c", "/app/add_tracks.sh"]