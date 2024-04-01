# Best Songs Ever Search Frontend
This is the frontend for the Best Songs Ever search application. It is a Flutter application that can be built for both Android and web.

## Getting Started
To run and test the application, make sure you have Flutter installed: [Click here](https://docs.flutter.dev/get-started/install)  
(Tip: Run `flutter doctor` to make sure everything is installed correctly)

!! Please note: This step is of course optional if you use Docker images to run / build the application (like in Gitlab CI/CD).

# Creating dotenv files
This Flutter application uses dotenv files to handle different API endpoints for different builds of the system.
There's two dotenv files that are needed in the project: the `dotenv_dev` and `dotend_prod` files.
Your task is to create both files (through Gitlab Pipelines preferably) when building the application (see next chapter).
When running locally, it's enough to copy the dotenv_example file and create the two necessary files. 
Fill in the values for the two keys and you should be able to build the project.

!! Please note: It is not possible for Android applications to access localhost. 
To get around this, use API_URL=10.0.2.2:8080 instead of localhost:8080. The scheme still needs to be HTTP.

## Running and building the application
Once everything is installed, run the following commands to build the application:
1. `flutter pub get` - Installs all dependencies
2. `dart run build_runner build` - Creates the auto-generated model files
3. `flutter build [web / android]` - Builds the application for either web or android

!! Please note: For step 3, there are two targets available. One for development and one for production. 
To build the project properly, use -t with the right file. For example: `-t lib/main_dev.dart`

After that, run the application:
1. `flutter run`
2. Select the right device
3. (A shortcut to run on a certain device can be used: `flutter run -d [device]`. For example: `flutter run -d chrome`)

## Trouble shooting
### base-href
If you run the application in anything but the root of the site, make sure you provide the right --base-href argument to the build command for web.
For example, if your application runs on www.saxion.nl/application/, you provide `--base-href "/application/"` to the build command.
In most cases, if you deploy to an S3 bucket, you don't need this.

If you want to run the application locally in your browser, change the /build/web/index.html file to include `<base href="./">`

### Running app locally
If you can't get the app to run locally, don't forget you don't have to for the final assignment. 
Let Gitlab CI/CD build the application for you and save it as artifacts. 
After downloading the artifacts, you should be able to run it locally in your browser (see previous chapter).