# Exam Assignment DevOps — Best Songs Ever
_April 2024_

In this exam assignment, you will design and implement an infrastructure and development environment for a web application, which allows users to view and search a playlist with the best songs ever made (according to Spotify).

This Flutter web application connects to a backend written in SpringBoot. The information about the songs in the playlist is stored in the backend application. The SpringBoot application uses a MariaDB database to store the songs.

Your task is to run and test this application. In addition, you must set up the pipeline for continuous integration for this application and containerize the application.

### Conditional Requirements

- It is mandatory to submit all *practice assignments* and have them signed off by your teacher before this final assignment can be submitted. Of course, you can already start working on this exam assignment in the meantime.

- For each requirement (see below), you explain how you solved the problem and why you solved it this way. You describe this in your own words in a way that is understandable to the teacher who is assessing your work. You can write it down in a Markdown file in your repository or in comments in the source code (in the latter case, you refer in the Markdown file to the locations of these comments).

- Make sure you use a repository in the Saxion Gitlab organization, created via [https://repo.hboictlab.nl](https://repo.hboictlab.nl/)

- Upload a zipped export of your Gitlab project to Blackboard (Settings → General → Advanced → Export Project).\
  **Also mention the URL of your repository in the comments field on Blackboard.**

### Exam Rules

- The deadline for submitting the assignment is Monday, April 15, 9:00 AM (week 3.9).

- The assignment is done in groups of two students who have registered with their teacher. Groups are formed in week 7, with group members both having to have submitted an equal number of practice assignments to be allowed to work together (maximum 1 week difference).

- Your grade is determined based on the assessment that takes place after you have submitted your assignment. So make sure you understand all the parts you have made, theoretical questions will also be asked about your solution.

- You only get points for parts of your work that you can explain during the assessment. For example: if your code works, but you can't explain what it does or why it works that way, then that part of the assignment does not count towards your final grade.

- It is **not** allowed to get help from someone outside your test group, except from your teacher. It is also **not** allowed to provide help to someone else.

- You may use online posts, articles, tutorials, books, videos. However, you must add references [[1]](https://libguides.murdoch.edu.au/IEEE) for all sources and code snippets that you use in your text/code.

## Process Requirements

During the execution of the assignment, you must follow a proper software development process, as covered in week 1. This includes things like keeping track of tasks using Gitlab Issues, using Git to collaborate on the code, and using branches and merge requests to be able to do code reviews. This should all be clearly visible from your Gitlab repository.

## Functional Requirements

### 1. Add data to the backend

In the repository, you will find a folder containing a backend application. This is a SpringBoot application provided by us that returns data in JSON format. If you run the application (with Gradle) and go to http://localhost:8080/api/songs, you will see a list of songs that are currently present in the database. Initially, the database is empty.

To add songs to the backend, you need to do a POST request in the correct format (see the `seed-application` folder). You can use `curl` for this. Make sure you set the content type to `application/json` in your Curl command. In addition, the REST endpoint must be configurable through an environment variable.

Write the Bash script `add_tracks.sh`, which reads the data file `playlistdata.edi` and then adds the songs to the backend (also known as 'seeding'). Provide sufficient error handling.

### 2. Containerization of the applications

The backend and frontend must be containerized with Docker and Docker Compose. There must be separate backend and frontend containers.

Provide a convenient way to build, run, and stop the containers by writing a script. Make sure that temporary files created by running the application outside Docker do not end up in the image.

Extend the compose file so that the data is stored in a MariaDB database. The `README.md` of the backend explains which variables are needed to connect the backend to the database.

There are some steps needed to build the frontend. The steps are described in the `README` in the frontend folder. For building, a Flutter image is needed. The image `ghcr.io/cirruslabs/flutter` works well for both the Dockerfile and for the Gitlab CI/CD integration.

### 3. Continuous Integration

Implement a development street with continuous integration for the app. The CI/CD must consist of at least two phases. In the first phase, the backend application is tested and built. Export the test report as an artifact and also the executable JAR file.

In addition, the frontend application must be built. This consists of two different jobs, one for the web frontend and one for the Android application. Make sure that both the web bundle and the APK file are available as artifacts in Gitlab. Use the image mentioned in the previous chapter for this.

### 4. Create an infrastructure to run the application

Create a suitable infrastructure for the application in AWS using Terraform. The infrastructure does not (yet) need to be high availability. If this is not possible with Terraform, you may manually create the infrastructure (of course, you will lose points for this). Your Terraform configuration must be placed in the supplied `infra` folder.

The backend must be installed on an EC2 instance (for now manually), the frontend can be served as a static website.

### 5. Automate the deployment of applications

Automate the deployment of the backend so that, when we commit to the main branch, the Gitlab CI:

- builds the necessary Docker image(s)

- uploads the image(s) to the [private container registry](https://docs.gitlab.com/ee/user/packages/container_registry/index.html) of your Gitlab repository

- connects to the EC2 instance using SSH, pulls in the Docker image(s) and runs it

- uploads the built frontend web files as a static website.

To achieve this, you need to copy the contents of your AWS private SSH key (which you use to connect to the instance) to an environment variable in Gitlab CI (Settings → CI/CD → Variables, click on "Expand"). In your `.gitlab-ci.yml` file, you can then use this variable to connect to the EC2 instance via SSH.

When using SSH, the client checks if the server is a known server. For our automated deployment, this is not very convenient (because someone then has to type 'yes'). If you want to disable this check, you can use the option `-o StrictHostKeyChecking=no` with SSH.

### 7. Create a backend with high availability

Extend your Terraform configuration with a high availability backend. Don't forget to also make the database highly available (i.e., redundant). If this is not possible, you may also work with a single database instance, although you will of course get fewer points for this.

Make sure the instances are not directly accessible from outside your network. Don't forget to adjust the frontend to connect to your new infrastructure. To validate whether your infrastructure is set up correctly, check if your frontend shows the list of songs.