## Assignment 1 - BI-1 POST request script
At first, I had problems with running the backend locally. I tried to install the required version of Java which was 21,
but it didn't work, so I just changed build.gradle file in the fronted to require version 17.
Then I saw that I have to actually create the database first. I installed MariaDB and everything was working.
After that I created the script, got this error a few times:
````curl: (3) URL using bad/illegal format or missing URL```` but that was just because I was using the wrong url to
POST to the backend. I also figured out that if I run the script in WSL I have to give my IPv4 address instead of localhost
for the script to work.


## Assignment 2 - BI-2 Dockerfile for frontend.

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

After Bobby attempted the script on his laptop, and it failed. There was an additional file which was created in the lib/models folder which was created previously on my laptop and was not in the dockerignore, so it was copied over. Now the Dockerfile also runs the command ```flutter pub run build_runner build``` to generate that.

## Assignment 2 - BI-3 Dockerfile for backend
At first I tried building the application on Docker by using the graddle-wrapper.jar but wasn't able to do that. After
searching for the right image that has both gradle and jdk17 installed I figured out that I have to build the jar file
in Docker itself and then use it to actually run the program. I had some problems with setting the DOCKER_ENV variable
to true, but then I discovered I can just do ```ENV DOCKER_ENV=true```.

## Assignment 2 - BI-5 Write a docker-compose for backend and database
The problem I encountered here is that when I run the docker-compose file both the database and backend containers 
start simultaneously, then I got a tip from a very kind person(Trang) that there is a way to prevent this. I looked into
health checks. At first, I had problems because the image was using for the database couldn't use ``mysqladmin`` but I 
just found another image and it worked.

## Assignment 2 BI-6 - Add the add_tracks script to the docker-compose file
I had problem with running the script itself on Docker even though it worked on my local PC. At first I got this error
`` unable to start container process: exec: "/bin/sh": stat /bin/sh: no such file or directory: ``
I changed the image, but then I had this error
``/app/add_tracks.sh: line 11: syntax error: unexpected redirection `` which was because I was trying to run the script
with /bin/sh instead of bin/sh/bash, so I just changed the image again and everything was fine. 

## Assignment 3 - BI-7 CI/CD .yml file front end

After some trial and error, I realized that I can just copy the code from the already existing Dockerfile for the front end. Then to get the env files I created variables in gitlab Settings -> CI/CD and used them to copy and paste as contents for the env files. Then had some issues with getting the builds to be set as artifacts, but after some tinkering with the path I got it working. 

## Assignment 2 - BI-2-1 Docker image for front end should self generate dotenv files.

Somehow didn't think of the fact that the `dotenv_prod` and `dotenv_dev` files need to be generated manually. Now they are generated and the data is added to them. Currently, the data is inside the dockerfile, but will be moved into the docker-compose later.

## Assignment 2 - BI-9 Add front end to the docker compose.

Used arguments to provide the front end Dockerfile with data for its env files.

## Assignment 3 - BI-8 CI/CD .yml file for backend.

This time the first thing done was look up the already existing Dockerfile for the backend. Using ChatGPT I also tried adding the database. The result was this:
```
stages:
  - test
  - build

test_backend:
  stage: test
  image: gradle:jdk17
  services:
    - name: mariadb:lts-jammy
      alias: mariadb
  variables:
    DATABASE_URL: jdbc:mariadb://mariadb:3306/playlist
    DATABASE_USERNAME: root
    DATABASE_PASSWORD: root_password
  script:
    - gradle test
  artifacts:
    paths:
      - backend/build/reports/tests/
  only:
    - ci-cd-yml-file-for-backend

build_backend:
  stage: build
  image: gradle:jdk17
  script:
    - gradle build
  artifacts:
    paths:
      - backend/build/libs/*.jar
  only:
    - ci-cd-yml-file-for-backend
```
Of course that didn't work, because I was in the wrong directory. But also the database implementation was wrong. I then tried some other ways proposed by ChatGPT, but they failed too. 

Later I set a env variable to true, which I thought was supposed to be, but turns out that actually disabled the test which checks the database, so I thought it was working now. Then I tried to reduce duplicate lines using settings.

After that I started working on combining them. I once again had forgotten to fix the path, so that failed. Also, I had the set-up in the same stage as the testing and building of the front end. I tried setting them to have a dependency on the other jobs, but that did not work, and I am not sure why. So I separated them into different stages. 

I then also fixed how the gitlab variables are used to populate the dotenv files for the front end.

Now after the env variable which disables the database test is enabled, an error appears. From the error message I get that the key word used for setting the password might be wrong, so I changed it. The new keyword removed the error, but it still did not work.