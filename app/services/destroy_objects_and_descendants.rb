class DestroyObjectsAndDescendants
  def self.call(pids)
    pids.each do |pid|
      obj = ActiveFedora::Base.find(pid)
      if obj.respond_to?(:child_ids)
        call(obj.child_ids)
      end
      obj.destroy
      puts "#{obj.model_pid} destroyed."
    end
  end
end
