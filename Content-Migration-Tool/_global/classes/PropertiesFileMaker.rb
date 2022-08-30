class PropertiesFileMaker
  def initialize(base_path, log_file)
    @base_path = base_path
    @log = log_file
  end

  def write(path, title, add_base_path = true)
    if add_base_path
      path = @base_path + path
    end
    File.open(path, "w") do |props_file|
      props_file.puts '<?xml version="1.0" encoding="utf-8"?>'
      props_file.puts '<?pcf-stylesheet path="/_resources/xsl/properties.xsl" title="Properties" extension="html"?>'
      props_file.puts '<!DOCTYPE document SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">'
      props_file.puts '<document xmlns:ouc="http://omniupdate.com/XSL/Variables">'
      props_file.puts '   <ouc:properties label="config">'
      props_file.puts '      <parameter name="breadcrumb" type="text" group="Everyone" prompt="Section Title" alt="Enter the friendly name for the section\'s breadcrumb. Type the word \'$skip\' or leave empty to have the breadcrumb path skip value.">'+ title + '</parameter>'
      props_file.puts '    </ouc:properties>'
      props_file.puts '</document>'
      
      puts "Wrote title '#{title}' to properties file at #{path}"
      @log.puts "Wrote title '#{title}' to properties file at #{path}"
    end
  end
end