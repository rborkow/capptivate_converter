#!/usr/bin/env ruby

#Convert existing videos to compressed format and gracefully replace existing video

require 'find'
require 'rubygems'
require 'streamio-ffmpeg'
require 'csv'

$conversionInfo = Array.new

$options = "-c:v libx264 -profile:v main -level 4.0 -preset veryfast -crf 22 -an"

baseDir = Dir.pwd
level1Dirs =  Dir.entries(baseDir).select {|entry| File.directory? File.join(baseDir,entry) and !(entry =='.' || entry == '..') }

###Functions###
def transcode(movie)
  theMovie = FFMPEG::Movie.new(movie)
  out = theMovie.transcode("out.mov", $options) { |progress| puts progress }
  
  info = [movie, theMovie.size, out.size]
  $conversionInfo.push(info)
end

def swap_videos(movie)
  #NB: File.rename will not work across partitions or devices.
  
  #1. Move the original video out of the way to a predictable location.
  File.rename(movie, "original.mov")
  
  #2. Move the new video into position of the original video
  File.rename("out.mov", movie)
end

###Main Loop###
if __FILE__==$0 
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
         puts "Video path: #{f}" if f.match(/\.mov\Z/)
         movie_file = f if f.match(/\.mov\Z/)
       
         transcode(movie_file) if f.match(/\.mov\Z/)
         swap_videos(movie_file) if f.match(/\.mov\Z/)
       
         movie_destination = File.join(path, "video.mov")

      end

    else
      Find.find(path) do |f|
        puts "Video path: #{f}" if f.match(/\.mov\Z/)
        movie_file = f if f.match(/\.mov\Z/)
       
        transcode(movie_file) if f.match(/\.mov\Z/)
        swap_videos(movie_file) if f.match(/\.mov\Z/)
      end
    end
  end

  ###Write stats to file###
  
  CSV.open("stats.csv", "w") do |csv|
    $conversionInfo.each do |row|
      csv << row
    end
  end
end
