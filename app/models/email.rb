# The Email model represents an email record associated with a user.
# It stores information about individual emails, including the sender, subject,
# and date of the email. It belongs to a User model.
#
# @!attribute [r] sender
#   @return [String] The sender of the email.
# @!attribute [r] subject
#   @return [String] The subject of the email.
# @!attribute [r] email_date
#   @return [Date] The date when the email was sent.
# @!attribute [r] email_datetime
#   @return [DateTime] The date and time when the email was sent.
# @!attribute [r] user_id
#   @return [Integer] The ID of the user associated with this email.
#
class Email < ApplicationRecord
  # Association with the User model.
  belongs_to :user

  # Specifies the attributes that are searchable with Ransack.
  # @param auth_object [Object, nil] Optional authorization object.
  # @return [Array<String>] The list of attributes that can be searched.
  def self.ransackable_attributes(auth_object = nil)
    ["sender", "email_date", "user_id", "subject"]
  end

  # Specifies the associations that are searchable with Ransack.
  # @param auth_object [Object, nil] Optional authorization object.
  # @return [Array<String>] The list of associations that can be searched.
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
