require "fedora-migrate"

FedoraMigrate::TargetConstructor.class_eval do
  def build
    target.new
  end
end
