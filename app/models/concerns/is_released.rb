require 'active_support'

# Adds functionality for releasing material to students at a specific date.
module IsReleased
  extend ActiveSupport::Concern

  included do
    # The default time when this object will be released to students.
    validates :released_at, timeliness: { type: :datetime, allow_nil: true }

    # Nullify :released_at if the author did not decide a release date.
    def act_on_reset_released_at
      if @reset_released_at
        self.released_at = nil
        @reset_released_at = nil
      end
    end
    private :act_on_reset_released_at
    before_validation :act_on_reset_released_at
  end

  class_methods do
    # The generic default value of :released_at.
    def default_released_at
      Time.current.beginning_of_hour
    end
  end

  # True if the release date was omitted (reset to nil) (virtual attribute).
  def reset_released_at
    released_at.nil?
  end

  # Store the user's decision to set or omit (reset) the release date.
  #
  # @param [String] state '0' if setting a date, '1' if omitting
  def reset_released_at=(state)
    @reset_released_at = ActiveRecord::Type::Boolean.new.cast(state)
  end

  # The release date, with default values if there isn't one.
  def released_at_with_default
    released_at || default_released_at
  end
end
