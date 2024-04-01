package nl.saxion.devops.playlist.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import nl.saxion.devops.playlist.entities.Song;
import nl.saxion.devops.playlist.repositories.SongRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.Arrays;
import java.util.List;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SongControllerTest {

    @Mock
    private SongRepository songRepository;

    @InjectMocks
    private SongController songController;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void getAllSongs() throws Exception {
        // Arrange
        List<Song> songs = Arrays.asList(
                new Song(1L, "Artist1", "Title1", 2000, "image1"),
                new Song(2L, "Artist2", "Title2", 2010, "image2")
        );

        when(songRepository.findAll()).thenReturn(songs);

        // Act and Assert
        MockMvc mockMvc = createMockMvc(songController);
        mockMvc.perform(MockMvcRequestBuilders.get("/api/songs"))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.content().json(objectMapper.writeValueAsString(songs)));

        // Verify that the repository method was called once
        verify(songRepository, times(1)).findAll();
    }

    @Test
    void addSong_ValidInput_Success() throws Exception {
        // Arrange
        Song newSong = new Song(null, "NewArtist", "NewTitle", 2022, "newImage");
        Song savedSong = new Song(1L, "NewArtist", "NewTitle", 2022, "newImage");

        when(songRepository.save(any(Song.class))).thenReturn(savedSong);

        // Act and Assert
        MockMvc mockMvc = createMockMvc(songController);
        mockMvc.perform(MockMvcRequestBuilders.post("/api/songs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(newSong)))
                .andExpect(MockMvcResultMatchers.status().isCreated())
                .andExpect(MockMvcResultMatchers.content().json(objectMapper.writeValueAsString(savedSong)));

        // Verify that the repository method was called once with the correct argument
        verify(songRepository, times(1)).save(argThat(song -> song.getArtist().equals("NewArtist") && song.getTitle().equals("NewTitle")));
    }

    @Test
    void addSong_InvalidInput_BadRequest() throws Exception {
        // Arrange
        Song invalidSong = new Song(null, "", "", 100, "newImage");

        // Act and Assert
        MockMvc mockMvc = createMockMvc(songController);
        mockMvc.perform(MockMvcRequestBuilders.post("/api/songs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidSong)))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());

        // Verify that the repository method was not called
        verify(songRepository, never()).save(any(Song.class));
    }

    @Test
    void searchSongs() throws Exception {
        // Arrange
        List<Song> searchResults = Arrays.asList(
                new Song(1L, "Artist1", "Title1", 2000, "image1"),
                new Song(2L, "Artist2", "Title2", 2010, "image2")
        );

        when(songRepository.findByArtistContainingOrTitleContaining("Artist", "Artist"))
                .thenReturn(searchResults);

        // Act and Assert
        MockMvc mockMvc = createMockMvc(songController);
        mockMvc.perform(MockMvcRequestBuilders.get("/api/songs/search")
                        .param("searchstring", "Artist"))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.content().json(objectMapper.writeValueAsString(searchResults)));

        // Verify that the repository method was called once with the correct argument
        verify(songRepository, times(1)).findByArtistContainingOrTitleContaining("Artist", "Artist");
    }

    public static MockMvc createMockMvc(Object controller) {
        return MockMvcBuilders.standaloneSetup(controller).build();
    }
}