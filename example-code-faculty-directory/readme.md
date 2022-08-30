***The included source code, service and information is provided as is, and OmniUpdate makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of OU Campus.***

# Faculty Directory - with jQuery Datatables

This package contains all the basic code that is needed to add a simple Faculty Directory to your site. **This code is intended to be added to an existing implementation or the starter package**, which includes standard OU code skeleton files, such as common.xsl and other shared XSL files. This solution, while created for faculty, could also function as a directory for generic profiles or staff listings. 

OU is not held responsible for your misuse, and support for this code will be limited to pointing out where to find your own solutions. 

## Overview

The Faculty Directory code provided in this package provides a simple, XSL-based solution that allows for easy creation and maintenance of a faculty directory, consisting of a number of profile pages and a listing page that aggregates the information from each individual profile page into a consolidated list. This solution ensures the profiles all follow a standard layout that remains consistent across each profile and pulls them together as a whole. In addition, this makes it possible to easily grab important information for display on a listing page. 

This package provides code for a listing page that will utilize the jQuery DataTables library by default. With some XSL knowledge, it is possible to adjust this code to output other custom HTML structures and their supporting code. 

Once this package is implemented, you will be able to easily create profile, modify, and delete profile pages in a special Faculty Directory section. Through XSL, you will then be able to aggregate them automatically into a listing page for display and easy navigation within the directory. 

## End User Workflow

Once it is implemented, the basic process to create a faculty directory is as follows:

### Step 1: Use the included template to create a new profile section, where the faculty directory will live. 

The profile section template will create a new folder, with the standard \_nav.inc and \_props.pcf files. The main listing page for the faculty directory will also be created as the index page. 

### Step 2: Begin creating the profile pages.

Use the New Page Wizard to create the individual profile pages. Each page should then be populated with the appropriate information. In particular, the MultiEdit fields are important in order to standardize the output that will be aggregated into the listing page. 

### Step 3: Publish all unpublished or modified profile pages. 

This is a very important step in the process. Publishing each profile not only publishes the profile's page, but also an individual XML data file containing the information that will be aggregated into the listing page. **Unpublished profiles will NOT appear in the directory listing.** 

### Step 4: Publish/Republish the listing page. 

Since this solution utilizes XSL to aggregate the profile data files, the listing page must be published after a profile is modified and published. When published, the listing page will scan all published XML files in the directory and aggregate them into the listing. If a profile is not published, this scan will not see that profile and it will be omitted from the listing. 

Thus, the publishing order should always be:
 1. Publish any updated profile pages.
 2. Update the listing page for those profiles.

## Components

The Faculty Directory solution consists of the following components:

File | Required | Description
---- | -------- | -----------
helper.xsl | YES | Helps the profile.xsl.
profile-xml.xsl | YES | Generates the xml output of your profiles, be sure to call this file in your PCF.
profile.xsl | YES | Where the magic happens.
\_profile_section.tcf | YES | Creates a new profile section, update as necessary.
profile.tcf | YES | Starts the creation of a new individual profile page.
profile.tmpl | YES | Finalizes the individual profile creation process, creates a MultiEdit page for each profile.  Suggestion would be to base this off an existing template in the site and copy over the profile node with the MultiEdit.
profile_landing.tmpl | YES | Creates the profile landing page to list the profiles. From the \_profile_section.tcf.

## Using the Starter Code

The following steps will allow you to add a simple Faculty Directory to your templates. 

1. **Upload the package files** to their respective locations, as reflected in the directory structure. 
 - XSL files should be placed in `/_resources/xsl/_profiles/`. These files do not need to be published, but it is recommended to [save a version](https://support.omniupdate.com/learn-ou-campus/pages-files/review/versions.html) each time changes are made. 
 - TCF/TMPL files should be placed in your site's templates folder, typically `/_resources/xsl/ou/templates/`. If your site uses Remote templates as defined in the [site settings](https://support.omniupdate.com/learn-ou-campus/administration/setup/sites/settings.html#productionserverftpsettings), you will need to publish these files as well. 

2. **Update the PCF files** with the information you wish to display. You may add or remove the given fields to contain the information you would like displayed in your faculty directory. 
 - **All information that should be aggregated to the listing page must appear as MultiEdit fields in the <profile> node.** This is important to ensure the data is consistent for the individual XML output for each profile. 

3. **Update the XSL** to transform the data from the PCF into the desired HTML output, using `profile.xsl` for the listing and individual profile views. 
 - This solution assumes that the listing and individual profile pages will share a common global structure. The XSL template named `faculty-profile` is called where the page types will different in their output. 
 - The XSL will determine which view is used by the presence (or absence) of the <profile> node. If a <profile> node is present in a PCF, then it will be treated as a profile page; otherwise it will be treated as a listing page. 
 - The individual profile page output pulls from a profile page's data within the <profile> node, adding an `href` attribute for the link if needed in the output. For outputting the data, simply use the ouc:div's label attribute value (replacing spaces with underscores) as the element name. For example, 
 ```
 <ouc:div label="firstname" group="Everyone" button="hide"><ouc:multiedit type="text" prompt="First Name" alt="First Name"/>John</ouc:div>
 ``` 
 can be referenced in the template match for "profile" as 
 ```
 <xsl:value-of select="firstname" />
 ``` 
  - Update helper.xsl, line 19, with your output extension so the proper links will be generated on the listing page. The default in this package shows `.html`. 
  - If your implementation does not use the current OU Campus starter templates, you will need to be sure the XSL template named page-template is either called or updated to what your XSL uses. The same goes for the headcode/footcode. 
  - If you already have an interior template, it may be helpful to copy the code from your interior XSL and change the call to the main content editable region to a call to page-template, such as:
 ```
 <xsl:call-template name="page-template" />
 ```

#### Notes

Here are some helpful things to remember/note about this code:

1. Include all of the files in all the right places, probably common.xsl.
2. Double check your paths to all files, even images, before you think it's broken.
3. Don't forget to include profile-xml.xsl in your individual profile pcf as well as your listing page pcf, like so: 
```
<?pcf-stylesheet path="/_resources/xsl/profiles/profile-xml.xsl" alternate="yes" extension="xml"?>
```
4. Don't forget to update the helper.xsl on line 21 with your server side scripting language.
5. If you are already using jQuery on your site, make sure the DataTables JavaScript file is called ***after*** jQuery or it will not initialize. 

#### jQuery dataTables Reference

* [https://datatables.net/](https://datatables.net/)
* [https://github.com/DataTables/DataTables](https://github.com/DataTables/DataTables)

