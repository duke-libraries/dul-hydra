require "tempfile"
require "digest"
require "fileutils"
require "net/http"

namespace :dul_hydra do
  namespace :tika do
    version = "1.12"
    desc "Download Tika #{version}."
    task :download => :environment do
      filename = "tika-app-#{version}.jar"
      dest = File.dirname(TextExtraction.tika_path)
      target = File.join(dest, filename)
      jar_url = URI("http://archive.apache.org/dist/tika/#{filename}")
      sha1_url = URI("http://archive.apache.org/dist/tika/#{filename}.sha1")

      if File.exist?(target)
        puts "Tika #{version} already downloaded to #{target}."
        exit
      end
      Dir.mktmpdir do |tmpdir|
        FileUtils.cd(tmpdir) do
          File.open(filename, "wb") do |f|
            Net::HTTP.start(jar_url.host) do |http|
              puts "Downloading Tika ..."
              http.request_get(jar_url.path) do |res|
                res.read_body do |chunk|
                  f.write(chunk)
                end
              end
            end # http
            f.close
          end # file
          sha1_file = Net::HTTP.get(sha1_url)
          sha1 = sha1_file.chomp.split(/\s+/).last
          if Digest::SHA1.file(filename).hexdigest != sha1
            raise "SHA1 of downloaded file does not match #{sha1}."
          end
          FileUtils.mkdir_p(dest)
          FileUtils.mv(filename, dest)
        end # cd
      end # dir
      puts "Tika #{version} downloaded to #{target}."
      FileUtils.cd(dest) do
        link = File.basename(TextExtraction.tika_path)
        FileUtils.remove_entry_secure(link) if File.exist?(link)
        begin
          File.symlink(filename, link)
          puts "Symlink created at #{File.absolute_path(link)}."
        rescue NotImplementedError
          FileUtils.cp(filename, link)
          puts "Tika #{version} copied to #{File.absolute_path(link)}."
        end
      end
    end
  end
end
