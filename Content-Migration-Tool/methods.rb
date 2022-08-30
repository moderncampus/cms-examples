# migration specific methods

def get_content(html_doc)
  #get the page's body node (if it exists) to work with
  if html_doc.xpath("/html/body/node()").length > 0
    # page_body = html_doc.xpath("/html/body/node()") #for regex matching
    # page_bodyXML = page_body.to_xhtml #for regex matching
    
    #use xpath to find content
    if html_doc.xpath("//article[@class='main-content']").length > 0
      return html_doc.xpath("//article[@class='main-content']")
      
    #use this example to match content using regex instead of xpath
    # elsif page_bodyXML.include? "<td valign=\"top\""
      # if page_bodyXML.gsub(/<td valign=\"top\"([\s\S]*?)(<table[^>]*?>[\s\S]*?<\/table>)([\s\S]*?)(<\/td>)/, 'OU MATCH').include? "OU MATCH"
        # return page_bodyXML.gsub(/[\s\S]*?<td valign=\"top\"[^>]*?>([\s\S]*?<table[^>]*?>[\s\S]*?<\/table>[\s\S]*?)<\/td>[\s\S]*/, "\\1").gsub(/&#13;/, "")
      # else
        # return page_bodyXML.gsub(/[\s\S]*?<td valign=\"top\"[^>]*?>([\s\S]*?)<\/td>[\s\S]*/, "\\1").gsub(/&#13;/, "")
      # end
    else
      #content not found... 
      puts "no content found"
      return "no content found"
    end
  end
end

####################################
############ From CSV ##############
####################################

#the main method that migrates a file from csv map and source files
def migrate_file_csv(orig_path, new_path, title, template, encoding)
  rr_output_file_path = new_path.sub(OUTPUT_EXTENSION, ".pcf")
  output_file_path = OUTPUT_ROOT + OUTPUT_PUB_DIR + rr_output_file_path
  puts "output_file_path: " + output_file_path
  @log.puts "output_file_path: " + output_file_path
  
  orig_path = SOURCE_ROOT + orig_path
  rr_dir = rr_output_file_path.rpartition('/')[0]
  
  create_directory(output_file_path) #create directory if needed
  
  puts "orig_path: " + orig_path
  @log.puts "orig_path: " + orig_path
  
  if File.file?(orig_path)
    puts "Source page exists."
    @log.puts "Source page exists."
    
    File.open(orig_path, "r:#{encoding}") do |html_file|

      # this will sometimes fail and should be rescued
      html_doc = Nokogiri.HTML(html_file)
      html_doc = Nokogiri.HTML(html_doc.to_s.encode("UTF-8"))
      
      if title == nil or title == ""
        title = html_doc.xpath("//title/node()").to_s
      end
      # content = html_doc.xpath("//div[@id='content']/node()").to_xhtml.gsub(/<!--[\s\S]*?-->/, "")
      content = get_content(html_doc)
      
      # @log.puts "HTML Content: " + content #for debugging
      
      #create the page depending on the template given
      if template == "home"
        #home page
        puts "Template: home page"
        @log.puts "Template: home page"
    
        doc_data = {"title" => title}
        @fp_home.punch_file(output_file_path, doc_data)
    
        puts "Wrote new file at: #{output_file_path}"
        @log.puts "Wrote new file at: #{output_file_path}"
    
      elsif template == "full width"
        #full width page
        puts "Template: full width page"
        @log.puts "Template: full width page"
        
        sidebar_disp = '<parameter name="sidebarDisplay" prompt="Sidebar Display" alt="Choose to show or hide the sidebar." type="select">
          <option value="show" selected="false">Show</option>
          <option value="hide" selected="true">Hide</option>
        </parameter>';
    
        doc_data = {"title" => title, "sidebar_disp" => sidebar_disp}
        @fp_interior.punch_file(output_file_path, doc_data)
    
        puts "Wrote new file at: #{output_file_path}"
        @log.puts "Wrote new file at: #{output_file_path}"
    
      elsif template == "interior"
        #interior page
        puts "Template: interior page"
        @log.puts "Template: interior page"
        
        sidebar_disp = '<parameter name="sidebarDisplay" prompt="Sidebar Display" alt="Choose to show or hide the sidebar." type="select">
          <option value="show" selected="true">Show</option>
          <option value="hide" selected="false">Hide</option>
        </parameter>';
    
        doc_data = {"title" => title, "sidebar_disp" => sidebar_disp}
        @fp_interior.punch_file(output_file_path, doc_data)
    
        puts "Wrote new file at: #{output_file_path}"
        @log.puts "Wrote new file at: #{output_file_path}"
    
      else
        puts "Template not found!"
        @log.puts "Template not found!"
        
        #copy file over as-is if no template found
        puts "filepath: " + orig_path
        puts "new_path: " + new_path
        copy_file(orig_path, OUTPUT_ROOT + OUTPUT_PUB_DIR + new_path)
      end
      
      #we're done writing pages, now add to the nav
      @sidenav_file_maker.write_link(OUTPUT_PUB_DIR + new_path, title)
    
      #if it's the index page, create the props file
      if new_path.rpartition('/')[2] == INDEX_NAME + OUTPUT_EXTENSION
        props_path = rr_output_file_path.rpartition('/')[0] + PROPS_FILENAME
        @props_file_maker.write(OUTPUT_PUB_DIR + props_path, title)
      end
    end
  else
    puts "Source file does not exist: " + orig_path
    @log.puts "Source file does not exist: " + orig_path
    
    @missing_pages_arr[@missing_pages_arr_index] = orig_path.partition(SOURCE_ROOT)[2]
    @missing_pages_arr_index = @missing_pages_arr_index + 1
  end
end

def process_rows_from_csv(row, i)
  #store information from the csv into vars with meaningful names
  orig_path = row[0]
  new_path = row[1]
  title = row[2]
  template = row[3]
  
  if orig_path == nil
    orig_path = ""
  end
  orig_path = orig_path.encode('utf-8')
  if title == nil
    title = ""
  end
  title = title.encode('utf-8')
  
  unless orig_path == nil
    orig_path.sub!("http://www.omniupdate.com", "") #update this if needed to remove parts of the given path to make it root-relative
    if orig_path[-1,1] == '/'
      orig_path = orig_path + INDEX_NAME + SOURCE_EXTENSION
    end
  end
  unless new_path == nil
    new_path.sub!("http://www.omniupdate.com", "") #update this if needed to remove parts of the given path to make it root-relative
  end
  
  puts "Processing row #{i+1}: #{orig_path}"
  @log.puts "Processing row #{i+1}: #{orig_path}"
  
  #migrate all rows unless there is no new path defined
  unless new_path == nil or new_path[0] != '/' or orig_path == nil
    begin
      migrate_file_csv(orig_path, new_path, title, template, "UTF-8")
    rescue
      begin
        migrate_file_csv(orig_path, new_path, title, template, "Windows-1252")
      rescue
        puts "*UNABLE TO MIGRATE FILE: " + $!.to_s
        @log.puts "*UNABLE TO MIGRATE FILE: " + $!.to_s
        
        @encoding_issues_arr[@encoding_issues_arr_index] = orig_path
        @encoding_issues_arr_index = @encoding_issues_arr_index + 1
      end
    end
  end
  unless orig_path == nil
    #the file was in the csv, so add it to the migrated files array for processing
    migrated_files_arr_add(orig_path)
    #add the lower case version...
    filename = orig_path.rpartition('/')[2]
    path = orig_path.rpartition('/')[0] + "/"
    migrated_files_arr_add(path + filename.downcase)
  end
  
  puts ""
  @log.puts ""
end


####################################
############ Shell CSV #############
####################################

#migrate the file from csv only and create a shell site
def migrate_file_shell_csv(new_path, title, template, encoding)
  rr_output_file_path = new_path.sub(OUTPUT_EXTENSION, ".pcf")
  output_file_path = OUTPUT_ROOT + OUTPUT_PUB_DIR + rr_output_file_path
  puts "output_file_path: " + output_file_path
  @log.puts "output_file_path: " + output_file_path
  
  rr_dir = rr_output_file_path.rpartition('/')[0]
  
  create_directory(output_file_path) #create directory if needed
  
  #create the page depending on the template given
  if template == "home"
    #home page
    puts "Template: home page"
    @log.puts "Template: home page"

    doc_data = {"title" => title}
    @fp_home.punch_file(output_file_path, doc_data)

    puts "Wrote new file at: #{output_file_path}"
    @log.puts "Wrote new file at: #{output_file_path}"

  elsif template == "full width"
    #full width page
    puts "Template: full width page"
    @log.puts "Template: full width page"
    
    sidebar_disp = '<parameter name="sidebarDisplay" prompt="Sidebar Display" alt="Choose to show or hide the sidebar." type="select">
      <option value="show" selected="false">Show</option>
      <option value="hide" selected="true">Hide</option>
    </parameter>';

    doc_data = {"title" => title, "sidebar_disp" => sidebar_disp}
    @fp_interior.punch_file(output_file_path, doc_data)

    puts "Wrote new file at: #{output_file_path}"
    @log.puts "Wrote new file at: #{output_file_path}"

  elsif template == "interior"
    #interior page
    puts "Template: interior page"
    @log.puts "Template: interior page"
    
    sidebar_disp = '<parameter name="sidebarDisplay" prompt="Sidebar Display" alt="Choose to show or hide the sidebar." type="select">
      <option value="show" selected="true">Show</option>
      <option value="hide" selected="false">Hide</option>
    </parameter>';

    doc_data = {"title" => title, "sidebar_disp" => sidebar_disp}
    @fp_interior.punch_file(output_file_path, doc_data)

    puts "Wrote new file at: #{output_file_path}"
    @log.puts "Wrote new file at: #{output_file_path}"

  else
    puts "Template not found! Creating interior page..."
    @log.puts "Template not found! Creating interior page..."

    #default to interior if no template found
    sidebar_disp = '<parameter name="sidebarDisplay" prompt="Sidebar Display" alt="Choose to show or hide the sidebar." type="select">
      <option value="show" selected="true">Show</option>
      <option value="hide" selected="false">Hide</option>
    </parameter>';

    doc_data = {"title" => title, "sidebar_disp" => sidebar_disp}
    @fp_interior.punch_file(output_file_path, doc_data)

    puts "Wrote new file at: #{output_file_path}"
    @log.puts "Wrote new file at: #{output_file_path}"
  end

  #we're done writing pages, now add to the nav
  @sidenav_file_maker.write_link(OUTPUT_PUB_DIR + new_path, title)

  #if it's the index page, create the props file
  if new_path.rpartition('/')[2] == INDEX_NAME + OUTPUT_EXTENSION
    props_path = rr_output_file_path.rpartition('/')[0] + PROPS_FILENAME
    @props_file_maker.write(OUTPUT_PUB_DIR + props_path, title)
  end

end

def process_rows_shell_from_csv(row, i)
  #store information from the csv into vars with meaningful names
  new_path = row[0]
  title = row[1]
  template = row[2]
  
  if title == nil
    title = ""
  end
  title = title.encode('utf-8')
  
  unless new_path == nil
    new_path.sub!("http://scciowa.edu", "")
  end
  
  puts "Processing row #{i+1}: #{new_path}"
  @log.puts "Processing row #{i+1}: #{new_path}"
  
  #migrate all rows unless there is no new path defined
  unless new_path == nil or new_path[0] != '/'
    migrate_file_shell_csv(new_path, title, template, "UTF-8")
  end
  
  puts ""
  @log.puts ""
end

####################################
########## Source Files ############
####################################

#the main method that migrates a file
def migrate_source_file(orig_path, encoding)
  rr_output_file_path = orig_path.partition(SOURCE_ROOT)[2].rpartition('.')[0] + ".pcf"
  output_file_path = OUTPUT_ROOT + OUTPUT_PUB_DIR + rr_output_file_path
  rr_output_prod_path = rr_output_file_path.rpartition('.')[0] + OUTPUT_EXTENSION
  puts "output_file_path: " + output_file_path
  @log.puts "output_file_path: " + output_file_path
  
  rr_dir = rr_output_file_path.rpartition('/')[0]
  
  create_directory(output_file_path) #create directory if needed
  
  puts "orig_path: " + orig_path
  @log.puts "orig_path: " + orig_path
  
  if File.file?(orig_path)
    puts "Source page exists."
    @log.puts "Source page exists."
    
    File.open(orig_path, "r:#{encoding}") do |html_file|

      # this will sometimes fail and should be rescued
      html_doc = Nokogiri.HTML(html_file)
      html_doc = Nokogiri.HTML(html_doc.to_s.encode("UTF-8"))
      
      title = html_doc.xpath("//title/node()").to_s
      # content = html_doc.xpath("//div[@id='content']/node()").to_xhtml.gsub(/<!--[\s\S]*?-->/, "")
      content = get_content(html_doc)
      
      # @log.puts "HTML Content: " + content #for debugging
      
      #determine template based on source files
      template = "";
      if html_doc.xpath("//section[@class='carousel homepage-carousel']").length > 0 #it's a homepage layout
        template = "home"
      elsif html_doc.xpath("//body").to_s.gsub(/[s\S]*?(<!--[\s\S]-->)[\s\S]*?/, "\\1").include? "full width" #it's a full width page
        template = "full width"
      elsif title.include? "Interior" #it's an interior page
        template = "interior"
      end
      
      #create the page depending on the template given
      if template == "home"
        #home page
        puts "Template: home page"
        @log.puts "Template: home page"
    
        doc_data = {"title" => title}
        @fp_home.punch_file(output_file_path, doc_data)
    
        puts "Wrote new file at: #{output_file_path}"
        @log.puts "Wrote new file at: #{output_file_path}"
    
      elsif template == "full width"
        #full width page
        puts "Template: full width page"
        @log.puts "Template: full width page"
        
        sidebar_disp = '<parameter name="sidebarDisplay" prompt="Sidebar Display" alt="Choose to show or hide the sidebar." type="select">
          <option value="show" selected="false">Show</option>
          <option value="hide" selected="true">Hide</option>
        </parameter>';
    
        doc_data = {"title" => title, "sidebar_disp" => sidebar_disp}
        @fp_interior.punch_file(output_file_path, doc_data)
    
        puts "Wrote new file at: #{output_file_path}"
        @log.puts "Wrote new file at: #{output_file_path}"
    
      elsif template == "interior"
        #interior page
        puts "Template: interior page"
        @log.puts "Template: interior page"
        
        sidebar_disp = '<parameter name="sidebarDisplay" prompt="Sidebar Display" alt="Choose to show or hide the sidebar." type="select">
          <option value="show" selected="true">Show</option>
          <option value="hide" selected="false">Hide</option>
        </parameter>';
    
        doc_data = {"title" => title, "sidebar_disp" => sidebar_disp}
        @fp_interior.punch_file(output_file_path, doc_data)
    
        puts "Wrote new file at: #{output_file_path}"
        @log.puts "Wrote new file at: #{output_file_path}"
    
      else
        puts "Template not found!"
        @log.puts "Template not found!"
        
        #copy file over as-is if no template found
        new_path = OUTPUT_ROOT + OUTPUT_PUB_DIR + orig_path.partition(SOURCE_ROOT)[2]
        puts "filepath: " + orig_path
        puts "new_path: " + new_path
        copy_file(orig_path, new_path)
      end
      
      #we're done writing pages, now add to the nav
      @sidenav_file_maker.write_link(rr_output_prod_path, title)
    
      #if it's the index page, create the props file
      if rr_output_prod_path.rpartition('/')[2] == INDEX_NAME + OUTPUT_EXTENSION
        props_path = rr_output_file_path.rpartition('/')[0] + PROPS_FILENAME
        @props_file_maker.write(OUTPUT_PUB_DIR + props_path, title)
      end
    end
  else
    puts "Source file does not exist: " + orig_path
    @log.puts "Source file does not exist: " + orig_path
    
    @missing_pages_arr[@missing_pages_arr_index] = orig_path.partition(SOURCE_ROOT)[2]
    @missing_pages_arr_index = @missing_pages_arr_index + 1
  end
end


# compare 2 links for equality
def link_is_same(pcf_link, link_in_csv)
# puts "##########################################"   
#  puts "compare #{pcf_link} to #{link_in_csv}"  
# puts "##########################################"              
     
  # if either links is undefined, return false. Also skip invalid links ex. 'DO NOT MIGRATE'
  if pcf_link.nil? || link_in_csv.nil? 
    return false
  end
  
  # clean link paths by removing extra space and normalize case
  l1 = pcf_link.strip.downcase
  l2 = link_in_csv.strip.downcase
  
  #puts "comparing #{l1}(pcf_link) with #{l2}(link_in_csv)"
  
  # return true if matching
  return l1 == l2
end

# Update the links in the source file to move with the migration map links
# call this function on the content before any replaces and the document is in a Nokogiri form as well.
def update_links(pcf_as_nkg)
  
  @map_array = CSV.read(CSV_PATH)
  updated_links = 0
  # loop thru all links
  pcf_as_nkg.xpath("/html/body/descendant::a/@href").each do |href|                        
    old_path = String.new(href.text).strip
    # skip # links and external/subdomain links     
    unless old_path.start_with?("tel") || old_path.start_with?("#") || ( old_path.include?("//") && !(old_path.include?("wcupa.edu")))
     
      # find a row containing the new path
      csv_row_of_path = @map_array.select{|row| link_is_same(old_path,row[0])}         
      
      #puts @map_array
      # skip if no match
      unless csv_row_of_path[0].nil?
        new_path = csv_row_of_path[0][2]      
        # skip if new_path undefined in that row, or if it's already the same
        unless new_path.nil? || new_path == old_path || !(new_path.start_with?("/"))
            new_path.strip!               
           # update href (append migration folder)
           href.value = "#{OUTPUT_PUB_DIR}#{new_path}"
           msg = "#{old_path} updated to #{new_path}"
           #puts msg
           #@log.puts msg
           updated_links = updated_links + 1                
         end # end if new link not empty                        
      end # end if no old link match           
    end          
  end # end link loop
   
  # log how many links were updated 
  if updated_links > 0
    msg = "Updated #{updated_links} link(s)"
    puts msg
    @log.puts msg
  end
  
    return pcf_as_nkg
 
  end # end link update method
