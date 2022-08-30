# require statement for global requirements
require File.join(File.dirname(__FILE__), 'main.rb' )

time1 = Time.new

@log = File.new(LOG_PATH, "w")
@log.puts "Begin migration at " + time1.inspect + "\n\n"

#get all the templates ready
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

@migrated_files_arr = Array.new
@migrated_files_arr_index = 0

@missing_pages_arr = Array.new
@missing_pages_arr_index = 0


#create log output directory if needed
if not File.directory?(PLUGINS_LOG_FOLDER_PATH)
  curr_path = ""
  if not OS.windows?
    curr_path = "/"
  end

  path_parts = (PLUGINS_LOG_FOLDER_PATH).scan(/[^\/]+/)
  # path_parts.pop if is_file_path
  path_parts.each do |part|
    curr_path += part + "/"
    if not File.directory?(curr_path)
      Dir.mkdir(curr_path)
    end
  end
  @log.puts "Created log directory path."
end

@wp_plugins_log = File.new(PLUGINS_LOG_FOLDER_PATH + "/wp_plugins.log", "w")
@wp_plugins_count_log = File.new(PLUGINS_LOG_FOLDER_PATH + "/wp_plugins_all_countsort.log", "w")
@wp_plugins_all_log = File.new(PLUGINS_LOG_FOLDER_PATH + "/wp_plugins_all_namesort.log", "w")
@wp_plugins = Hash.new
@wp_plugins_all = Array.new

#open wordpress source xml
if File.file?(WP_SOURCE_FILE)
  puts "Source xml exists: " + WP_SOURCE_FILE
  @log.puts "Source xml exists: " + WP_SOURCE_FILE

  File.open(WP_SOURCE_FILE, "r:utf-8") do |xml_file|

    # load source xml into nokogiri for easy access
    xml_doc = Nokogiri.XML(xml_file)

    migrate_xml(xml_doc)
  end
#go through all xml files in source directory
else
  #determine whether to use the source root or if a directory was given to pull xml source files from
  wp_source_directory = SOURCE_ROOT
  if File.directory?(WP_SOURCE_FILE)
    wp_source_directory = WP_SOURCE_FILE
  end

  puts "Source directory provided: " + wp_source_directory
  @log.puts "Source directory provided: " + wp_source_directory

  #file to hold aggregation of all wp xml source data
  @full_xml = File.new("#{PROJECT_ROOT}/_full.xml", "w")

  first_xml = true
  full_xml_doc = Nokogiri.XML("<rss><channel></channel></rss>") #initialize full_xml_doc with dummy data

  #open wordpress source xmls
  Dir.glob("#{wp_source_directory}/**/**.xml") do |filepath|

    if File.file?(filepath)
      puts "Source xml exists: " + filepath
      @log.puts "Source xml exists: " + filepath

      File.open(filepath, "r:utf-8") do |xml_file|
        if first_xml == true
          puts "first xml"
          @log.puts "first xml"

          first_xml = false
          full_xml_doc = Nokogiri.XML(xml_file) #load as initial full xml
        else
          puts "append to first xml"
          @log.puts "append to first xml"

          #append current items to full xml
          xml_items = Nokogiri.XML(xml_file).search('item')
          full_xml_doc.at('channel').add_child(xml_items)
        end
      end
    end

  end

  @full_xml.puts full_xml_doc.to_s #keep record of merged source xml for reference

  puts "All xml in source directory merged, now migrate the items."
  @log.puts "All xml in source directory merged, now migrate the items."

  #migrate from the full xml
  migrate_xml(full_xml_doc)

end




#remove duplicate elements and then write the full list of plugins to log file
puts "\nWrite full plugins list to log"
@log.puts "\nWrite full plugins list to log"

#create hash to store plugin frequency count
@wp_plugins_all_count = Hash.new(0)
#calculate and record the count for each plugin identified in @wp_plugins_all
@wp_plugins_all.each do |p|
  @wp_plugins_all_count[p] += 1
end
#sort the plugin list by count and output the info to the log file
@wp_plugins_all_count.sort{|a,b| a[1]<=>b[1]}.reverse.each { |elem|
  @wp_plugins_count_log.puts "#{elem[0]} (#{elem[1]})"
  # puts "#{elem[1]}, #{elem[0]}"
}
#sort the plugin list by name and output the info to the log file
@wp_plugins_all_count.sort{|a,b| a[0]<=>b[0]}.each { |elem|
  @wp_plugins_all_log.puts "#{elem[0]} (#{elem[1]})"
}

#add sidenav files to directories that need them
puts "Adding additional sidenav files as needed..."
@log.puts "\n\nAdding additional sidenav as needed..."
Dir.glob("#{OUTPUT_ROOT}/**/**") do |filepath|
  if File.directory?(filepath) #check if in a directory
    sidenav_path = filepath + NAV_FILENAME
    
    #add new sidenav files if needed
    if not File.file?(sidenav_path)
      blank_data = {"content" => NAV_TAG}
      @blank_file_puncher.punch_file(sidenav_path, blank_data) #add sidenav
      
      puts "Wrote new sidenav file at: #{sidenav_path}"
      @log.puts "Wrote new sidenav file at: #{sidenav_path}"
    end
  end
end
puts "Done adding additional sidenav files.\n\n"
@log.puts "Done adding additional sidenav files.\n\n"

#add other files to directories that need them
puts "Adding other additional files as needed..."
@log.puts "\n\nAdding other additional files as needed..."
Dir.glob("#{OUTPUT_ROOT}/**/**") do |filepath|
  if File.directory?(filepath) #check if in a directory
    index_path = filepath + '/' + INDEX_NAME + ".pcf"
    props_path = filepath + PROPS_FILENAME
    
    #add new index/default pages if needed
    if not File.file?(index_path)
      title = capitalize_words(index_path.rpartition('/')[0].rpartition('/')[2].gsub(/[-_]/, ' '))
      main_content = "<p>This is an automatically generated #{INDEX_NAME} file.</p>"
      doc_data = {
        "extension" => OUTPUT_EXTENSION.partition(".")[2], 
        "title" => title, 
        "description" => "", 
        "main_content" => main_content
      }
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
puts "Done adding other additional files.\n\n"
@log.puts "Done adding other additional files.\n\n"

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

