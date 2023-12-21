#########################################################
################# CUSTOM EXCEPTIONS #####################
#########################################################
class CustomExceptions < StandardError

  # ============== User Format and Authentication - Exceptions =============
  class InvalidUser < StandardError
    class Unknown < StandardError # Should be risen when there is no record in users for a given id
    end

    class CredentialsWrong < StandardError # User credentials not correct -> Authentication failed
    end

    class LoggedOut < StandardError # (NON-API-ONLY) Current.user is nil (= session token expired)
    end

    class Inactive < StandardError # Current.user is deactivated (activity_status = 0)
    end

  end

  # ============== User Authorization - Exceptions =============
  class Unauthorized < StandardError

    class NotOwner < StandardError # Current.user is not owner of resource that he is trying to access
    end

    class InsufficientRole < StandardError # User does not have the required role to access the resource
      # TODO: Subklassen können je nach dem wie genau die Error message sein soll auch weggelassen werden
      class NotAdmin < StandardError # User does not have the 'admin' role
      end

      class NotEditor < StandardError # User does not have the 'admin' role
      end

      class NotDeveloper < StandardError # User does not have the 'developer' role
      end

      class NotModerator < StandardError # User does not have the 'moderator' role
      end

      class NotVerified < StandardError # User is not 'verified' yet
      end

    end

    class Blocked < StandardError # User is blacklisted
    end
  end

  # ============== JWT-Token - Exceptions =============
  class InvalidInput < StandardError
    class Token < StandardError # Invalid token?
    end

    class SUB < StandardError # Token has wrong format?
    end

    class CustomEXP < StandardError # Token expired?
    end

    class BlankCredentials < StandardError # Blank email || password
    end

    class GeniusQuery < StandardError # Invalid token?
      class Blank < StandardError
      end

      class Malformed < StandardError
      end
    end

    class Quicklink < StandardError
      class Client < StandardError # Invalid token?
        class Blank < StandardError
        end

        class Malformed < StandardError
        end
      end

      class Request < StandardError # Invalid token?
        class Blank < StandardError
        end

        class Malformed < StandardError
        end
      end

    end
  end

  # ============== Job - Exceptions =============
  class InvalidJob < StandardError
    class Unknown < StandardError # Should be risen when there is no record in jobs for a given job_id
    end
  end

  # ============== Subscription - Exceptions =============
  class Subscription < StandardError
    class ExpiredOrMissing < StandardError # Subscription is either expired or not existent
    end
  end
end
