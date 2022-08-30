# require statement for global requirements
require File.join(File.dirname(__FILE__), 'main.rb' )

time1 = Time.new

@log = File.new(LOG_PATH, "w")
@log.puts "Begin migration map generation at " + time1.inspect + "\n\n"


#given a wordpress xml source file, this method will loop through each <item> and append each link to the migration map
def process_csv_for_map(xml_path)
  #open wordpress source xml
  if File.file?(xml_path)
    puts "Source xml exists: " + xml_path
    @log.puts "Source xml exists: " + xml_path

    File.open(xml_path, "r:utf-8") do |xml_file|

      # load source xml into nokogiri for easy access
      xml_doc = Nokogiri.XML(xml_file)
      # xml_doc = Nokogiri.XML(xml_doc.to_s.encode("UTF-8"))

      #loop through each item in the source and process it
      xml_doc.xpath("//rss/channel/item").each do |item|
        puts "\nNow processing " + item.xpath("./link/text()").to_s
        @log.puts "\nNow processing " + item.xpath("./link/text()").to_s

        item_type = item.xpath("./wp:post_type/node()").text
        puts "\titem type: " + item_type
        @log.puts "\titem type: " + item_type

        if item_type == "page" || item_type == "post"

          #define and set the output paths
          orig_path = item.xpath("./link/text()").to_s

          #remove special characters from path
          rr_output_file_path = orig_path.gsub(/[\!\#\$\%\^\&\*\(\)\[\]\?\’\”\|<>{};:,\+\=]/, "") 
          
          #update links that end in / to be the index page of a section
          if rr_output_file_path[-1] == '/' 
            rr_output_file_path = rr_output_file_path + INDEX_NAME
          end

          #add .pcf extension to pages
          if not(rr_output_file_path.end_with? ".pcf")
            rr_output_file_path = rr_output_file_path + ".pcf"
          end

          #get page title for reference
          title = item.xpath("./title/text()").to_s

          #write info to the migration map
          @migration_map.puts orig_path + "," + rr_output_file_path + ",\"" + title + "\""
          
          puts "\tItem written to migration map."
          @log.puts "\tItem written to migration map."
        end
      end

    end
  end
end


#generate map based on MIGRATION_MAP_PATH value
if (MIGRATION_MAP_PATH == "")
  puts "MIGRATION_MAP_PATH not defined! Please set a value in the config.rb file and try again."
  @log.puts "MIGRATION_MAP_PATH not defined! Please set a value in the config.rb file and try again."
else
  puts "MIGRATION_MAP_PATH set to: " + MIGRATION_MAP_PATH + "... creating map."
  @log.puts "MIGRATION_MAP_PATH set to: " + MIGRATION_MAP_PATH + "... creating map."

  #create migration map output directory if needed
  @dir_maker = DirMaker.new(OUTPUT_ROOT, @log)
  create_directory(MIGRATION_MAP_PATH)

  @migration_map = File.new(MIGRATION_MAP_PATH, "w")
  @migration_map.puts "Old Location,New Location,Page Title"

  #if a single WP_SOURCE_FILE is defined, process it only
  if File.file? WP_SOURCE_FILE
    puts "Processing single WordPress xml source file."
    @log.puts "Processing single WordPress xml source file."

    process_csv_for_map(WP_SOURCE_FILE)

  #WP_SOURCE_FILE defined as directory, so process all .xml files in the defined directory
  elsif (File.directory? WP_SOURCE_FILE)
    puts "Processing all WordPress xml source files in: " + WP_SOURCE_FILE
    @log.puts "Processing all WordPress xml source files in: " + WP_SOURCE_FILE

    Dir.glob("#{WP_SOURCE_FILE}/**/**.xml") do |filepath|
      process_csv_for_map(filepath)
    end

  #WP_SOURCE_FILE is blank, so process all .xml files in the SOURCE_ROOT directory
  elsif (WP_SOURCE_FILE == "")
    puts "Processing all WordPress xml source files in: " + SOURCE_ROOT
    @log.puts "Processing all WordPress xml source files in: " + SOURCE_ROOT

    Dir.glob("#{SOURCE_ROOT}/**/**.xml") do |filepath|
      process_csv_for_map(filepath)
    end

  else
    puts "WP_SOURCE_FILE not found, map content not populated."
    @log.puts "WP_SOURCE_FILE not found, map content not populated."
  end
end


@log.puts "\nMigration map generation finished at " + time1.inspect
@log.close

puts "\nFinished"

