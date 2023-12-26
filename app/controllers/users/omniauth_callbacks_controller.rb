# The Users::OmniauthCallbacksController is a Devise controller that handles
# the OmniAuth callbacks for third-party authentication. Specifically, this
# controller handles the callback from Google OAuth2 authentication.
#
# This controller inherits from Devise's OmniauthCallbacksController and
# overrides the `google_oauth2` method to provide custom handling of the
# authentication callback from Google.
#
# @see Devise::OmniauthCallbacksController
#
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Callback method for Google OAuth2 authentication.
  # It is called after successful authentication with Google.
  # If the user is persisted successfully in the database (i.e., either found
  # or created), they are redirected to their signed-in home page.
  # If there is an error (e.g., the user could not be created), they are
  # redirected to the sign-in page with an error message.
  #
  # @note This method sets a flash notice on successful authentication and
  #       a flash alert on failure.
  #
  def google_oauth2
    # Retrieves or creates the user based on the OmniAuth auth hash.
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      # Sets a flash message and redirects to the user's home page upon successful sign-in.
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
      sign_in_and_redirect @user, event: :authentication
    else
      # Stores the OmniAuth data in the session (excluding extra data)
      # and redirects to the sign-in page with an error message.
      session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_session_path, alert: @user.errors.full_messages.join("\n")
    end
  end
end
