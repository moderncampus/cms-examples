***The included source code, service, and the information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of Omni CMS.***

# WordPress Migration Tool
This package contains code and instructions that can be used to migrate content from a WordPress site into a simple site in Omni CMS through the use of a simple Ruby script. With some simple updates to the template files, this script could also migrate content into any predefined Omni CMS PCF file structure. 

 - **This tool is only meant to migrate basic WordPress content from a single domain/subdomain. It is not indended to migrate content or complex HTML data structures contained within plugins or other applications.**

## Table of Contents

 - [Set Up Ruby Environment](#user-content-set-up-ruby-environment)
 - [Set Up Simple Site](#user-content-set-up-simple-site)
 - [Export WordPress Content](#user-content-export-wordpress-content)
 - [Migration Process](#user-content-migration-process)
 - [Migrating Binaries](#user-content-migrating-binaries)
 - [Cleanup](#user-content-cleanup)
 - [Troubleshooting](#user-content-troubleshooting)

## Set Up Ruby Environment
Ruby needs to be installed on the same machine where the migration script will be run. Ruby should come installed if you are using Mac OS, but for versions of Windows you will want to install Ruby from the [Ruby Installer](https://rubyinstaller.org/) site.

If you aren't sure if you have Ruby installed, run `ruby -v`. If you see the Ruby version displayed, Ruby is installed. Otherwise, you need to install it. 

### Ruby Gems

Ruby should come installed with a few "gems" but some additional gems are needed to run this migration script, as listed below. These are packages that are installed through Ruby's bundled-in RubyGems package manager, so no additional installation should be required in order to install them, as described below. 

 - File Utils
 	- This gem should be preinstalled with Ruby. If not, please install by running `gem install fileutils` from the Command Prompt or Terminal. 

 - Nokogiri
 	- Nokogiri is used to load and query your existing source files. This script focuses on XPath related queries, but Nokogiri is capable of interpreting CSS selectors to target content for migration. 
 	- To install Nokogiri, run the following command from the Command Prompt or Terminal: `gem install nokogiri`

 - OS (Operating System)
 	- This gem is used by the migration script to detect the operating system the script is installed on and apply appropriate logic in the way files are migrated, and how folders are created on output, primarily through file path manipulation. 
 	- To install OS, run the following command from the Command Prompt or Terminal: `gem install os`

After you have installed Ruby and ensure the above gems are also installed, your system should be ready to run this tool. 

## Set Up Simple Site
This package contains code for a small sample website that can be used in Omni CMS and will be the destination for your migrated WordPress content. 

### Installation
 1. Navigate to Modern Campus's example code for a [Simple Site](https://github.com/moderncampus/omni-cms-examples/tree/main/example-code-simple-site) and download the package as a Zip file.
 2. Upload the downloaded Simple Site Zip file to the root of your Omni CMS site using Omni CMS' Zip Import feature, which will also extract the files for you. 
 3. If the Simple Site is on a C# server then configure the ASP includes in the `functions.xsl` file. Also change PCF extensions via Find and Replace to the desired extension (if not `php`). A sample regex to perform this replace is below:

	Find:

	```
	(<\?pcf-stylesheet[^?]+?extension=")php("[^?]*?\?>)
	```

	Replace:

	```
	$1new_extension$2
	```

	*Remember to update `new_extension` in the Replace with the extension you want each PCF to publish.*

 4. After the upload is complete, publish all files and navigate to the published pages on production to ensure the content renders correctly. 
 	- If all appears as expected, delete the `/about` folder and its contents to ensure the sample content will not appear alongside the migrated content after the migration process is complete. 

## Export Wordpress Content
The following steps show how to generate a WordPress export that this script may then use. For your convenience, we have included a sample `gallena.xml` export along with a sample migration map that you may use to test the script before going through these steps to use your own data. 

 1. Starting in your WordPress dashboard navigate to mysite --> settings and then select "Export". 
 2. On the next screen, you will have the option to export your entire site or pick and choose which elements you would like to export. 
 3. Once desired elements have been chosen, click "Download Export File" button and an xml file of the WordPress site content will be downloaded. 
 4. Repeat the above steps for each instance of WordPress that you would like to import into a single site in Omni CMS. 

More details on this process can be found on WordPress' [Tools Export Screen Documentation](https://wordpress.org/support/article/tools-export-screen/).

## Migration Process

### Gather Required Resources

 1. Download all the files from this GitHub package to a location it can be run by the Ruby engine. 
 2. Copy the WordPress xml file export(s) into `/source`
 3. If you will be using a **migration map** during this process copy your migration map into `/migration_maps`. The migration map should use the same structure as `/migration_maps/sample.csv`. No matter how you decide to edit this map, the important thing is to save it as a .csv file without any headers with the old path, new path, and template columns in that order. 

### Configure the Script

Open `/config.rb` in a text editor and adjust the values for each of the variables, as described below. 

 - Root Paths
	- These variables define particular folders where groups of similar files should be placed or generated. They should not need to be updated. 

 - Log Paths
	- These variables define paths for where each log file will be created. They should not need to be updated. 

 - Template Paths
	- For this tutorial, we suggest using the default templates that will migrate into the Simple Site. With some additional setup, advanced users can use these options to add additional paths to define other PCF structures that content will be migrated into. 

 - WP_SOURCE_FILE 
 	- Enter one of the following:
 		- A path to your WordPress source xml, exported as outlined earlier in this document.
 		- A path to the directory to pull all WordPress source xml files from. When you choose this option, a combined XML file called `_full.xml` will be created as part of the process, which you can use to track the migration source in a single location. 
 		- Leave blank to process all .xml files within SOURCE_ROOT.

 - MIGRATION_MAP_PATH
	- If you are using a migration map then update this variable to point to the location of the CSV map you uploaded previously. 
	- If you are not using a migration map, this variable should be left as a blank string and all items in WordPress source XML defined by WP_SOURCE_FILE will be processed as-is. 
	- **Create a migration map** - This path can also be used in conjunction with `create_migration_map.rb` to create a migration map based off a WordPress XML file defined here. To do so, simply set this variable and run this Ruby file and a migration map will be created at the defined location. 

 - SOURCE_URL_BASE
	- As the script migrates individual page content into Omni CMS it will target the <link></link> nodes in the WordPress xml source and use the discovered values as the new file paths for the carried over pages. Because the default WordPress export will generate a fully qualified path referencing the old WordPress site we will need to remove the website root to get a useful root-relative path. Consider this value within the sample XML for a Library page: `<link>https://www.gallena.edu/academics/library</link>`. 

	- In this example, you should enter `https://www.gallena.edu` into the `SOURCE_URL_BASE` variable so that `https://www.gallena.edu/academics/library` will become `/academics/library`. **It is highly recommended that you copy and paste this value from an entry in the source xml to ensure accuracy.**

	- As the script processes each URL, it will place the migrated files into the root-relative path defined by the `<link>` value with `SOURCE_URL_BASE` removed (or it will be defined in the migration map, if used). The generated files will then be output maintaining the URL structure within the defined `OUTPUT_ROOT`. 

	- In our example, after we upload the new pages to Omni CMS this page will have a full URL that would look something like `http://dev.your-ou-site.edu/academics/library.php` when published, and relative to the Omni CMS root on staging, the file would look something like `/academics/library.pcf`. 

 - Created Content Variables
	- This set of variables defines common filenames, and content for navigation files. Most of these can likely be left alone, as they are configured to standard Omni CMS implementations, but the following two variables should be adjusted if necessary: 

		1. OUTPUT_EXTENSION 
			- This should be set to the extension of published pages on your production server. The most common values for this are: "html", "php", and "aspx". 

		2. INDEX_NAME 
			- When a user navigates to a folder on the server, the index page for that folder will be served by default. So, going to `https://www.your-school.edu` will actually serve up a page like `http://www.your-school.edu/index.html` or `https://www.your-school.edu/default.html` depending on how the server is configured. 
			- Update this variable to be "index" or "default" depending on your server setup. In general, an Apache/PHP server will use "index" and a Windows/ASP server will use "default". 

	- Additional variables that can be set are: 

		1. NAV_FILENAME
			- This defines the name of the section navigation file for the implementation, typically left as `/_nav.inc`. 

		2. NAV_TAG
			- This tag will be written to each section navigation file created during the process, which is typically left as the standard provided, but can be adjusted if you have defined it differently for your implementation. 

		3. PROPS_FILENAME
			- This defines the name of the section properties file for the implementation, typically left as `/_props.pcf`.

 - WP_PLUGIN_CODE_DISPLAY
	- These configurations give users a variety of options on how to handle WordPress (wp) plugin tags within the xml export's content. Accepted values are: 
		- "as_is" - does not update wp tags
		- "span" - (default) places wp tags and any contained content within custom `<span>` tags
		- "comment_tags" - comments out the wp tags surrounding their content, leaving the tagged content intact
		- "comment_all" - comments out the wp tags including their content
		- "none" - deletes the wp tags and their content
	- The output generated from the default value of "span" can generate a display to notify the user of the plugin code in Omni CMS when editing pages by adding the following XSL to your `common.xsl` just before the closing `</xsl:stylesheet>` node. When previewing or publishing the page, this XSL will remove the custom `<span>` tags added from the script so the final display is not affected. 

	```
		<!-- output wp plugin spans on edit -->
		<xsl:template match="span[@data-type='wp-plugin']" mode="#all">
			<xsl:variable name="wp-plugin-content"><xsl:apply-templates select="node()"/></xsl:variable>
			<xsl:choose>
				<xsl:when test="$ou:action ='edt'">
					<div style="border: 1px solid #c3e6cb; margin: 0px;">
						<div style="background-color: #d4edda; border-bottom: 1px solid #c3e6cb; color: #155724; vertical-align:top; margin:0px!important; padding:10px;">
							<p style="margin: 0;"><strong>WordPress plugin found:</strong><br/>
								<em>[ <xsl:value-of select="@data-name"/><xsl:text> </xsl:text><xsl:value-of select="span[@data-type='wp-plugin-attribute']" /> ]</em></p>
						</div>
						<div style="padding:10px; margin:0px;">
							<p style="margin: 0;"><strong>Plugin content shown below:</strong></p>
							<xsl:choose>
								<xsl:when test="normalize-space($wp-plugin-content) = ''"><em>No plugin content found</em></xsl:when>
								<xsl:otherwise><xsl:apply-templates select="$wp-plugin-content" /></xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:template>
		<!-- remove wp plugin attribute spans -->
		<xsl:template match="span[@data-type='wp-plugin-attribute']" mode="#all" />
	```

	\*Some implementations may use a `mode="copy"` when calling `xsl:apply-templates` throughout the implementation as a "recursive copy template" or "identity match". If your implementation uses this code (you can check by looking at your existing XSL and see if an `xsl:apply-templates` contains the `mode="copy"` attribute), then you will need to add `mode="copy"` to all 3 instances of `xsl:apply-templates` in the above XSL so that it will function as expected. 

### Run the Migration Script
 1. Open a Command Prompt or Terminal window and navigate to your migration folder.
 2. Run the command: `ruby migrate_from_wp.rb`
 3. Wait until the script finishes and you see that `Finished` is displayed on standard output. 

### Upload Migration Output to Omni CMS.
 1. After you have run your script and generated your output files (to the OUTPUT_ROOT directory), add them into a zip file. 
 2. Login to Omni CMS and go to Pages view. Typically you will want to upload the migration to the root of your site, though you can upload to a subfolder to get a general idea of what the migration will look like first. 
 3. Upload the zip file to Omni CMS using the Zip Import feature, checking the "Overwrite Existing Files" box to ensure the the navigation, properties, and index files at the root will be overwritten with the files generated by the script. 
 	- Correct any errors that the Zip Import may identify, if present, as the "Finish Upload" button will not become active until all identified errors are addressed. This will most commonly occur if there are files or folders that contain characters that are not supported by Omni CMS, or if the name exceeds 128 characters. 
 4. Once the upload is complete, open the migrated PCF pages to see how the migrated pages appear. Additional, manual cleanup may be required at this point to present the content in more complex elements that may have been built out as part of the implementation, or to adjust any other content that looks different than desired, or to update/remove outdated content. 
 5. Publish out the uploaded files using a site or folder publish and correct any errors that may have been reported during the publishing process. This is typically due to migrated content with encodings or structures that are different than what Omni CMS or your implementation is expecting. 

## Migrating Binaries
In addition to migrating content from your WordPress site, you will likely want to copy over any images or other binary (non-text) files into Omni CMS. This script does not handle migration of any binary files, but if you have a standard WordPress installation, any files that you have uploaded will be placed in `/wp-content/uploads/` on your server with month/year folders further organizing the data. The process to migrate these files into Omni CMS is as follows: 
 1. Download a copy of the entire `/wp-content/uploads/` folder to your local machine, typically accessed through SFTP or a similar connection. These files should be compressed into a Zip file using software such as 7-Zip or whatever compression tool you prefer. 
 2. Upload the images to Omni CMS to the same file location using Omni CMS' Zip Import feature. Please be sure that the files are uploaded to a corresponding `/wp-content/uploads/` folder structure in Omni CMS (you may need to create these folders before upload, depending on how you zipped the binary files). 
 3. Publish all the uploaded files so they will be available on the Production server and will be viewable on your pages. If your WordPress installation automatically generated references to your files using fully qualified URLs, you should run a Find and Replace to ensure these references are pointing to the Omni CMS files instead of the original files that are presumably still live. 
 4. If Binary Management is enabled (highly recommended) run a Dependency Scan on the site so all references to the uploaded binary files are tracked by Omni CMS. Once this is complete, you should then be able to move any of these images to other locations in the site and/or rename the `wp-content` and `uploads` folders and all references should be preserved. 

## Cleanup
Once you have completed the scripted migration process, it is recommended that you look through your pages and perform any manual cleanup that may be required for your previous elements to display as desired in Omni CMS. Typically this will include recreating any plugin functionality with Omni CMS tools, or adjusting data structures from an old design to a new design, where the HTML/JS/CSS is expecting different classes and HTML structures to render the pages than they required previously. 

## Troubleshooting
If you are missing content or something is not coming across as expected after uploading to Omni CMS, the following guidelines will help you narrow down the issue, but adjustments would require updates to the Ruby scripts from a more technical person. Here are some general troubleshooting tips: 

 1. Check the various log files generated by the migration script. These contain a lot of additional information that can provide information on the pages processed, issues encountered, and the plugin code that was encountered in the content region. 
 2. Make sure you exported the desired elements in your WordPress export. If content does not appear in the `<content:encoded>` or basic nodes, such as `<title>`, within a page's `<item>` node, then the content will not be pulled in by the script. 
 3. Republish in OU and look for the errors log after publish completes. This may provide some insights into what your Omni CMS implementation is expecting and narrow down where an issue may exist. 
 4. If you notice that there is a `Invalid argument @ dir_s_mkdir` error, double check the SOURCE_URL_BASE variable is *exactly* the same as the items in the XML Source file(s). 
 5. Sometimes a WordPress export will have special characters in the content, such as a NUL charaacter <0x00>. This can prevent the script from processing the file past the special character. If this occurs, the best solution is to find the special character that is causing the issue, then do a bulk replace of that character with a simple character (or remove it). When you run the script again on this modified source, it should process the full data set. 
 	- One way to narrow down where a problematic character is located in a WordPress XML export is to add a log statement to `/migrate_from_wp.rb`, line 63: `@log.puts xml_doc.to_s`. This will output the entire contents of the source file as tidied up by the Nokogiri library to the log file. If there is a special character interfering with the parsing, the file should be cut off in the log, allowing you to more easily isolate which node the problem character is at. 
