#! /bin/ruby

# this scripte for refining data set
# original data is not complete. Then when we do test., some error may appear. 
# So, I decide to refine a data.

file = File.open("../resource/origin_data.txt")
Dir.chdir("..")

Dir.mkdir("temp") unless File.directory?("temp")
Dir.chdir("temp")
file_pointers = Hash.new
garbage_file = File.open("garbage.txt","w")
begin

  while line = file.readline

    #    data = {:date => words[0], :time => words[1], :epoch => words[2], :moteid => words[3], :temperature => words[4], :humidity => words[5], :light => words[6], :voltage => words[7]}
    moteid = line.split[3];

    if moteid == nil || moteid.to_i > 54
      garbage_file.write(line)

    else

      if file_pointers[moteid] == nil
        file_pointers[moteid] = File.open(moteid + ".txt","w")
      end
      file_pointers[moteid].write(line)
    end


      
      
    
  end
rescue EOFError

  file_pointers.values.each {|pointer| pointer.close}
  garbage_file.close
  file.close
end

