#!/usr/bin/env ruby

Dir.entries("jobs/").each do |filename|
  next if not File.file? "jobs/"+filename
  data = File.open("jobs/"+filename).read
  next if not start=data.index(/Remote sauce test.*started/)
  next if not fin=data.index(/Remote sauce test.*finished/)

  data=data[start..-1]

  errors = []
  state = "skip"
  error = ""
  indent = 0

  data.split("\n").each do |line|
    next if line.match(/Remote sauce test/)

    if line.match(/FINISHED|^$/)
      if error != ""
        errors.push error
        error = ""
      end
      state = "skip"
      next
    end

    if not line.match(/PENDING|PASSED|FAILED/) and (state == "skip")
      next
    end

    if line.match(/PASSED|PENDING/)
      if error != ""
        errors.push error
        error = ""
      end
      state = "skip"
      next
    end

    if line.match(/FAILED/)
      if error != ""
        errors.push error
        error = ""
      end
      if m=line.match(/^\[[^\]]+\](\s+)/)
        indent = m[1].size
      end
      line.gsub!(/^\[[^\]]+\]\s+-> FAILED : /,"")
      state = "fail"
      error = line
      next
    end

    if state == "fail"
      if m=line.match(/^\[[^\]]+\](\s+)/) and m[1].size < indent
        state = "skip"
        indent = 0
        next
      end
      line.gsub!(/^\[[^\]]+\]\s+/,"")
      error += line.strip
      next
    end

  end

  errors.map! do |e|
    e if not e.match(/Pad never loaded|Padnever loaded|Pad neverloaded/) # a space is somewhere lost in this script
  end

  # skip if more than 10 errors are in a file
  next if errors.size > 10

  if errors.size > 0
    File.open("failed/#{filename}","w") do |f|
      f.write errors.join("\n")
      f.write "\n"
    end
  end


end
