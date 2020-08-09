#!/usr/bin/env ruby

Dir.entries("jobs/").each do |filename|
  next if not File.file? "jobs/"+filename
  data = File.open("jobs/"+filename).read

  #intended to skip totally broken builds
  next if not start=data.index(/Remote sauce test.*started/)
  next if not data.index(/Remote sauce test.*finished/)
  next if data.index(/The build has been terminated/)
  next if data.index(/no test started since/)

  data=data[start..-1]

  @errors = []
  state = "skip"
  @error = ""
  indent = 0

  def push_error
    if @error != ""
      @errors.push @error
      @error = ""
    end
  end

  data.split("\n").each do |line|

    if line.match(/Remote sauce test|FINISHED|^\s+?$|PASSED|PENDING/)
      push_error
      state = "skip"
      next
    end

    #special case error, it has no prepended "FAILED"
    if line.match(/allowed test duration exceeded/)
      push_error
      @error = "allowed test duration exceeded"

      state = "skip"
      next
    end

    # multiline output of a non-failing test
    if not line.match(/PENDING|PASSED|FAILED/) and state == "skip"
      next
    end


    # a failed test
    if line.match(/FAILED/)
      push_error
      # save the indention level to detect multiline test descriptions
      if m=line.match(/^\[[^\]]+\](\s+)/)
        indent = m[1].size
      end
      line.gsub!(/^\[[^\]]+\]\s+-> FAILED : /,"")
      state = "fail"
      @error = line
      next
    end

    if state == "fail"
      # a new suite
      if m=line.match(/^\[[^\]]+\](\s+)/) and m[1].size < indent
        state = "skip"
        indent = 0
        next
      end
      # multiline test description
      line.gsub!(/^\[[^\]]+\]\s+/,"")
      @error += line.strip
    end
  end


  # skip known errors
  @errors.map! do |e|
    e if not e.match(/Pad never loaded|Padnever loaded|Pad neverloaded/) # a space is somewhere lost in this script
  end.compact!

  # skip if more than 10 errors are in a file
  next if @errors.size > 10

  if @errors.size > 0
    File.open("failed/#{filename}","w") do |f|
      f.write @errors.join("\n")
      f.write "\n"
    end
  end


end
