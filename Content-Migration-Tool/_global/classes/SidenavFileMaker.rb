class SidenavFileMaker
  def initialize(base_path, log_file)
    @base_path = base_path
    @log = log_file
  end

  def write_link_to_file(nav_file_path)
    #create new sidenav file if it doesn't already exist
    if not File.exists?(nav_file_path)
      @log.puts "Creating new nav file at #{nav_file_path}"
    end
    File.open(nav_file_path, "a+") do |nav_file|
    #add the editor tag if the file is empty
      if nav_file.size == 0
        nav_file.puts NAV_TAG
      end
      #write the link to the file
      nav_file.puts "<li><a href=\"#{@rr_path}\">#{@title}</a></li>"
      puts "Wrote link for #{@rr_path} to nav file at #{nav_file_path}"
      @log.puts "Wrote link for #{@rr_path} to nav file at #{nav_file_path}"
    end
  end

  def write_link(rr_path, title)
    @rr_path = rr_path
    @title = title
    path_parts = rr_path.rpartition('/')
    nav_file_path = @base_path + path_parts[0] + NAV_FILENAME
    
    #if it's an index page, write to the parent sidenav file
    if path_parts[2].match(/index\.\w+$/)
      if path_parts[0].size > 0
        nav_file_path = @base_path + path_parts[0].rpartition('/')[0] + NAV_FILENAME
        write_link_to_file(nav_file_path)
      else
        @log.puts "At the top level: not writing to navigation!"
      end
    else
      #it's not an index page, write to the local sidenav file
      write_link_to_file(nav_file_path)
    end
  end

end