FROM ghcr.io/cirruslabs/flutter

ARG SCHEME
ARG API_URL

WORKDIR /app

COPY . .

RUN flutter pub get

RUN echo "SCHEME=$SCHEME" > dotenv_dev
RUN echo "API_URL=$API_URL" >> dotenv_dev

RUN echo "SCHEME=$SCHEME" > dotenv_prod
RUN echo "API_URL=$API_URL" >> dotenv_prod

RUN flutter pub run build_runner build

RUN flutter build web -t lib/main_dev.dart

CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]
