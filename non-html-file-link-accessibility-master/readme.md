***The included source code, service, and the information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for all users and may not be compatible with all implementations of Omni CMS.***

# Non-HTML File Link Accessibility
**This tool is only intended to be used on Omniupdate CMS sites running PHP on their production server.**

This tool is designed to help websites meet accessibility standards. It was specifically built to address W3C's Success Criterion 2.4.4. 

The full Success Criterion 2.4.4 documentation can be found here: https://www.w3.org/TR/UNDERSTANDING-WCAG20/navigation-mechanisms-refs.html

Another accessibility standards document that was taken into consideration during the creation of this tool can be found here: https://www.digital.govt.nz/standards-and-guidance/design-and-ux/usability/linking-to-non-html-files?rf=1

### What does Non-HTML File Link Accessibility Links do?

This tool dynamically appends file information to on-page, non-HTML file links. Specifically, the script adds a respective filetype as text after the link text displayed for the on-page, non-HTML file.
 - Following the generated filetype text, the file size is displayed upon publish via PHP script.
 - Both the filetype text and filesize text are incorporated into the on-page file link. 
 - If a linked file is changed, any pages linking to that file will need to be republished for the new filesize to appear on those pages. 

### What file extensions does Non-HTML File Link Accessibility identify?
   ```
    -pdf
    -doc || docx
    -ppt || pptx
    -xls || xlsx
   ```
With some minor modifications to the code, you can also update, remove or add file extensions types for identification.

### Installation of Non-HTML File Link Accessibility.
1. Download this repository as a Zip file. 
2. Upload the downloaded Non-HTML File Link Accessibility Zip file to the root of our Omni CMS site using Omni CMS' Zip Import feature, which will also extract the files for you. 
3. After the upload is complete, navigate to `/_resources/php/non-html-file-link-accessibility` and publish this entire folder. 
4. Add `<xsl:import href="_shared/non-html-file-link-accessibility.xsl"/>` to the import statements near the top of your `common.xsl` file, often located at `/_resources/xsl/common.xsl`.
  	- You may need to adjust this path and/or the XSL file location depending on your particular setup.
  	- If you do not have a `common.xsl` or would like this to only affect a certain set of pages, add the import statement to the appropriate location in your XSL. 

### Testing Non-HTML File Link Accessibility
After installation no other steps should be needed. The file type and size should start rendereding next to on-page, non-html links on subsequent preview and publish actions for applicable page. 

To ensure everything is functioning correctly after the installation, we have included some test content in this package. To utilize them, paste these links into an editable region's source on any PCF page calling the `xsl:import` statement in step 4 of the installation instructions:

```
<p><a href="/_resources/php/non-html-file-link-accessibility/sample/sample.pdf"> PDF: Click to download this file</a></p>
<p><a href="/_resources/php/non-html-file-link-accessibility/sample/sample.xlsx"> Excel: Click to download this file</a></p>
<p><a href="/_resources/php/non-html-file-link-accessibility/sample/sample.pptx"> Powerpoint: Click to download this file</a></p>
<p><a href="/_resources/php/non-html-file-link-accessibility/sample/sample.docx"> Documents: Click to download this file</a></p>
<p><a href="/_resources/php/non-html-file-link-accessibility/sample/nonexistent.docx"> Nonexistent File: Click to download this file</a></p>
```

### Troubleshooting Non-HTML File Link Accessibility.
If you have any trouble getting the functionality to work correctly, please try the following troubleshooting steps: 

1. Make sure the site has PHP enabled.
2. Make sure PHP script and icon files are published out. 
3. If the Zip file was uploaded somewhere other than the root of the site, you will likely have to adjust paths in `non-html-file-link-accessibility.xsl`.
4. If the file type that you are trying to target is not included in the list of file types that this script identifies, it will need to be manually added to `non-html-file-link-accessibility.xsl`. 
5. Ensure any URL that you are trying to target with this code is valid. 
6. If you have an older implementation that is using `mode="copy"`, you will need to add that to each XSL template match and apply-templates statement in order for the XSL to run correctly. 