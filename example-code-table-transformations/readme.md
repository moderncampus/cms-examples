***The included source code, service and information is provided as is, and OmniUpdate makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of OU Campus.***

# Table Transformations

This package contains all the basic code that is needed to get started using Table Transformation snippets on your site. All of the HTML structures presented in these snippets is based upon Bootstrap, though the XSL can be modified to allow for other custom outputs. 

## Overview

OU Campus uses editable regions to make editing pages easy. The WYSIWYG editor has many great features that allow you to insert, edit, and format your content in a variety of ways without the need for the end user to understand how the underlying code functions. However, there is often a need to add a more complex HTML element on a page that cannot be easily edited in the WYSIWYG. Typically, these elements would need to be identified and managed in a separate location than the editable region. This can be accomplished through solutions such as Assets or modifying the XSL templates to allow for MultiEdit or some other mechanism to handle the complex HTML element that lies between two editable regions. 

In such cases, it can sometimes be useful to employ Table Transformation snippets, which allow the user to drop a more complex HTML structure in the middle of an editable region with a simpler, more form-based editable experience utilizing a table. When the edits are made and the page saved, the previewed and published page will show the complex HTML structure, but the editing experience will utilize a simple table, which the WYSIWYG editor can manipulate and edit easily. 

In short, the end user can simply insert the desired Table Transformation snippet from the toolbar, edit the content in the table, and see the complex output without ever having to touch a line of code. They can still preview and publish out the complex HTML, but when they enter the editable region containing the snippet, all they will see is an easy to edit table with the information they wish to display on the page. 

## Components

Each table transformation consists of the following components:

1. An HTML table that can be added to an editable region. 
2. CSS to style the table editing experience. 
3. An XSL template match to transform the table. 

The HTML table should be structured in logical way that accurately represents the data being entered. For instance, in the accordion snippet provided in this package, the table is divided into a series of rows. Each row consists of two columns, one for the heading and one for the content of the accordion item. In reality, any logical table structure can be transformed into a different output by harnessing the power of XSL transformations. 

## Using the Starter Code

The following steps will allow you to add table transformations to an existing implementation. 

1. **Upload the table-transformations.xsl file** to `/_resources/xsl/_toolkit/`. This is where the template matches for each new table transformation will be placed. This should be imported from the standard `/_resources/xsl/common.xsl` file so it will be available on your pages. 
2. **Ensure that the XSL Identity Matches exist** (typically placed in `/_resources/ou/_shared/template-matches.xsl` and are imported from `/_resources/xsl/ou/common.xsl`). This package contains code for the Identity Matches in the template-matches.xsl file, but if it's not in the suggested location, it should be placed in a central, shared location. In addition, any regions that will utilize a template match should be called in the XSL using <xsl:apply-templates> instead of <xsl:copy-of>. Otherwise, the content will never be matched and the tables will not be transformed into the desired output. 
3. **Upload the table-transformations.css file** to `/_resources/ou/editor/` and add the following line to the current wysiwyg.css file in that same directory: `@import 'table-transformations.css';`. This enables styling for all tables that will be transformed. This file can be edited for additional helper text for individual table transformations as well, using standard CSS styles. 
4. **Upload each of the table transformation snippet files from this package** (located in `/snippets`) to `/_resources/snippets` or another desired location. Each of these files will need to then be added to OU Campus as snippets, which will allow the end user to insert the table transformations into their editable regions. More information on how to do this step can be found on the [OU Campus Support Site](https://support.omniupdate.com/learn-ou-campus/snippets/create-manage.html). 

## Creating a New, Custom Table Transformation

To create a new table transformation snippet to add to your site, upload the CSS/XSL from this package as described in "Using the Starter Code" above. Then follow the steps below to expand the functionality with your own custom code. 

### Step 1: Identify the HTML structure you would like the table transformation to output.

This should be code that will display correctly if the HTML structure can be placed inside the HTML structure of your page where your editable region(s) exist. Any additional code necessary to facilitate the display should be put in place on the site, such as any necessary CSS or JS code for the HTML output. 

### Step 2: Create a table structure that logically maps to the content.

The primary purpose of a table transformation is to make code more easily editable to users who aren't skilled in source code. As such, care should be taken in determining a table structure that will:

1. Encapsulate all the data that should be edited.
2. Be easy for the end user to understand and edit. 
3. Have a logical pattern that can be targeted with XSL to produce the desired output. 

It is usually easiest to create your table in a PCF page's editable region using OU Campus' source code editor. During the XSL development of the transformation, it is easy to then preview the page to see the effect the XSL code has on the table. 

_The table will need a specific, unique identifier._ Typically this is achieved by adding a class to the table. This allows the XSL to target the table and transform its contents. The CSS in this package has been created to style all tables that have a class beginning with `omni-` for consistency. 

### Step 3: Code the XSL to transform the content.

This is where the magic happens, as this code will match the table we have created, grab the content, and output it into the desired HTML structure. 

1. Match the table.

	Add a new XSL template match to `/_resources/xsl/_toolkit/table-transformations.xsl`. The match will target the table created in Step 2 above by targeting a specific, unique identifier for the table. This code should look something like the following: 

	```
	<xsl:template match="table[@class='omni-accordion']">
	<!-- HTML output goes here -->
	</xsl:template>
	```

	This example matches the accordion table, but the class could easily be called `omni-mytable`. Any HTML placed inside this template match will then be output in place of the table. 

2. Grab the content.

	Since we are utilizing XSL, we will use XPath to grab the content we need to target. There are two basic methods for targeting the content for a table transformation: direct access of each element or looping through an unknown number of rows. In either case, we need to keep in mind the context when we are writing XPath. In the case of a table transformation, our initial context will always be the table we have matched. Here are a couple of examples of how you can target content for each of these methods. 

	First, we can access each element directly. In this case we could use an XPath such as `tbody/tr[1]/td[1]/node()` to grab the entire HTML contents of the first cell in the first row of the table body. This could be modified to target any cell.

	Second, we can loop through the table rows. This is common for elements such as an accordion, where we would like the user to be able to create an arbitrary number of rows, each row corresponding to an accordion element (heading and content). Typically, this would be accomplished through a for-each statement, such as `<xsl:for-each select="tbody/tr">`. Once we are inside this loop, the XPath statements only need to target the content inside the table row, as the context will have changed at this point (sample XPath: `td[1]`). 

3. Output into a new HTML structure.
	
	The instructions to this point allow for you to grab the specific content from the table so it can be outputted in the new structure. To create the output, all that is left is to add that output to the XSL and add the appropriate `apply-templates` or `value-of` statements to output the content, using the XPath discussed above. `apply-templates` is used instead of `copy-of` so that each element can be matched within the content instead of outputting the entire content as a single block. `value-of` is used to output text only and does not preserve any of the node structure in the targeted content. 

Putting these 3 steps together, a typical flow to code this would be to first create the template match and then paste the desired output into the table. If there is a repeated structure based off the table, surround one of those elements in a loop and remove the rest. Then replace the content with XSL expressions utilizing XPath to place content from the table in the proper locations. If all goes well, at this point you should be able to make changes in the table and see it reflected in the HTML structure it was transformed into. 

### Step 4: Create Snippet File

This simply consists of taking your new table structure and saving it as a new HTML file with no additional code. The snippet files in this package are under `/_resources/snippets/`. 

### Step 5: Add Snippet to OU Campus

Adding the snippet to OU Campus will allow the end user to enter an editable region and add the table transformation snippet on the page. This step takes the raw source code from the snippet file and inserts it into the editable region, ready for adding and editing content. More information on how to do this step can be found on the [OU Campus Support Site](https://support.omniupdate.com/learn-ou-campus/snippets/create-manage.html). 