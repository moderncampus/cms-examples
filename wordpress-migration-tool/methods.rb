# migration specific methods

@char_log = File.new(CHAR_REPLACE_PATH, "w")

def update_plugin_references(path, content)
  new_content = content
  
  #track wp plugins
  cur_wp_plugins = new_content.scan(/\[([^\/][^\]]*?)\]/).uniq
  cur_wp_plugins = cur_wp_plugins.map do |plugin|
    if not( 
        plugin[0].include?('CDATA') || plugin[0].include?('<') || plugin[0] == "endif" || plugin[0].start_with?("if ") 
      )
      plugin[0].gsub(/([\S]+?) [\s\S]*/, "\\1")
    end
  end
  cur_wp_plugins.compact!
  cur_wp_plugins.uniq!
  cur_wp_plugins.sort!
  #at this point, cur_wp_plugins should be a sorted list of each unique plugin node identified within [] without attributes

  #write page plugins list to log file
  @wp_plugins_log.puts path
  @wp_plugins_log.puts "\t" + cur_wp_plugins.inspect.gsub(",", "\n\t")
  @wp_plugins_log.puts "\n--------------------------------------------------\n\n"

  #add each plugin found to the full plugins list
  cur_wp_plugins.each do |plugin|
    @wp_plugins_all.push plugin

    plugin_replace = ""
    orig_str = new_content.clone
    @log.puts "\t plugin: " + plugin

    #replace plugins that have an opening and closing tag
    wp_plugin_regex = /[\s]*?(\[(#{plugin}) ?([^\]]*?)\])([\s\S]*?)(\[\/#{plugin}\])[\s]*/
    if (WP_PLUGIN_CODE_DISPLAY == "span")
      wp_plugin_replace_str = "<span data-type=\"wp-plugin\" data-name=\"\\2\"><span data-type=\"wp-plugin-attribute\">\\3</span>\\4</span>"
      new_content.gsub!(wp_plugin_regex, wp_plugin_replace_str)
      if !(orig_str.eql? new_content)
        plugin_replace = "wp opening/closing tags placed in custom span tags, content within preserved"
      end
    elsif (WP_PLUGIN_CODE_DISPLAY == "comment_tags") #leaves code within wp tags
      wp_plugin_replace_str = "<!-- wp plugin opening tag removed: \\1 --> \n \\4 \n <!-- wp plugin closing tag removed: \\5 -->"
      new_content.gsub!(wp_plugin_regex, wp_plugin_replace_str)
      if !(orig_str.eql? new_content)
        plugin_replace = "wp opening/closing tags placed in comments, content within preserved"
      end
    elsif (WP_PLUGIN_CODE_DISPLAY == "comment_all") #puts entire wp tag within html comments
      wp_plugin_replace_str = "<!-- wp plugin tag removed: \\1 \n \\4 \n \\5 -->"
      new_content.gsub!(wp_plugin_regex, wp_plugin_replace_str)
      if !(orig_str.eql? new_content)
        plugin_replace = "wp opening/closing tags and content within placed in comments"
      end
    elsif (WP_PLUGIN_CODE_DISPLAY == "none")
      wp_plugin_replace_str = "<!-- wp plugin tag removed -->"
      new_content.gsub!(wp_plugin_regex, wp_plugin_replace_str)
      if !(orig_str.eql? new_content)
        plugin_replace = "wp opening/closing tags and all content within removed"
      end
    end

    #remove additional references to wp plugins (those that weren't caught by the first pass, such as items with only a single tag instead of opening/closing tags)
    if not(plugin_replace.include? "wp")
      # @log.puts "\t\t plugin not replaced with first regex... trying secondary regex"
      wp_plugin_regex = /(\[(#{plugin}) ?([^\]]*?) ?\/? ?\])/
      if (WP_PLUGIN_CODE_DISPLAY == "span")
        wp_plugin_replace_str = "<span data-type=\"wp-plugin\" data-name=\"\\2\"><span data-type=\"wp-plugin-attribute\">\\3</span></span>"
        new_content.gsub!(wp_plugin_regex, wp_plugin_replace_str)
        if !(orig_str.eql? new_content)
          plugin_replace = "wp plugin tag placed in custom <span> tag"
        end
      elsif (WP_PLUGIN_CODE_DISPLAY == "comment_tags" or WP_PLUGIN_CODE_DISPLAY == "comment_all") #leaves code within wp tags
        wp_plugin_replace_str = "<!-- wp plugin tag removed: \\1 -->"
        new_content.gsub!(wp_plugin_regex, wp_plugin_replace_str)
        if !(orig_str.eql? new_content)
          plugin_replace = "wp plugin tag placed in comments"
        end
      elsif (WP_PLUGIN_CODE_DISPLAY == "none")
        wp_plugin_replace_str = "<!-- wp plugin tag removed -->"
        new_content.gsub!(wp_plugin_regex, wp_plugin_replace_str)
        if !(orig_str.eql? new_content)
          plugin_replace = "wp plugin tag removed"
        end
      end
    end

    @log.puts "\t\t - plugin_replace:" + plugin_replace
  end

  #add line breaks where spaces are in the original content to more closely mirror the original site
  new_content.gsub!(/[\n]/, "<br/>")
  new_content.gsub!("--> <br/> <!--", "--> \n <!--")

  #ensure returned contnet is valid xhtml for OU Campus PCFs
  new_content = Nokogiri.HTML(new_content).xpath("//body/node()").to_xhtml() 

  return new_content
end



def migrate_xml(xml_doc)
  #if set to use migration map,
  if MIGRATION_MAP_PATH.length > 0
    puts "Migration map path provided, process all items in map."
    @log.puts "Migration map path provided, process all items in map."

    process_csv_row(MIGRATION_MAP_PATH, xml_doc)
  else
    puts "No migration map provided, loop through and migrate all items"
    @log.puts "No migration map provided, loop through and migrate all items"

    #loop through each item in the source and process it
    xml_doc.xpath("//rss/channel/item").each do |item|
      puts "\n\nNow processing " + item.xpath("./link/text()").to_s
      @log.puts "\n\nNow processing " + item.xpath("./link/text()").to_s
      item_type = item.xpath("./wp:post_type/node()").text
      puts "\titem type: " + item_type
      @log.puts "\titem type: " + item_type

      if item_type == "page" || item_type == "post"
        migrate_file(item, "interior", "")
      end
    end
  end
end



def process_rows_from_csv(row, i, xml_doc)
  #store information from the csv into vars with meaningful names
  orig_path = row[0]
  new_path = row[1]
  template = row[2]

  if orig_path == nil
    orig_path = ""
  end
  orig_path = orig_path.encode('utf-8')
  if new_path == nil
    new_path = ""
  end
  new_path = new_path.encode('utf-8')
  
  puts "Processing row #{i+1}: #{orig_path}"
  @log.puts "Processing row #{i+1}: #{orig_path}"

  #
  if xml_doc.xpath("//item[link/text() = '#{orig_path}']").length > 0
    puts "Path exists in source xml"
    @log.puts "Path exists in source xml"

    item = xml_doc.xpath("//item[link/text() = '#{orig_path}']")
    migrate_file(item, template, new_path)
  else
      puts "Path does not exist in source xml, skipping item"
      @log.puts "Path does not exist in source xml, skipping item"
  end
  
  puts ""
  @log.puts ""
end


############################################
########### Migrate from WP Item ###########
############################################
def migrate_file(item, template, new_path)

  #use the item's <link> as the path if no new path is provided
  if new_path == ''
    new_path = item.xpath("./link/text()").to_s.strip
  end

  rr_output_file_path = new_path.gsub(SOURCE_URL_BASE, "") 

  puts "rr_output_file_path: " + rr_output_file_path
  @log.puts "rr_output_file_path: " + rr_output_file_path

  if
    rr_output_file_path.include?  "="||"?"||"!"||"#"||
    "$"||"%"||"^"||"&"||"*"||"("||")"||"["||"]"||"’"||
    "”"||"|"||"<"||">"||"{"||"}"||";"||":"||","||"+"||"="

    @char_log.puts "-----------------------------------------------------------------------------------------------------------------------"
    @char_log.puts "Your old path: ", rr_output_file_path, "Contains special charcters that are not allowed in OU Campus.", "*We've modified your path.", "Your new path is:"
    #remove special characters from path
    @char_log.puts rr_output_file_path = rr_output_file_path.gsub(/[\!\#\$\%\^\&\*\(\)\[\]\?\’\”\|<>{};:,\+\=]/, "")
    @char_log.puts "-----------------------------------------------------------------------------------------------------------------------"

  end  

  #update links that end in / to be the index page of a section
  if rr_output_file_path[-1] == '/' 
    rr_output_file_path = rr_output_file_path + INDEX_NAME
  end
  #add .pcf extension to pages
  if not(rr_output_file_path.end_with? ".pcf")
    rr_output_file_path = rr_output_file_path + ".pcf"
  end

  #generate full path to write to locally
  output_file_path = OUTPUT_ROOT + rr_output_file_path

  rr_output_prod_path = rr_output_file_path.rpartition('.')[0] + OUTPUT_EXTENSION
  puts "output_file_path: " + output_file_path
  @log.puts "output_file_path: " + output_file_path
  
  create_directory(output_file_path) #create directory if needed

  #grab content from source item
  title = item.xpath("./title/text()").to_s
  description = item.xpath("./description/text()").to_s
  main_content = item.xpath("./content:encoded/node()").text

  main_content = update_plugin_references(rr_output_file_path, main_content)
  
  #write data to interior page template
  doc_data = {
    "extension" => OUTPUT_EXTENSION.partition(".")[2], 
    "title" => title, 
    "description" => description, 
    "main_content" => main_content
  }
  @fp_interior.punch_file(output_file_path, doc_data)

  puts "Wrote new file at: #{output_file_path}"
  @log.puts "Wrote new file at: #{output_file_path}"
  
  #we're done writing the page, now add to the nav
  @sidenav_file_maker.write_link(rr_output_prod_path, title)

  #if it's the index page, create the props file
  if rr_output_prod_path.rpartition('/')[2] == INDEX_NAME + OUTPUT_EXTENSION
    props_path = rr_output_file_path.rpartition('/')[0] + PROPS_FILENAME
    @props_file_maker.write(props_path, title)
  end
end
