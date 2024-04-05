## Assignment 2 - BI-2

First iteration of the Dockerfile was

```
FROM ghcr.io/cirruslabs/flutter

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter run -t lib/main_dev.dart
```

This didn't work for two reasons, first there was no CMD command, so nothing to keep the container running, and also the `flutter run` runs the program using some other application for front end. And of course the docker linux can't do that. 

I got that information from the log of the container.

Then I asked chatGPT for ideas and got the answer to run ```RUN flutter build -t lib/main_dev.dart``` instead.

This now didn't show anything in the console, so I assume it finished successfully. But the container exited immediately, that is because there was nothing to replace the function of the flutter run.

ChatGPT proposed to run `CMD ["flutter", "run", "-d", "web-server", "--web-hostname", "0.0.0.0", "--web-port", "8080"]`, but that did not work. I am not sure why. It gave the same error as running the `flutter run`.

I tried running it with python3 and this time it worked. I just had to specify the directory otherwise it just hosts the work dir folder.
`CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]`