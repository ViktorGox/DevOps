FROM scratch

# Set the working directory inside the container
WORKDIR /app

# Copy the script into the container
COPY script.sh /app/script.sh

# Make the script executable
RUN chmod +x /app/script.sh

# Define the command to execute when the container starts
CMD ["/bin/sh", "-c", "/app/script.sh"]
