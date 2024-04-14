BACKEND_ENDPOINT=http://$LB_DNS/api/songs
# Method to actually do the POST request
parse_and_add_song() {
    local line="$1"
    local artist
    local title
    local year
    local imageUrl

    # Set IFS to '+' and read the input line into variables
    IFS='+' read -r _ artist title year imageUrl _ <<< "$(echo "$line" | cut -d '+' -f 1-)"

    # Check if any of the required fields are missing or incomplete
    if [ -z "$artist" ] || [ -z "$title" ] || [ -z "$year" ] || [ -z "$imageUrl" ]; then
        echo "Skipping incomplete line: $line"
        return 1
    fi

    # Make the POST request
    curl -X POST -H "Content-Type: application/json" -d '{
        "artist": "'"$artist"'",
        "title": "'"$title"'",
        "year": '"$year"',
        "imageUrl": "'"$imageUrl"'"
    }' "$BACKEND_ENDPOINT"
}

response=$(curl -s "$BACKEND_ENDPOINT")
# Check if the response contains any elements
if [[ "$response" == *"[]"* ]]; then
    echo "No elements found in the array."
else
    echo "Database already populated."
    exit 1
fi

# This will read until the last line
while IFS= read -r line || [[ -n "$line" ]]; do
    # Exclude lines that start with UNH or UNT
    if [[ "$line" != UNH* && "$line" != UNT* ]]; then
        parse_and_add_song "$line"
    fi
done < "playlistdata.edi"