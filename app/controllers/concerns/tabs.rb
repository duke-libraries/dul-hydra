class Tabs < ActiveSupport::OrderedHash

  attr_reader :active_tab

  def initialize(controller)
    super()
    @active_tab = controller.params[:tab]
    controller.tabs.each {|m| self << controller.send(m)} if controller.tabs.present?
  end

  def << (tab)
    self[tab.id] = tab if tab.guard
  end

  def active
    active_tab && self.key?(active_tab) ? self[active_tab] : self.default
  end

  def default?(tab)
    self.default ? tab.id == self.default.id : false
  end

  def default
    self.first[1] unless self.empty?
  end

end
