***The included source code, service and information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of Modern Campus CMS.***

# XSL Breadcrumbs

The `breadcrumb.xsl` code here provides a mechanism to build out breadcrumbs for pages in a section by recursively checking the breadcrumb settings in each of the parent sections and the current section for titles. Each breadcrumb up the tree will link to the index/default page of the section, with a final breadcrumb appearing for pages that are not index/default pages. 

Users who wish to implement this code should have a basic understanding of XSL and the implementation skeleton. 

Every folder has breadcrumb settings, which has the following options:
 - Section Title. This is the text for the breadcrumb. If empty, it will use the folder name.
 - Skip. When selected, this folder will be skipped in the breadcrumbs.
 - Stop. When selected, the breadcrumbs up to this point will stop, and this breadcrumb will become the new root for the breadcrumbs that follow.

## Example

In the `breadcrumb.xsl` there is an `<xsl:choose>` block that handles the various cases for the breadcrumbs.
 - `$type = 'skipped'` handles when the breadcrumb is skipped. By default, it'll display "System Message: Breadcrumb Skipped at [PATH_NAME]." as defined in `cms-breadcrumb.xsl`. The message will only display on staging.
 - `$type = 'root'` handles the root of the breadcrumb path.
 - `$type = 'index'` handles index pages. On index pages, this will display as the last breadcrumb instead of the curr type.
 - `$type = curr` handles the current page.
 - The `<xsl:otherwise>` block handles all other cases.

 Within the xsl, there are a few values of the `$folder` variable that can be used:
 - `breadcrumb` is the breadcrumb title.
 - `@level` is the depth level.
 - `@path` is the path to the folder.

As well as that, the HTML that surrounds the breadcrumbs can be set within the `<xsl:template name="output-breadcrumbs">` template.

The breadcrumb code can then be called from another XSL as needed to create the output in the appropriate location of the output. 

```
<xsl:call-template name="output-breadcrumbs" />
```

### Dependencies

This code requires the files `variables.xsl`, `functions.xsl`, and `cms-breadcrumb.xsl` which are typically included for an implementation. Samples of these two files are also included in this package. 