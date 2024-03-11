***The included source code, service and information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of Modern Campus CMS.***

# Content Migration Tool

The Modern Campus Content Migration Tool utilizes Ruby scripts to allow for bulk processing of source files to produce Modern Campus CMS PCF files that are ready to use. 

## Required Gems
	- Nokogiri: `gem install nokogiri` or `sudo gem install nokogiri`
	- OS: `gem install OS` or `sudo gem install OS`

## Global (\_global)
	- Contains the global methods and classes for all migrations.
	- ***This is always needed for all migrations.***

## Skeletons

Choose the appropriate package depending on the type of migration you expect to perform as follows:

1. `migrate_shell_csv.rb`
	- Used to create a shell site, given a migration map (CSV format). 
2. `migrate_from_source.rb`
	- Used to perform a 1-to-1 migration from a set of source files. 
3. `migrate_from_csv.rb`
	- Used to perform a migration from a set of source files, rearchitecting the files during migration using a migration map (CSV format). 

Once you have chosen the appropriate skeleton package, you will need to adjust the configuration (`config.rb`) with the proper variables, set your templates (ERB files within `/templates`) to match the Modern Campus CMS PCF output required for your implementation, and target your content using XPath (within the appropriate migrate method in `methods.rb`). 

Once the above has been completed and the script has been run, it will output a file package that can then be zipped and uploaded into Modern Campus CMS for immediate use. 

## Additional Customization

Since this package contains the Ruby source code necessary to run a migration, it is completely customizable and can be adapted for any condition you can consistently target with your code. For example, if you find your source files consistently have an additional `<div>` within the main content region you have targeted, additional conditions could be programmatically added to target the extraneous elements and remove them from the content. This allows the programmer much more flexibility to refine a migration to fit the needs of any given use case.