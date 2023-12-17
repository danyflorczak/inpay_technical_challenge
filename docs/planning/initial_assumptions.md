# Assumptions

- I will develop basic UI (it was specified that for tools i should use chrome so to simplify walk through the app)
- I will use PostgreSQL
- Authentication with Google OAuth 2.0: For secure user login and access to Gmail data.
- Download All Emails Initially: To have a comprehensive dataset in the DB, allowing for complex queries without repeated API calls. (adjustment): Date Range Download Implementation: To enhance efficiency by fetching emails within a specified range.
- Implement Error Handling and Token Refresh Functionality: To manage API access issues and maintain continuous operation.
- I will use google_api_client because, gmail gem is deprecated
- I will use ransack for search feature instead of elasticsearch beacuse it is pretty simple search and using elasticsearch would be a exaggerated