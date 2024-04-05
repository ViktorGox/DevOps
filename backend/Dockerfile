FROM gradle:jdk17

# Set the working directory inside the container
WORKDIR /app


# Copy the Gradle configuration files
COPY build.gradle .
COPY settings.gradle .
COPY gradle/ gradle/

# Copy the .env file and set the environment variable
COPY .env /app
ENV DOCKER_ENV=true
ENV DB_HOST=192.168.100.1
ENV DB_USER=root
ENV DB_PASSWORD=password

# Copy the application source code
COPY src/ src/

# Build the application using Gradle
RUN gradle build

# Expose port
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "build/libs/playlist-0.0.1-SNAPSHOT.jar"]
