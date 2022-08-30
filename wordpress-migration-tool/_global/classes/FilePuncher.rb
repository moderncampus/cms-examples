class FilePuncher
  def initialize(template, log)
    @tmpl = template
    @log = log
  end
  def punch_file(file_path, doc_data)
    doc_data.each { |key, val| self.instance_variable_set("@#{key}", val) }
    File.open(file_path, "w") do |new_file|
      file_content = @tmpl.result(binding)
      # @log.puts "File: " + file_path
      # @log.puts "File content: " + file_content
      new_file.write(file_content)
    end
  end
end