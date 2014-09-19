class MintedId < ActiveRecord::Base

  validates_presence_of :minted_id
  validates_uniqueness_of :minted_id

end