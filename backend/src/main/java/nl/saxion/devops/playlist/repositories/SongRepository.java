package nl.saxion.devops.playlist.repositories;

import nl.saxion.devops.playlist.entities.Song;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SongRepository extends JpaRepository<Song, Long> {
    List<Song> findByArtistContainingOrTitleContaining(String artist, String title);
}