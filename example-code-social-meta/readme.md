***The included source code, service and information is provided as is, and OmniUpdate makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of OU Campus.***

# Social Meta Tags

Social meta tags can allow you to control your site content that is shown when a link is shared on a social media network. If unused, the social media network will attempt to glean the information from your page in some other way. There are two main types of meta tags that you can add to the `<head>` of your source code to send this information. 
	1. Open Graph tags (created by Facebook)
	2. Twitter Card tags

## Open Graph Tags

Facebook's Open Graph tags are recognized by most social networks, including Facebook, LinkedIn, and Google+. If there are no Twitter Cards present on a page, Twitter will also use Open Graph tags. Each Open Graph tag starts with `og:` followed by the name of the tag. This package will insert some basic Open Graph tags and populate them with specific content from your page using XSL, which can then be customized to pull from different content areas if desired. 

### Default Output

By default, the following Open Graph tags will be outputted, pulling content from the location specified below:

| Open Graph Tag | Tag Description | Content Location | 
| --- | --- | --- | 
| `og:image` | The URL of the image that appears when someone shares the content to Facebook. | Directory Variable: `og-image` | 
| `og:title` | The title of your article without any branding such as your site name. | The page's `<title>` node, found by the XPath expression: `ouc:properties/title/text()`. | 
| `og:url` | The canonical URL for your page. This should be the undecorated URL, without session variables, user identifying parameters, or counters. | The page's fully qualified URL when published from OU Campus. | 
| `og:description` | A brief description of the content, usually between 2 and 4 sentences. | The page's meta description content, found by the XPath expression: `ouc:properties/meta[@name='description']/@content`. | 
| `og:site_name` | The name that you would like your website to be recognized by. | Directory Variable: `og-site-name` | 
| `og:type` | The type of media of your content. This tag impacts how your content shows up in News Feed. | This is hardcoded to the default value of `website`. | 
| `fb:admins` | A comma-separated list of either Facebook user IDs or a Facebook Platform application ID that administers this page. | Directory Variable: `fb-admins` | 
| `fb:app_id` | Facebook Application ID | Directory Variable: `fb-app_id` | 

Any of these values can be removed and/or new items added from Open Graph by modifying the provided `social-meta.xsl` file, allowing you to customize the values passed to social networks as they scan your pages. 

## Twitter Card Tags

Twitter Card tags are used in a similar way as Open Graph tags and start with `twitter:` followed by the name of the tag. This package will insert some basic Twitter Card tags and populate them with specific content from your page using XSL, which can then be customized to pull from different content areas if desired. 

From the Twitter developer website: 
*"When the Twitter card processor looks for tags on a page, it first checks for the Twitter-specific property, and if not present, falls back to the supported Open Graph property. This allows for both to be defined on the page independently, and minimizes the amount of duplicate markup required to describe content and experience."*

### Default Output

By default, the following Twitter Card tags will be outputted, pulling content from the location specified below:

| Twitter Card Tag | Tag Description | Content Location | 
| --- | --- | --- | 
| `twitter:card` | The card type, used with all cards. | This is hardcoded to `summary` in the `social-meta.xsl`. | 
| `twitter:site` | @username of website. | Directory Variable: `twitter-site` | 
| `twitter:creator` | @username of content creator | Directory Variable: `twitter-creator` | 

### Optional Output

The following Twitter cards are commented out in the XSL by default, as Twitter will pull this information from the equivalent Open Graph tags described above. When used, these tags will take precendence over the Open Graph tags when the Twitter card processor looks for tags on a page. 

| Twitter Card Tag | Tag Description | Content Location | 
| --- | --- | --- | 
| `twitter:url` | The canonical URL for your page. This should be the undecorated URL, without session variables, user identifying parameters, or counters. | The page's fully qualified URL when published from OU Campus. | 
| `twitter:title` | Title of content (max 70 characters) | The page's `<title>` node, found by the XPath expression: `ouc:properties/title/text()`. | 
| `twitter:description` | Description of content (maximum 200 characters) | The page's meta description content, found by the XPath expression: `ouc:properties/meta[@name='description']/@content`. | 
| `twitter:image` | URL of image to use in the card. Images must be less than 5MB in size. | Directory Variable: `twitter-image`. Defaults to `og-image` directory variable if left blank. |

## Using the Starter Code

Perform the steps below to automatically add social media meta tags to your OU Campus pages.

1. **Upload** the `social-meta.xsl` file to OU Campus.
 - This XSL file should be placed in `/_resources/xsl/_shared/`. XSL files do not need to be published, but it is recommended to [save a version](https://support.omniupdate.com/learn-ou-campus/pages-files/review/versions.html) each time changes are made. 

2. **Update existing XSL** to use the social meta tags code. This will require modifying `common.xsl` or another XSL file that outputs content within a page's `<head>` tag. Once you have located this key file, make the adjustments to this file as described below. 
 - *Import* the `social-meta.xsl` file. This statement should look something like the following: `<xsl:import href="_shared/social-meta.xsl" />`. This should be a page-relative path from the XSL that is importing this code. 
 - *Call the XSL Template* from within the `<head>` tag using the following statement: `<xsl:call-template name="social-meta" />`. 

3. **Verify** the social meta tags are working by one of the following methods: 
 - Preview a page in OU Campus and view the frame source, or Publish a page from OU Campus and view the page source. You should see a series of Open Graph and Twitter Card tags appearing within the page's `<head>` tag. If you do not see these tags, ensure the page you are testing with is using the XSL that was modified, or is importing the XSL that was modified to call this package's social meta template. 
 - Publish a page from OU Campus that uses this XSL, then go to a social media network and put a link to the published page in the post. Typically, you can see a preview of the information before posting and can visually verify the social media meta tags are populating the post information from the information in OU Campus. 