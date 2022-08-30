***The included source code, service and information is provided as is, and OmniUpdate makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of OU Campus.***

# Authors

@updated - 5/23/17

There are two versions of the Authors section.

## Basic: 
The basic package is for displaying a small about the author section at the bottom of post pages. Rather than have an author enter in this information for each blog post, they can create a PCF for storing this information. Then, this author file can be chosen and pulled from via page parameters on the blog post PCF. The parameters also include the ability to choose between an editable region on the page (for single time authors etc.) or pulling information from the author PCF.

### Files:
	* author-lite.xsl - lightweight author XSL for info storage.
	* author-lite.pcf - author sample PCF.
	* extras.html - contains snippets for the about the author section to place in post PCF and XSL.


### Steps:

1. Upload author-lite.xsl
2. Create /authors folder in blog and upload author-lite.pcf
3. Add page parameters and editable region from extras.html to the blog post PCF.
4. Add author content from extras.xsl to post.xsl


## Full:
Extending from the basic package, the full version contains a profile page for the author with similar information and a blog listing of all posts by the respective author. In addition, there is an index page which aggregates all authors in the folder and displays them in a listing with links to their profiles. 

*Side Note: It is not necessary to have the about the author section above for these profiles to work... but they do work nicely together.*

### Files:

* author.xsl - the profile page and listing page XSL.
* helper.xsl - the aggregate functions for listing page.
* author.pcf - author sample PCF.
* index.pcf - the author listing page.
* extras.html - contains snippets for the about the author section to place in post PCF and XSL.

### Steps:

1. Upload author.xsl and helper.xsl
2. Create /authors folder in blog and upload author.pcf and index.pcf

To use the about the author section on post pages:

3. Add page parameters and editable region from extras.html to the blog post PCF.
4. Add author content from extras.xsl to post.xsl
