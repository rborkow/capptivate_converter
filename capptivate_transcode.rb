#Convert existing videos to compressed format and gracefully replace existing video

require 'find'
require 'rubygems'
require 'streamio-ffmpeg'

baseDir = Dir.pwd
level1Dirs =  Dir.entries(baseDir).select {|entry| File.directory? File.join(baseDir,entry) and !(entry =='.' || entry == '..') }

level1Dirs.each do |i|
  #Reset to Base Directory, init variables
  Dir.chdir(baseDir)
  movie_file = ""
  movie_destination = ""

  #Get path and search terms ready
  path = File.join(baseDir, i)
  hypeFolderName = i + ".hyperesources"

  #Move to the post directory
  Dir.chdir(path)
  puts path
  
  if File.directory?(hypeFolderName)
    hypePath = File.join(path, hypeFolderName)

    puts hypePath
    Find.find(hypePath) do |f|
       puts f if f.match(/\.mov\Z/)
       movie_file = f if f.match(/\.mov\Z/)
       
       transcode(movie_file)
       
       movie_destination = File.join(path, "video.mov")

    end
    File.symlink(movie_file, movie_destination) if !(File.symlink?(movie_destination))

  else
    Find.find(path) do |f|
      puts f if f.match(/\.mov\Z/)
       movie_file = f if f.match(/\.mov\Z/)
       
       transcode(movie_file)

       movie_destination = File.join(path, "video.mov")

    end
    File.symlink(movie_file, movie_destination) if !(File.symlink?(movie_destination))
  end
  
  def transcode(movie)
    movie = FFMPEG::Movie.new(movie)
    movie.transcode("out.mov") { |progress| puts progress }
    out = FFMPEG::Movie.new("out.mov")    
  end

end