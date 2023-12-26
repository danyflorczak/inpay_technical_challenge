# The Users::SessionsController is a custom controller inheriting from
# Devise::SessionsController. It overrides Devise's default post sign-in and
# sign-out redirection behavior.
#
# This controller defines custom methods to determine the redirection path
# following a user's sign-in or sign-out, enhancing the user experience by
# redirecting users to appropriate paths within the application.
#
# @see Devise::SessionsController
#
class Users::SessionsController < Devise::SessionsController
  # Determines the path to redirect to after a user signs out.
  #
  # Overrides the default Devise behavior to redirect users to the sign-in
  # page immediately after signing out, rather than the application root or
  # any other page.
  #
  # @param _resource_or_scope [Object] The resource or scope which is signed out.
  # @return [String] The path for the new user session (sign-in page).
  #
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  # Determines the path to redirect to after a user signs in.
  #
  # Overrides the default Devise behavior to redirect users to the stored
  # location (if any) or the application root if no specific location was stored.
  # This can be useful for redirecting users back to the page they attempted to
  # access before signing in.
  #
  # @param resource_or_scope [Object] The resource or scope which has signed in.
  # @return [String] The path to redirect the user to after sign-in.
  #
  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end
end
