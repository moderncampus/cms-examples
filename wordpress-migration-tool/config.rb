require 'erb'
require 'nokogiri'
require 'csv'
require 'FileUtils'
require 'OS'

#begin root paths
PROJECT_ROOT = Dir.pwd #the current working directory
SOURCE_ROOT = "#{PROJECT_ROOT}/source" #where source files should be placed
OUTPUT_ROOT = "#{PROJECT_ROOT}/output" #where output files will be generated
LOGS_ROOT 	= "#{PROJECT_ROOT}/logs" #where log files will be generated
TMPL_ROOT 	= "#{PROJECT_ROOT}/templates" #where template files should exist
CSV_ROOT 	= "#{PROJECT_ROOT}/csv" #where csv files should be placed (i.e. migration map)
#end root paths

#begin log paths
LOG_PATH = "#{LOGS_ROOT}/migration.log" #the main log file that will capture a lot of information about the migration
MAP_LOG_PATH = "#{LOGS_ROOT}/migration_map.log"
NO_MIGRATE_PATH = "#{LOGS_ROOT}/not_migrated.txt"
ENC_ISSUES_PATH = "#{LOGS_ROOT}/encoding_issues.txt"
MISSING_PAGES_PATH = "#{LOGS_ROOT}/missing_pages.txt"
CHAR_REPLACE_PATH = "#{LOGS_ROOT}/char_replace.log" #when <link> path contains characters that are not valid in OU they will be logged here
PLUGINS_LOG_FOLDER_PATH = "#{LOGS_ROOT}/plugins" #basic reports about plugin data found in the source will be logged here
#end log paths

#begin template paths
TMPL_PATH_INTERIOR = "#{TMPL_ROOT}/interior.erb"
TMPL_PATH_BLANK = "#{TMPL_ROOT}/blank.erb"
#end template paths

#enter path to WordPress source xml, a directory to pull all WordPress source xml files from, or leave blank to process all .xml files within SOURCE_ROOT
WP_SOURCE_FILE = "#{SOURCE_ROOT}/gallena.xml"
# WP_SOURCE_FILE = "";

#if using a migration map enter path to map here (example path provided in commented line below). Leave blank to keep all paths the same, running the script without a migration map. 
MIGRATION_MAP_PATH = ""
# MIGRATION_MAP_PATH = "#{PROJECT_ROOT}/migration_maps/sample.csv"

#this should be the root url in <link>https://www.example.edu/</link> from the xml source file
SOURCE_URL_BASE = "https://www.gallena.edu"

#begin created content variables
OUTPUT_EXTENSION = ".php" #the extension your published pages should have
INDEX_NAME = "index" #index or default, depending on your production server's settings
NAV_FILENAME = "/_nav.inc" #the name of your implementation's section navigation files
NAV_TAG = '<!-- ouc:editor csspath="/_resources/ou/editor/nav.css" cssmenu="/_resources/ou/editor/styles.txt"/ -->' #the common tagging at the top of each navigation file in your implementation
PROPS_FILENAME = "/_props.pcf" #the name of your implementation's section properties files
#end created content variables

#WP_PLUGIN_CODE_DISPLAY can be used to determine how to handle WordPress (wp) plugin tags. Accepted values are: 
# 	"as_is" - does not update wp tags
#   "span" - places wp tags and any contained content within custom <span> tags
# 	"comment_tags" - comments out the wp tags surrounding their content, leaving the tagged content intact
# 	"comment_all" - comments out the wp tags including their content
# 	"none" - deletes the wp tags and their content
WP_PLUGIN_CODE_DISPLAY = "span"