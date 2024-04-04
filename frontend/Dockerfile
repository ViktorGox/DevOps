FROM ghcr.io/cirruslabs/flutter

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter build web -t lib/main_dev.dart

CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]