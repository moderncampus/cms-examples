***The included source code, service and information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of Omni CMS.***

# Structured Data
- The files in this directory are intended to generate structured data in JSON-LD format. Additional information, entities, and attributes can be found on the [schema.org](https://schema.org) website.
## What is Structured Data and Why is it important?
- 'Structured Data' is a standardized format for providing information about a page and classifying the page content. This aids Search Engine Optimization by helping top search engines; Google, Bing, Yandex, and Yahoo understand the context of the page.
>Google Search can enable a rich set of features for your page in search results if it understands the content of the page and, in some circumstances, if you explicitly provide additional information in the page code using structured data. These features fall into two general categories:

> **Content type:** Many search features are tied to the topic of your page. For example, if the page has a recipe or a news article, or contains information about an event or a book. Google Search results can then apply content-specific features such as making your page eligible to appear in a top news stories carousel, a recipe carousel, or an events list.

> **Enhancements:** These are features that, can be applied to more than one kind of content type. For example, providing review stars for a recipe or movie, or exposing a carousel of rich results (previously known as rich cards).

>There is no guarantee that your page will appear in Search results with the specified feature. This is because search features depend on many factors, including the search device type, location, and whether Google thinks the feature would provide the best search experience for the user.

*the above quote is from the following Google page https://developers.google.com/search/docs/guides/search-features*

When building additional structured data templates be sure to test the output using [Google's Structured Data Validation tool](https://search.google.com/structured-data/testing-tool) to validate additional items 

## Types
Below is a list of current XSL templates: 
 1. Blog Posting 
 2. News Article
### Blog Posting
Structured data for Blog Postings should contain the following:
```
Type - hardcoded in XSL
Headline - from page parameter heading 
datePublished - date created in Omni CMS 
dateModified - date published in Omni CMS
image - first one in main content or hardcoded in XSL (Absolute URL w/ height and width to scale appropriately)
author - page parameter or user First & Last name
publisher - entity or university
publisher logo - hardcoded in XSL (Absolute URL w/ height and width to scale appropriately)
```
### News Articles
Structured data for News Articles should contain the following:
```
Type - hardcoded in XSL
Headline - from page parameter heading 
datePublished - date created in Omni CMS 
dateModified - date published in Omni CMS
image - first one in main content or hardcoded in XSL (Absolute URL w/ height and width to scale appropriately)
author - page parameter or user First & Last name
publisher - entity or university
publisher logo - hardcoded in XSL (Absolute URL w/ height and width to scale appropriately)
```
## How to Install
1. Upload the Structured Data folder into your XSL folder
2. Import each XSL file into the relevant XSL using `xsl:import`. Example "structured-data-blog-posting.xsl" into "blog-post.xsl" or  "structured-data-news-article.xsl" into "news-article.xsl"
3. At the end of your "Page Content" the following to call the structured data code:
	- `<xsl:call-template name="blog-posting-structured-data" />` - Blog Post
	- `<xsl:call-template name="news-article-structured-data" />` - News Article
4. Configure the following depending on type
	- Blog Custom Image Settings (`blog-custom-image-items`) defines where the blog image should be pulled from
	- News Article Image Settings (`news-custom-image-items`) defines where the News Article should be pulled from
5. View and Publish one page that has this code output in the HTML source
6. Run through validator from `https://search.google.com/structured-data/testing-tool`
7. Configure and change options as needed
