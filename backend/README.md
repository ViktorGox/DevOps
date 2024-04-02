# Bests Songs Ever Backend
This is the backend for the Best Songs Ever search application. This project has been built using SpringBoot with a MariaDB database.

## Configuration
Application settings have been stored in `src/main/resources/application.properties`. Please take a look at the official SpringBoot documentation pages to understand the database configuration (JPA settings). The host, username and password for the database can be set by using environment variables (`DB_HOST`, `DB_USER`, `DB_PASSWORD`). The database tables will be created automatically when the project is ran the first time.

## Testing
There is a SongControllerTest class written to test (some) parts of the controller. This can be done without a database connection, since we are using a mock. Make sure you set the `DOCKER_ENV=true` environment variable during the build process, so that the database connection will NOT be tested when building the application.

## Gradle commands
This project has been build with Gradle. Please see documentation about Gradle to see all available tasks.
Tasks that you need to do in all cases: being able to run the application, test the application, export the test report (html) as an artefact, build the project as a runnable JAR-file (and store it as an artefact).
