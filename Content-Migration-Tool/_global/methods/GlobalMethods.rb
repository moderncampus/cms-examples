#copies a file from the given source path to the given destination path
def copy_file(src_path, dest_path)
  begin
    create_directory(dest_path)
    FileUtils.cp(src_path, dest_path)
    puts "File copied from " + src_path + " to " + dest_path
    @log.puts "File copied from " + src_path + " to " + dest_path
  rescue
    puts "Unable to copy from " + src_path + " to " + dest_path
    @log.puts "Unable to copy from " + src_path + " to " + dest_path
  end
end

#capitalizes all the words of the given string and returns the result
def capitalize_words(words)
  return words.split.map(&:capitalize).join(' ')
end

#given a path to a source file, creates the directory structure the file needs to exist
def create_directory(path)
  #create output directory path if needed
  if not File.directory?(path.rpartition('/')[0])
    output_sub_path = path.partition(OUTPUT_ROOT)[2]
    @dir_maker.create_dirs_in_path(output_sub_path, true)
    @log.puts "Created directory path."
  end
end

#returns the name of the parent directory for the given path (ex: a path of /dir1/dir2/file.html returns dir2)
def get_parent_dir(path)
  return path.rpartition('/')[0].rpartition('/')[2]
end

# process the rows from csv
def process_csv_row(csv_path)
  puts "Processing CSV: " + csv_path
  @log.puts "Processing CSV: " + csv_path
  @map_array = CSV.read(csv_path)
  @map_array.each_with_index do |row, i|
    process_rows_from_csv(row, i)
  end
  puts ""
  @log.puts ""
  puts ""
  @log.puts ""
end

# process the rows shell from csv
def process_csv_shell_row(csv_path)
  puts "Processing CSV: " + csv_path
  @log.puts "Processing CSV: " + csv_path
  @map_array = CSV.read(csv_path)
  @map_array.each_with_index do |row, i|
    process_rows_shell_from_csv(row, i)
  end
  puts ""
  @log.puts ""
  puts ""
  @log.puts ""
end



#given a path to a navigation file, sorts the navigation and rewrites the file
def sort_nav(nav_path)
  File.open(nav_path, "r:UTF-8") do |nav_file|
    
    nav_doc = Nokogiri.HTML(nav_file)
    nav_doc = Nokogiri.HTML(nav_doc.to_s.encode("UTF-8"))
    
    #store each link into an array
    nav_info = Hash.new
    nav_doc.xpath("//li").each do |li|
      nav_text = li.xpath("./a/node()").to_s
      nav_link = li.xpath("./a/@href").to_s
      nav_info.store(nav_link, nav_text)
    end
    
    #sort the navigation array
    nav_arr = nav_info.sort_by { |text, link| link }
    # puts "nav_arr: " + nav_arr.inspect
    
    #start rewriting the nav file
    File.open(nav_path, "w") do |new_nav_file|
      new_nav_file.puts NAV_TAG
    end
    
    #go through each link in the nav array
    nav_arr.each do |nav_item|
      #write each link to the new nav file
      File.open(nav_path, "a+") do |new_nav_file|
        new_nav_file.puts "<li><a href=\"#{nav_item[0]}\">#{nav_item[1]}</a></li>"
        # puts "Wrote link for #{nav_item[0]} to nav file at #{nav_path}"
        @log.puts "Wrote link for #{nav_item[0]} to nav file at #{nav_path}"
      end
    end
    
  end
end

def migrated_files_arr_add (text)
  @migrated_files_arr[@migrated_files_arr_index] = text
  @migrated_files_arr_index = @migrated_files_arr_index + 1
end

# update time/date for date picker
def update_pubdate_to_dtp (item)
  date = ''  
    date = item.xpath("./pubdate/node()").to_s.gsub("+0000", "")
    t = Time.parse(date.to_s)
    # 09/20/2015 01:11:36 PM
    date = t.strftime("%m/%d/%Y %H:%M:%S %p") # format time for date picker
  return date
end

# update html columns to ou snippet 
def update_column_to_snippet(current_content)
   
  puts "Searching for Column Content!"
  @log.puts "Searching for Column Content!"
  c_doc = Nokogiri.HTML(current_content)
  
 
   if c_doc.xpath("//div[@class ='3-columns']/node()").length > 0       
    c_doc.xpath("//div[@class ='3-columns']").each do |elements|             
      puts "Column Content found!"
    @log.puts "Column Content found!"
    
      content = ''
      post_content = ''
      heading = ''    
      # Table Snippet Structure / HTML
      content += '<table class="ou-three-cols">' + "\n"
      content += '  <caption>Three Columns Snippet</caption>' + "\n"
      content += '    <thead>' 
      content += '      <tr>'
      content += '        <td>Title</td>' 
      content += '        <td>Content (add \'class="list-unstyled"\' to ul)</td> </tr> </thead>' + "\n"
      content += '      <tbody>' + "\n"
       
      if elements.xpath("./div[@class='column-1']").length > 0        
        # loop through main element, updating c_doc with the new structure
        elements.xpath("./div[@class='column-1']").each do |the_element|                                
          puts "Inserting left structure!"
          @log.puts "Inserting left structure!"         
          
      content += '        <tr>'                                     
          
      # update the structure for the correct content                         
          # @log.puts "Current Update Element Column 1: " + the_element.to_s # debugging          
          # Add Content       
          new_td_1 = c_doc.create_element "td"      
          new_td_1.inner_html = the_element.xpath("./h3/node()").to_xhtml
          new_td_2 = c_doc.create_element "td"
         
      # target different elements
          if the_element.xpath("./p").length > 0     
            new_td_2.inner_html = the_element.xpath("./p").to_xhtml
          elsif the_element.xpath("./ul").length > 0
            new_td_2.inner_html = the_element.xpath("./ul").to_xhtml
          elsif !(the_element.xpath("./h3/node()"))
            new_td_2.inner_html = the_element.to_xhtml
          end 
                                                            
          # Overwrite Content
          content += new_td_1.to_xhtml() + "\n" + new_td_2.to_xhtml() + "\n"    
          content += '        </tr>'
          
          puts "Processing next overwrite"
      @log.puts "Processing next overwrite"               
        end
      end
      
      if elements.xpath("./div[@class='column-2']").length > 0              
        puts "Inserting middle structure!"
    @log.puts "Inserting middle structure!"
        elements.xpath("./div[@class='column-2']").each do |the_element|
          # @log.puts "Begin Overwrite..."   # debugging                                   
          
      content += '        <tr>'
          
      # Add Content       
          new_td_1 = c_doc.create_element "td"      
          new_td_1.inner_html = the_element.xpath("./h3/node()").to_xhtml
          new_td_2 = c_doc.create_element "td"
          
      
      if the_element.xpath("./p").length > 0     
            new_td_2.inner_html = the_element.xpath("./p").to_xhtml
          elsif the_element.xpath("./ul").length > 0
            new_td_2.inner_html = the_element.xpath("./ul").to_xhtml
          elsif !(the_element.xpath("./h3/node()"))
            new_td_2.inner_html = the_element.to_xhtml
          end 
                                                            
          # Overwrite Content
          content += new_td_1.to_xhtml() + "\n" + new_td_2.to_xhtml() + "\n"
          content += '        </tr>'  
          
          puts "Processing next overwrite"
      @log.puts "Processing next overwrite"
        end
      end
      
      if elements.xpath("./div[@class='column-3']").length > 0           
        puts "Inserting right structure!"
        @log.puts "Inserting right structure!"\
    
        elements.xpath("./div[@class='column-3']").each do |the_element|
          
          # @log.puts "Processing last overwrite..." # debugging
          content += '        <tr>'
          # Add Content       
          new_td_1 = c_doc.create_element "td"      
          new_td_1.inner_html = the_element.xpath("./h3/node()").to_xhtml
          new_td_2 = c_doc.create_element "td"
          if the_element.xpath("./p").length > 0     
            new_td_2.inner_html = the_element.xpath("./p").to_xhtml
          elsif the_element.xpath("./ul").length > 0
            new_td_2.inner_html = the_element.xpath("./ul").to_xhtml
          elsif !(the_element.xpath("./h3/node()"))
            new_td_2.inner_html = the_element.to_xhtml
          end 
                                         
          # Overwrite Content
          content += new_td_1.to_xhtml() + "\n" + new_td_2.to_xhtml() + "\n"       
       
          content += '    </tr>' + "\n"
         
          # puts "Content before replace... " + content.to_s # debugging          
          # @log.puts "Content after replace... " + content.to_s # debugging                            
        end
      end    
   
    content += '  </tbody>' + "\n"
      content += '</table>' + "\n"
      # @log.puts "Column Snippet Table added!" # debugging
      
      # update content output with new c_doc values
      elements.xpath("./*").each do |the_element|
        @log.puts "Elements"
        if (the_element.xpath("./@class").to_s == 'column-1' || the_element.xpath("./@class").to_s == 'column-2' || the_element.xpath("./@class").to_s == 'column-3') # (the_element.css(".column-1").length > 1 || the_element.css(".column-2").length > 1 || the_element.css(".column-3").length > 1)
          @log.puts "Is Column 1,2,3... Do nothing" 
          puts "Is Column 1,2,3... Do nothing"         
         else 
           post_content += the_element.to_xhtml()
           @log.puts "Content added after table..."  
         end         
      end
      
    # update element          
      elements.replace content + post_content
    end
    current_content = c_doc.xpath("//body/node()").to_xhtml()            
    return current_content     
  end
end
