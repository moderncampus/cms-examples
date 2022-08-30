require 'erb'
require 'nokogiri'
require 'csv'
require 'htmlentities'
require 'FileUtils'
require 'OS'

PROJECT_ROOT = Dir.pwd
SOURCE_ROOT = "#{PROJECT_ROOT}/source"
OUTPUT_ROOT = "#{PROJECT_ROOT}/output"
CSV_ROOT = "#{PROJECT_ROOT}/csv"

#begin template paths
TMPL_PATH_HOME = "#{PROJECT_ROOT}/templates/home.erb";
TMPL_PATH_INTERIOR = "#{PROJECT_ROOT}/templates/interior.erb";
TMPL_PATH_BLANK = "#{PROJECT_ROOT}/templates/blank.erb";
#end template paths

LOG_PATH = "#{PROJECT_ROOT}/migration.log";
NO_MIGRATE_PATH = "#{PROJECT_ROOT}/not_migrated.txt";
ENC_ISSUES_PATH = "#{PROJECT_ROOT}/encoding_issues.txt";
MISSING_PAGES_PATH = "#{PROJECT_ROOT}/missing_pages.txt";

#begin csv paths
CSV_PATH = "#{CSV_ROOT}/migration-map.csv"

CSV_PATH_SHELL = "#{CSV_ROOT}/shell.csv"
#end csv paths

OUTPUT_PUB_DIR = "" #where the migration will be placed on staging (root-relative) (ex:/_sample-migration)
NAV_FILENAME = "/_nav.inc"
NAV_TAG = '<!-- ouc:editor csspath="/_resources/ou/editor/nav.css" cssmenu="/_resources/ou/editor/styles.txt" wysiwyg-class="navigation" -->'
PROPS_FILENAME = "/_props.pcf"
SOURCE_EXTENSION = ".htm"
OUTPUT_EXTENSION = ".aspx"
INDEX_NAME = "index" #index or default
