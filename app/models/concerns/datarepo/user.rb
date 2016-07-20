module Datarepo::User
  extend ActiveSupport::Concern

  module ClassMethods
    def audituser
      User.find_by_user_key(audituser_key) || User.create!(Devise.authentication_keys.first => audituser_key, uid: audituser_key, provider: 'system')
    end

    def batchuser
      User.find_by_user_key(batchuser_key) || User.create!(Devise.authentication_keys.first => batchuser_key, uid: batchuser_key, provider: 'system')
    end
  end
end
