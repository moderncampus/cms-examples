***The included source code, service and information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of Modern Campus CMS.***

# XSL Breadcrumbs

The `breadcrumb.xsl` code here provides a mechanism to build out breadcrumbs for pages in a section by recursively checking a file in each of the parent sections and the current section for the breadcrumb titles. Each breadcrumb up the tree will link to the index/default page of the section, with a final breadcrumb appearing for pages that are not index/default pages. 

Users who wish to implement this code should have a basic understanding of XSL and the implementation skeleton. 

 - This code assumes that a section properties file (`_props.pcf`) is being used to extract section titles for each section. 
 - If there aren't any section properties files, the XSL can be modified to check the page title of the index/default page of each section instead.
 - If the user leaves the breadcrumb value empty or enters the value of "$skip", the build out will skip the breacrumb for that folder. 

## Example

The breadcrumb code can be called from another XSL as needed to create the output in the appropriate location of the output. 

```
<xsl:call-template name="breadcrumb">
	<xsl:with-param name="path" select="$ou:dirname"/>								
</xsl:call-template>
```

### Dependencies

This code requires the files `variables.xsl` and `functions.xsl`, which are typically included for an implementation. Samples of these two files are also included in this package. 
