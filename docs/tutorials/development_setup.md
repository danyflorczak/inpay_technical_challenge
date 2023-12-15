# Development setup

This repository depends on Google Api, in order to make it work you have to follow two setups: 
- [Application Setup](#Application-Setup), which would be recommended for people that doesn't have rails on their computer otherwise just follow the last step.
- [Google Cloud Setup](#Google-Cloud-Setup), which will walk you through creating project on google cloud and generate credentials essential for working with this app.
## Application Setup

### Requirements

- [asdf](https://asdf-vm.com/)
- [Homebrew](https://brew.sh/)

### Steps

1. Install Ruby

   ```sh
   asdf plugin add ruby
   asdf install ruby 3.2.2
   asdf global ruby 3.2.2
   gem update --system
   ```

2. Install Node

   ```sh
   asdf plugin add nodejs
   asdf install nodejs 20.9.0
   asdf global nodejs 20.9.0
   npm install -g yarn
   ```

3. Install Rails
   ```sh
   gem install rails -v 7.1.1
   ```

4. Install PostgreSQL
   ```sh
   brew install postgresql
   brew services start postgresql
   ```

5. Create db
   ```sh
   rails db:create
   rails db:migrate
   ```

## Google Cloud Setup

### Requirements

- [Google Account](https://google.com)

### Steps

1. Go to https://console.developers.google.com
2. Click "Select Project" => "New Project"
3. Type your Project name and click "Create"
4. Select "OAuth consent screen" => "User Type" select user type as external
5. In the next step, we fill in the name of the application, the email address for users needing help (your email of the account you have designated to work with the project), leave the logo blank, insert "http://localhost:3000/users/sign_in" in the "Application homepage" field, leave the other links blank. Fill in Your email in the "Deveploper contact information" field and click "Save and continue".
6. You will be taken to the "Scopes" step, we do not change anything here and click "Save and continue".
7. You will be taken to the "Test users" step, where by clicking on "Add users" we add the email addresses of our test accounts. After adding them, we click "Save and continue".
8. From the side panel, go to the "Login Details" section and click "Create Login Details" where you select "OAuth Customer ID."
9. In the "Application Type" field, select "Web Application", in the "Name" field, type your app name, in the "Authorized redirection URI indeterminators" section, click the "Add URI" button and enter the address "http://localhost:3000/users/auth/google_oauth2/callback" there, confirm by clicking the "Create" button.
10. You will see a popup with a confirmation that "OAuth client has been created" and with login data. You will need them in the project configuration so save them, you can use the "Download JSON" option.
11. In the config/configuration.yml fill in your credentials : google client id and google client secret. For the format checkout config/confiugration.yml.example