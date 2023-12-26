<!--
# @title Inpay Technical Challenge
-->
# Inpay Technical Challenge documentation

## How the documentation is organized

* [Planning](docs/planning/README.md) contains initial plan for developing this app.
* [Possible cases and exceptions](docs/scenarios/README.md) cases and exceptions that could happen within workflow of the application
* [Tutorials](docs/tutorials/README.md) take you by the hand through a series of steps to run the app locally. Start here if you’re new to the project.
* [Reference guides](docs/references/README.md) contain description of Classes from this application.

To browse the documentation run `yard server` and open it in a [browser](//localhost:8808).

## Setup 

[Here](docs/tutorials/README.md) you have access to a step-by-step tutorial that will guide you through the process of setting up this application locally.

## Application Logic from User perespective

Brief explanation on how the app works from user pespective.

## Initial Access and Login
- Upon opening the application at `localhost:3000`, you will be prompted to log in using Google. Note that this application exclusively supports Google authentication.
- After logging in, you will land on the email index page.
## Navigating the Index Page
On the index page, you will find four options:

- Sync All Emails: Downloads all emails from your Gmail inbox. This process might take approximately 7-10 minutes, depending on the volume of emails.
- Sync Emails by Date Range: Allows you to download emails from a specified start date to an end date. You will need to enter these dates in the provided form. The dates are treated as exclusive.
- Dashboard: It will take you to the dasbhoard page
- Logout: Logs you out of the application.

## Syncing Emails
When you click on either "Sync All Emails" or "Sync Emails by Date Range", you will be redirected to a page displaying "Downloading..." This indicates that your emails are being synchronized.
Once the download is complete, you will automatically be redirected to the dashboard.
## Dashboard Features
The dashboard provides several functionalities:

- Count Emails: This feature presents a form where you can enter a date and/or an email sender. Based on your input, it will display the count of emails received on that date, from that sender, or both.
- List Subjects: Here, you can see a form to enter a date. Upon submission, it will show you a list of all email subjects from emails received on the specified date.
- Email Stats: This section displays the sender and the count of emails you have received from them, based on the emails you have synced so far.
- Logout: Use this option to log out of the application.
- Back to Downloads: Clicking this will redirect you back to the index page for more email syncing options.
