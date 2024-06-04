***The included source code, service and information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of Modern Campus CMS.***

# Tag Management XSL API

Tags in Modern Campus CMS are used to sort and filter pages, files, and assets to make them easier to locate. This package contains code that makes it more convenient to take advantage of Modern Campus CMS tags programatically by using XSL to call the Modern Campus CMS Tag Management API. More information about the XSL API for Tag Management can be found on the [Modern Campus CMS Support Site](http://support.omniupdate.com/oucampus10/site-development/xsl-advanced/xsl-tag-data.html).

## Using the Starter Code

Use these files to play around with the Tag Management XSL API.

1. **Upload the files** to Modern Campus CMS.
 - The XSL files should be placed in `/_resources/xsl/_tag-management/`. These files do not need to be published, but it is recommended to [save a version](https://support.moderncampus.com/cms/pages-files/review/versions.html) each time changes are made. 
 - *The `examples-for-application.xsl` file does not need to be uploaded into the site; simply open the file and copy/paste code snippets from the file into other XSL files, such as the standard `common.xsl`.*
 - Upload `tagdemo.pcf` to any directory in your site. It never needs to be published, so it can basically go wherever you would like to put it.

2. **Preview tagdemo.pcf** and ensure that there are no XSL errors.
 - There are several page parameters that highlight the basic use of the different Tag Management XSL API functions available in this package. Multiple tags should be set, including at least one set of Fixed Tags in order to view results for all the API calls. 

3. **Build on the provided code and functionality** presented in this package and create your own solutions to use on your site! 

## Additional Information

 - Tags are not site specific and are shared across an account. 
 - Tags can be managed under **Setup > Tags**, but can be created directly from individual pages as well. 
 - You can create groupings of tags called collections, or merge tags together to consolidate them. 
 - Tag Access for directories can be utilized to control which tags can be applied to any pages or files within the directory. More information about the XSL API for Tag Management can be found on the [Modern Campus CMS API Reference Site](https://developers.omniupdate.com/).