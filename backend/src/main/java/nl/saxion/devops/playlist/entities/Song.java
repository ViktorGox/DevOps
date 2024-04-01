package nl.saxion.devops.playlist.entities;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(uniqueConstraints = {
        @UniqueConstraint(columnNames = {"artist", "title"})
})
public class Song {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(name = "id", example = "1")
    private Long id;
    @Schema(name = "artist", description = "Name of the artist or band", example = "TOTO")
    @NotBlank(message = "Artist is mandatory")
    private String artist;
    @Schema(name = "title", description = "Title of the track", example = "Africa")
    @NotBlank(message = "Title is mandatory")
    private String title;
    @Schema(name = "year", example = "1982")
    @Min(1800)
    @Max(2030)
    private int year;
    @Schema(name = "imageUrl", description = "Cover image for the track", example = "https://i.scdn.co/image/ab67616d00001e024a052b99c042dc15f933145b")
    private String imageUrl;

    public Song() {
    }

    public Song(Long id, String artist, String title, int year, String imageUrl) {
        this.id = id;
        this.artist = artist;
        this.title = title;
        this.year = year;
        this.imageUrl = imageUrl;
    }

    public Long getId() {
        return id;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
}