FROM scratch
WORKDIR /app

# Copy Gradle files
COPY build.gradle settings.gradle /app/
COPY gradle /app/gradle

# Download Gradle wrapper
RUN ./gradlew --version

# Copy application source
COPY src /app/src

# Copy .env file
COPY .env /app/.env

# Build application
RUN ./gradlew --no-daemon clean build

# Expose the port your application runs on
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "build/libs/your-application.jar"]
