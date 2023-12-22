# Possible Cases and Exceptions

## Overview
This document outlines various scenarios, including successful operations and exceptions, that might occur while using the email information web service.

## Successful Path
- Successful Email Retrieval: User queries are successfully processed, and relevant email data is returned without any errors.
## Exceptions
### Authentication and Authorization
- AuthorizationError: Occurs when the user's access token is expired or invalid, requiring re-authentication.
### Rate Limiting
- RateLimitError: Triggered when the application exceeds the Google API's rate limits.
### Network and API Communication
- API Communication Error: Can occur due to network issues or problems with the Gmail API.
### Data Parsing and Storage
- Data Parsing Error: Arises if there's an issue in parsing email data received from the Gmail API.
- Database Storage Error: Occurs when saving email records to the database fails.
### User Interaction
- Invalid Date Format: When a user inputs an incorrect date format for querying emails.
- No Emails Found: If no emails are found for the specified query.
### Couldn't find User Error
- this error occured while testing (ActiveJob::DeserializationError: Error while trying to deserialize arguments: Couldn't find User): to handle that instead of passing `current_user` in `emails_controller` we pass `user_id` and inside `EmailSyncJob` we look for the `User` model and if there is no such user with passed id it will raise ActiveRecord::RecordNotFound error.
### Miscellaneous
- Unexpected Errors: General catch-all for unanticipated errors.