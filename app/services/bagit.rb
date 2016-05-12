class Bagit
  def self.call(dir)
    `#{DulHydra.python}/bin/bagit.py #{dir}`
  end
end
