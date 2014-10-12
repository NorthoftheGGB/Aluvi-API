module UsersHelper
  def driver_state
    unless self.driver_state.nil?
      self.driver_state
    else
      'no state'
    end
  end

  def driver_state=(state_change)
    self.driver_state = state_change
  end

end
