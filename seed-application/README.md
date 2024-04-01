# Seed Application
This should be a docker container that adds the data from `playlistdata.edi` to the MariaDB database, by sending a POST request to the backend server.
The url to the backend server should be dynamic, so that the URL can be set in your docker composition.

Please write your own shell script that parses the file and posts each song to the backend server. Make sure that data is only added when the data is not yet present in the database.