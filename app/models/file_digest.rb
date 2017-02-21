require 'digest'

class FileDigest < ActiveRecord::Base

  class_attribute :algorithms
  self.algorithms = %w( md5 sha1 ).freeze

  module Algorithms
    FileDigest.algorithms.each do |algo|
      define_method "generate_#{algo}" do |file_path|
        algo_class = Digest.const_get(algo.upcase)
        algo_class.file(file_path).hexdigest
      end
    end
  end

  extend Algorithms
  include Algorithms

  validates_presence_of :repo_id, :file_id

  def set_digests(file_path)
    algorithms.each { |algo| set_digest(algo, file_path) }
  end

  def set_digest(algorithm, file_path)
    write_attribute algorithm, send("generate_#{algorithm}", file_path)
  end

  def digests_changed?
    (changed & algorithms).any?
  end

end
