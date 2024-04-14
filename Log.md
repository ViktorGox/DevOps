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

After trying a lot of things, nothing ended up working. Asked bobby for help, but still nothing worked. Reverted back to the test being skipped.

## Assignment 4 - BI-10 Run the backend on a EC2 instance
Our idea was for me to create a basic AWS structure where we only have 1 EC2 instance where the backend was supposed to
be. I thought a lot about how to do it. Eventually I discovered that I can just upload the Docker images onto the instance.
After a lot of problems with the ssh key I was trying to use it eventually worked. The problem I has was that when I tried 
to run ``chmod 400`` on the ssh key it didn't work. After that everything was easy but it definitely took some time for me to learn
how to build the images correctly and set up everything. I created a send_files.sh script so it would be easier for us
to upload files to a certain instance. At the end I ran the database and the backend on the same instance.

## Assignment 4 - BI-12 Create a S3 bucket with frontend
At first I tried to do the code with Chat-GPT but the code was deprecated so I looked online and I pasted the link where
I got the code from about creating the S3 bucket using Terraform. At first when I opened the bucket through the browser,
all I could see was raw html, then Viktor opened it as well, it was the same for him. At the end I think the problem was 
in the Meta Data, because it was not set to html/text. 

## Assignment 5 - BI-14 CI/CD builds docker images and upload them to the gitlab container registry.

Tested a bunch of stuff locally to see how it works, used ChatGPT and the official Gitlab documentation. I couldn't figure out why I wasn't able to run ./dockerize.sh in the CI/CD environment, so I just did the scripts work manually. At first, I was unaware that the `CI_PROJECT_NAMESPACE` and `CI_PROJECT_NAME` were a thing, so I tried making a script which takes in the Url of the repository and converts it, but that turned out to be unnecessary. Something that will need to be done is to delete exiting containers if that's possible.

## Assignment 5 - BI-20 Script which applies the terraform and replaces the CI/CD variables.

To automate things even more, we thought to create a script which will run the terraform and will update the environment variables inside the CI/CD.
All the code is done with the help of ChatGPT or self thought. Some look up of the gitlab documentation was done, but it did not help.

## Assignment 5 - BI-20-1 Change SSH key to Base64 and replace hardcoded data in the CI/CD file with the real variables.

Bobby had issues with the SSH key, and was successful with making it read from Base64, so I converted the key received from terraform.

## Assignment 5 - 17

The random generation part was actually easy, but then I ran into problems when running the CI/CD. The aws was giving errors that something exists while it didn't and the opposite. Terraform then didn't generate the auto-scaling group so something failed later.  Got it working at the end though.

## Assignment 5 - 25

I had to do some testing for this one to understand how the cache works. I tried caching the infra folder, but that didn't work, not sure exactly why, since I tried to cache a single testing file and that worked fine. Then I tried caching individual files, but then I ran into a different weird problem, which was that the state was not being updated. Finally, I added the base project directory environment variable, and it worked. Running terraform apply once gives some error, when it is run again, the error is gone. Couldn't figure out how to fix it, so I just call apply twice.

## Assignment 5 - 26

Used Bobby's script, added a check which does a request and checks whether the return is an empty array. Added a stage for it, and didn't realize that exit 1 will cause the ci cd to call fail, so I was confused why it failed with no comment. Reworked the script, but that bug was left in there, I fixed it later for issue 17.

## Assignment 5 - BI-15 CI/CD uploads the images from the registry to the EC2
Honestly this task took some time. First of all I had problems with the SSH key we were creating. That's why I created the output for terraform
and also why I added the ssh key to be created from terraform so it wouldn't require for it to be stored locally. This also meant
that the SSH key should somehow be uplaoded to the CI/CD variables. Because of the script that Viktor made that was easy. The problem was that
for some reason it didn't want to accept the ssh key when the ssh connection was being made. That's when I decided to just use
base 64 encoding after some research.

## Assignment 6 -  BI-23 Make the backend to use a load balancer and an autoscaling group
This was a pain, because this meant that for the CI/CD to be able to upload the images, it meant that it had to connect to
all of the instances from the load balancer. In order to do this we needed the ip addresses of every instance. I tried getting them from
terraform but terraform doesn't have an already made function for that (a little bit stupid if you ask me). After wasting my time on
trying to do it through terraform I decided to try through CI/CD. First I tried running commands locally to get the ip's of the running
instance. I couldn't make it work until I found a command from stackoverflow which worked. After Vitkor had already struggled with aws
configuration I was able to set it up easily. But my problem was that I needed an image with Ubuntu and aws, after a long time of searching
Viktor gave me an image from gitlab which worked perfectly.

## Assignment 6 - BI-16 CI/CD uploads frontend web files as static website in AWS S3 bucket

Tried a bunch of stuff once again. Found the base image in the gitlab documentation. Had issues with setting the aws credentials, and honestly I am not sure what changed to make it work, but it works.

## Assignment 6 - BI-16 CI/CD uploads frontend web files as static website in AWS S3 bucket

Tried a bunch of stuff once again. Found the base image in the gitlab documentation. Had issues with setting the aws credentials, and honestly I am not sure what changed to make it work, but it works.

## Assignment 6 BI-24 Create RDS for the database

This was not that much of a pain to create. At first ChatGPT gave me deprecated code, so I started looking on my own. At first
I had problems with selecting a version for MariaDB because it gave me an error that it couldn't find it. Eventually I just
created an RDS manually just to see what is needed and what version I can use. After figuring all of these stuff out I created our
first RDS. At first it was publicly accessible but eventually I was able to change the code in terraform and make it run
on the VPC we are using for our infrastructure.

## Assignment 6 BI-27 Create a launch template which downloads the backend image from the start

We had one problem in our infrastructure which was the following one: What would happen if a new instance is created by the
autoscaling group? Well the answer to that question is, nothing, literally. In other words, the instance is going to be empty and
only have docker installed but it won't have the backend, so we decided ot make a launch template for instances. I wasn't able to
make a launch template because it always gave me weird errors. That's why we created a launch configuration because somehow it
worked.