FROM ghcr.io/cirruslabs/flutter

WORKDIR /app

COPY . .

RUN flutter pub get

RUN echo "SCHEME=http" > dotenv_dev
RUN echo "API_URL=localhost:8080" >> dotenv_dev

RUN echo "SCHEME=http" > dotenv_prod
RUN echo "API_URL=localhost:8080" >> dotenv_prod

RUN flutter pub run build_runner build

RUN flutter build web -t lib/main_dev.dart

CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]
