package nl.saxion.devops.playlist;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.junit.jupiter.api.condition.DisabledIfEnvironmentVariable;

@SpringBootTest
@DisabledIfEnvironmentVariable(named = "DOCKER_ENV", matches = "true")
class PlaylistApplicationTests {

	@Test
	void contextLoads() {
	}

}
