package nl.saxion.devops.playlist.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.Valid;
import nl.saxion.devops.playlist.entities.Song;
import nl.saxion.devops.playlist.repositories.SongRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/songs")
public class SongController {

    @Autowired
    private SongRepository songRepository;

    @Operation(summary = "Add a song to the database.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Successfully added a new song"),
            @ApiResponse(responseCode = "400", description = "Invalid parameters given"),
            @ApiResponse(responseCode = "500", description = "Internal server error, e.g: trying to add duplicate entry")
    })
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Song addSong(@Valid @RequestBody Song song) {
        return songRepository.save(song);
    }

    @Operation(summary = "Get all songs from the database.")
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Get all songs from the database",
                    content = { @Content(mediaType = "application/json", array = @ArraySchema(schema = @Schema(implementation = Song.class)) )}
            )
    })
    @GetMapping
    public List<Song> getAllSongs() {
        return songRepository.findAll();
    }

    @Operation(summary = "Search the database and find tracks with the search string in either the artist name or the title.")
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Search results",
                    content = { @Content(mediaType = "application/json", array = @ArraySchema(schema = @Schema(implementation = Song.class)) )}
            )
    })
    @GetMapping("/search")
    public ResponseEntity<List<Song>> searchSongs(@RequestParam String searchstring) {
        List<Song> searchResults = songRepository.findByArtistContainingOrTitleContaining(searchstring, searchstring);
        return ResponseEntity.ok(searchResults);
    }
}