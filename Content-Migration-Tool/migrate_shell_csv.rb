# require statement for global requirements
require File.join(File.dirname(__FILE__), 'main.rb' )

time1 = Time.new

@log = File.new(LOG_PATH, "w")
@log.puts "Begin migration at " + time1.inspect + "\n\n"

#get all the templates ready
@tmpl_home = ERB.new(File.read(TMPL_PATH_HOME))
@log.puts "Got template at #{TMPL_PATH_HOME}.\n\n"
@fp_home = FilePuncher.new(@tmpl_home, @log)

@tmpl_interior = ERB.new(File.read(TMPL_PATH_INTERIOR))
@log.puts "Got template at #{TMPL_PATH_INTERIOR}.\n\n"
@fp_interior = FilePuncher.new(@tmpl_interior, @log)

@tmpl_blank = ERB.new(File.read(TMPL_PATH_BLANK))
@log.puts "Got nav template at #{TMPL_PATH_BLANK}.\n\n"
@blank_file_puncher = FilePuncher.new(@tmpl_blank, @log)
#end get all the templates ready

@dir_maker = DirMaker.new(OUTPUT_ROOT, @log)
@sidenav_file_maker = SidenavFileMaker.new(OUTPUT_ROOT, @log)
@props_file_maker = PropertiesFileMaker.new(OUTPUT_ROOT, @log)

#start the process
process_csv_shell_row(CSV_PATH_SHELL)

#add extra files to directories that need them
puts "Adding additional files as needed..."
@log.puts "\n\nAdding additional files as needed..."
Dir.glob("#{OUTPUT_ROOT}/**/**") do |filepath|
  if File.directory?(filepath) #check if in a directory
    sidenav_path = filepath + NAV_FILENAME
    index_path = filepath + '/' + INDEX_NAME + ".pcf"
    props_path = filepath + PROPS_FILENAME
    
    #add new sidenav files if needed
    if not File.file?(sidenav_path)
      blank_data = {"content" => NAV_TAG}
      @blank_file_puncher.punch_file(sidenav_path, blank_data) #add sidenav
      
      puts "Wrote new sidenav file at: #{sidenav_path}"
      @log.puts "Wrote new sidenav file at: #{sidenav_path}"
    end
    
    #add new index/default pages if needed
    if not File.file?(index_path)
      title = capitalize_words(index_path.rpartition('/')[0].rpartition('/')[2].gsub(/[-_]/, ' '))
      content = "<p>This is an automatically generated #{INDEX_NAME} file.</p>"
      doc_data = {"title" => title, "content" => content}
      @fp_interior.punch_file(index_path, doc_data)
      
      puts "Wrote new #{INDEX_NAME} file at: #{index_path}"
      @log.puts "Wrote new #{INDEX_NAME} file at: #{index_path}"
      
      #add link to nav
      @sidenav_file_maker.write_link(index_path.sub(OUTPUT_ROOT, "").sub(".pcf", OUTPUT_EXTENSION), title)
    end
    
    #add new props files if needed
    if not File.file?(props_path)
      title = capitalize_words(props_path.rpartition('/')[0].rpartition('/')[2].gsub(/[-_]/, ' '))
      @props_file_maker.write(props_path, title, false)
    end
    
  end
end
puts "Done adding additional files.\n\n"
@log.puts "Done adding additional files.\n\n"

#sort nav files
puts "Sorting nav files..."
@log.puts "Sorting nav files..."
Dir.glob("#{OUTPUT_ROOT}/**/*_sidenav.inc") do |filepath|
  # puts "Now processing #{filepath}"
  @log.puts "Now processing #{filepath}"
  
  sort_nav(filepath)
end
puts "Done sorting nav files.\n\n"
@log.puts "Done sorting nav files.\n\n"

@log.puts "\nMigration finished at " + time1.inspect
@log.close

puts "\nFinished"

