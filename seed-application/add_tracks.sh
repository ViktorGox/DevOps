#TODO Make this variable in .env file
BACKEND_ENDPOINT=http://192.168.178.101:8080/api/songs
# Method to actually do the POST request
parse_and_add_song() {
    local line="$1"
    local artist
    local title
    local year
    local imageUrl

    IFS='+' read -r _ artist title year imageUrl _ <<< "$(echo "$line" | cut -d '+' -f 1-)"

    echo "$artist + $title + $year + "'"$imageUrl"'""

    curl -X POST -H "Content-Type: application/json" -d '{
        "artist": "'"$artist"'",
        "title": "'"$title"'",
        "year": '"$year"',
        "imageUrl": "'"$imageUrl"'"
    }' "$BACKEND_ENDPOINT"
}

# This will read until the last line
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" != UNH* && "$line" != UNT* ]]; then
        parse_and_add_song "$line"
    fi
done < "playlistdata.edi"
