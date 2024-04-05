FROM gradle:jdk17

# Set the working directory inside the container
WORKDIR /app

ENV DOCKER_ENV=true

# Copy the Gradle configuration files
COPY backend/build.gradle .
COPY backend/settings.gradle .
COPY backend/gradle/ gradle/

# Copy the application source code
COPY backend/src/ src/

# Build the application using Gradle
RUN gradle build

# Expose port
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "build/libs/playlist-0.0.1-SNAPSHOT.jar"]
