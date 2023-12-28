class Email < ApplicationRecord
  belongs_to :user

  def self.ransackable_attributes(auth_object = nil)
    ["sender", "email_date", "user_id", "subject"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
