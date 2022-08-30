***The included source code, service and information is provided as is, and OmniUpdate makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of OU Campus.***

# A to Z Index

This package contains the code needed to take an OU Campus sitemap and output a list of each page in the sitemap at the time the page is published. The default styling for the output uses Bootstrap, which can be adjusted with CSS/XSL for different output structures and styles. 

## Using the Starter Code

The following steps will allow you to create an A-Z index page to an existing implementation. 

1. **Upload the az-index.xsl file** to `/_resources/xsl/`. 

2. **Modify the XSL** as needed to output the desired markup and fit with the rest of your normal "interior" page design. This package expects the standard `common.xsl` file will call a template named "page-content", which is where the magic happens. 

3. **Create a new PCF file** based off your normal "interior" page design, then change pcf-stylesheet declaration to point to the `az-index.xsl` file.

## End User Workflow

Once it is implemented, the managing an A-Z index is a simple process. To modify the links that appear, follow the steps below:

1. Manage the content that will appear or not appear on the A-Z index. Utilize the "Exclude from Sitemap" access setting for directories or pages that you do not want to have displayed. All pages that should appear on the A-Z index will need to be published before moving to the next step.

3. Publish the Sitemap.xml for the site.

4. Publish the A-Z index page.

More information about OU Campus' sitemap can be found on the [OU Campus Support Site](https://support.omniupdate.com/learn-ou-campus/administration/setup/sites/index.html#publish).

## Additional Information

- The Index listing displays the page title for all pages that it can find a title for. If the title is not available, you will see the page's URL displayed. 
- The A-Z Index will only display pages that are listed with a particular extension. The extension is determined by the XSL parameter "extension", which should be uncommented and adjusted at the top of `/_resources/xsl/az-index.xsl` if it is not previously defined (commonly available in `/_resources/xsl/_shared/variables.xsl`). 