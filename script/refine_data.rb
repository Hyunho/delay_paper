#! /bin/ruby

# this scripte for refining data set
# original data is not complete. Then when we do test., some error may appear. 
# So, I decide to refine a data.

file = File.open("../resource/origin_data.txt")
Dir.chdir("..")

Dir.mkdir("temp") unless File.directory?("temp")
Dir.chdir("temp")
file_pointers = Hash.new

begin

  while line = file.readline


    moteid = line.split[3];

    if moteid != nil || moteid.to_i < 54

      if file_pointers[moteid] == nil
        file_pointers[moteid] = File.open(moteid + ".txt","w")
      end

      file_pointers[moteid].write(line)
    else
    end
  end
rescue EOFError

  file_pointers.values.each {|pointer| pointer.close}
  file.close

end

