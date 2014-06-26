class Tab

  attr_reader :id, :href, :guard, :actions

  def initialize(id, opts={})
    @id = id
    @href = opts[:href]
    @guard = opts.fetch(:guard, true)
    @actions = opts.fetch(:actions, [])
  end

  def authorized_actions
    @authorized_actions ||= actions.select {|a| a.guard}
  end

  def css_id
    "tab_#{id}"
  end

  def partial
    href ? 'tab_ajax_content': id
  end

  def label
    I18n.t("dul_hydra.tabs.#{id}.label")
  end

end
