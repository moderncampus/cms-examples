class DirMaker
	def initialize(base_path, log_file)
		@base_path = base_path.chomp("/")
		@log = log_file
		if not File.directory?(@base_path)
			create_dirs_in_path("/", false)
		end
	end
	def create_dirs_in_path(sub_path, is_file_path)
		curr_path = ""
		if not OS.windows?
			curr_path = "/"
		end

		path_parts = (@base_path + sub_path).scan(/[^\/]+/)
		path_parts.pop if is_file_path
		path_parts.each do |part|
			curr_path += part + "/"
			if not File.directory?(curr_path)
				Dir.mkdir(curr_path)
			end
		end
	end
end