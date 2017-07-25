class ScanFilesystem

  DEFAULT_OPTIONS = { }

  attr_reader :basepath, :options
  attr_accessor :filesystem, :exclusions

  Results = Struct.new(:filesystem, :exclusions)

  # @param basepath [String] the filesystem directory path to scan
  # @param options [Hash] the options to use in scanning
  #   exclude [Array<String>] directory entries to ignore while scanning
  def initialize(basepath, options={})
    @basepath = basepath
    @filesystem = Filesystem.new(basepath)
    @options = DEFAULT_OPTIONS.merge(options)
    @exclusions = []
  end

  # @return [Hash] a representation of the relevant portions of the filesystem
  def call
    scan_files(basepath, filesystem.root)
    Results.new(filesystem, exclusions)
  end

  private

  def scan_files(dirpath, node)
    Dir.foreach(dirpath).each do |entry|
      next if ['.', '..'].include?(entry)
      if included?(dirpath, entry)
        handle_entry(dirpath, node, entry)
      else
        exclusions << File.join(dirpath, entry)
      end
    end
  end

  def included?(dirpath, entry)
    if exclude.include?(entry)
      false
    elsif File.directory?(File.join(dirpath, entry))
      true
    elsif include.present?
      include.include?(File.extname(entry)) ? true : false
    else
      true
    end
  end

  def handle_entry(dirpath, node, entry)
    child_node = Tree::TreeNode.new(entry)
    child_node.content = {}
    node << child_node
    entry_path = File.join(dirpath, entry)
    handle_directory(entry_path, child_node) if File.directory?(entry_path)
  end

  def handle_directory(dirpath, node)
    scan_files(dirpath, node)
    # Remove directories that contain no files or only excluded files
    unless node.has_children?
      node.remove_from_parent!
      exclusions << dirpath
    end
  end

  def exclude
    options.fetch(:exclude, [])
  end

  def include
    options.fetch(:include, [])
  end

end
