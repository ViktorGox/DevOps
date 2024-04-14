# Project information

- AWS must be running.
- Generate a personal access token in gitlab.
- Change the following Gitlab CI/CD variables:
  - P_ACCESS_KEY - Assign the personal access token.
  - LOGIN_USERNAME - Your gitlab username. Currently, Bobby's is there, so you can use that.
  - LOGIN_PASSWORD - Your gitlab password. Currently, Bobby's is there, so you can use that.
  - MY_AWS_ACCESS_KEY_ID
  - MY_AWS_SECRET_ACCESS_KEY
  - MY_AWS_SESSION_TOKEN
- If you want you can also change data inside the ./infra/variables.tf file.

If it is set up correctly, a push to main will trigger the entire system. No other manual input is required. 
The front end is a static website uploaded to a S3 bucket. 
The database is set up to use RDS. 
The back end uses a load balancer and an auto-scale group.

The docker images are built within the CI/CD, they are saved into the gitlab registry, and then the AWS EC2 instances pull the image.

Currently, the S3 bucket uses a randomly generated name, to connect to it you can find it in the Gitlab CI/CD variable BUCKET_DNS.

Made with love - Bobby and Viktor