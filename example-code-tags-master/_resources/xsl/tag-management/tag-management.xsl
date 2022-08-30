<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
<!ENTITY copy   "&#169;">
]>
<!--
TAG MANAGEMENT FUNCTIONS AND VARIABLES

This file contains the variables and functions necessary to bring in data from Tag Management onto a page.
This file should be imported by common.xsl, so all files that want to use/display tags are able to do so.

Contributors: Brandon Scheirman and Robert Kiffe
Last updated: 7/26/16
-->
<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">
	<!-- 

********	Variables  

-->
	<xsl:param name="ou:stagingpath" select="concat(substring-before($ou:path, '.'), '.pcf')" />

	<xsl:variable name="page-tags-csv" select="string-join(ou:get-combined-tags($ou:stagingpath, $ou:site)/tag/name, ', ')" />

	<!-- This version of page-tags-csv only grabs enabled tags -->
	<xsl:variable name="enabled-page-tags-csv" select="string-join(ou:get-combined-tags($ou:stagingpath, $ou:site)/tag[disabled/text()='false']/name, ', ')" />

<!--
	
********	Functions
Tag Management data is brought onto a page via a document() call in XSL that then makes an API call. We've made these functions so you don't have to write out a document() call each time you want to retrieve data about tags.
The final two functions in this section are what make the doc() calls themselves. All of the other functions ultimately call one of these two functions.

-->

	<!--
	GET PAGE TAGS
	Grabs all the tags that have been manually applied to a particular page.
	Passing no parameters into the function initially returns data about the current page.
	Passing one parameter into the function initially returns data about a specified page on the same site.
	Passing two parameters into the function initially returns data about a specified page on a specified site.
	-->

		<!-- PARAMETERS: None -->
		<xsl:function name="ou:get-page-tags">

			<xsl:sequence select="ou:get-page-tags($ou:stagingpath, $ou:site)" />
		</xsl:function>

		<!-- PARAMETERS: Staging Path -->
		<xsl:function name="ou:get-page-tags">
			<xsl:param name="path" />

			<xsl:sequence select="ou:get-page-tags($path, $ou:site)" />
		</xsl:function>

		<!-- PARAMETERS: Staging Path, Site  -->
		<xsl:function name="ou:get-page-tags">
			<xsl:param name="path" />
			<xsl:param name="site" />

			<xsl:variable name="tags-api" select="concat('ou:/Tag/GetTags?site=', $site,'&amp;path=', encode-for-uri($path))" />
			<xsl:copy-of select="ou:get-tags($tags-api)" />
		</xsl:function>

	<!--
	GET FIXED TAGS
	Grabs any fixed tags that have been applied to a directory through the Tag Access dialog box. The API call cannot have a trailing slash, so there is logic in the function that will strip the trailing slash if one has been added.
	Passing no parameters into the function initially returns data about the current directory.
	Passing one parameter into the function initially returns data about a specified directory on the same site.
	Passing two parameters into the function initially returns data about a specified directory on a specified site.
	-->

		<!-- PARAMETERS: None -->
		<xsl:function name="ou:get-fixed-tags">

			<xsl:sequence select="ou:get-fixed-tags($ou:dirname, $ou:site)" />
		</xsl:function>

		<!-- PARAMETERS: Staging Path -->
		<xsl:function name="ou:get-fixed-tags">
			<xsl:param name="path" />

			<xsl:sequence select="ou:get-fixed-tags($path, $ou:site)" />
		</xsl:function>

		<!-- PARAMETERS: Staging Path, Site  -->
		<xsl:function name="ou:get-fixed-tags">
			<xsl:param name="path" />
			<xsl:param name="site" />
			
			<xsl:variable name="directory" select="if (string-length($path) gt 1 and ends-with($path, '/')) then substring($path, 1, string-length($path)-1) else $path"/>

			<xsl:variable name="tags-api" select="concat('ou:/Tag/GetFixedTags?site=', $site,'&amp;path=', encode-for-uri($directory))" />
			<xsl:copy-of select="ou:get-tags($tags-api)" />
		</xsl:function>

	<!--
	GET COMBINED TAGS
	Grabs all tags (fixed tags and manually-applied tags) that have been applied to a page.
	Passing no parameters into the function initially returns data about the current page.
	Passing one parameter into the function initially returns data about a specified page on the same site.
	Passing two parameters into the function initially returns data about a specified page on a specified site.
	-->
	
		<!-- PARAMETERS: None -->
		<xsl:function name="ou:get-combined-tags">

			<xsl:sequence select="ou:get-combined-tags($ou:stagingpath, $ou:site)" />
		</xsl:function>

		<!-- PARAMETERS: Staging Path -->
		<xsl:function name="ou:get-combined-tags">
			<xsl:param name="path" />

			<xsl:sequence select="ou:get-combined-tags($path, $ou:site)" />
		</xsl:function>

		<!-- PARAMETERS: Staging Path, Site  -->
		<xsl:function name="ou:get-combined-tags">
			<xsl:param name="path" />
			<xsl:param name="site" />

			<xsl:variable name="tags-api" select="concat('ou:/Tag/GetCombinedTags?site=', $site,'&amp;path=', encode-for-uri($path))" />
			<xsl:copy-of select="ou:get-tags($tags-api)" />
		</xsl:function>

	<!--
	GET ALL TAGS
	Grabs all tags that have been added to the specified site.
	-->
	<xsl:function name="ou:get-all-tags">
		<xsl:variable name="tags-api" select="'ou:/Tag/GetAllTags'" />

		<xsl:sequence select="ou:get-tags($tags-api)" />
	</xsl:function>

	<!--
	GET CHILDREN TAGS
	Grabs any tags that belong to a specified collection.
	-->
	<xsl:function name="ou:get-children-tags">
		<xsl:param name="tag" />

		<xsl:variable name="tags-api" select="concat('ou:/Tag/GetChildren?tag=', $tag)" />

		<xsl:sequence select="ou:get-tags($tags-api)" />	
	</xsl:function>

	<!--
	GET PARENT TAG
	Grabs any collections that the specified tag belongs to.
	-->
	<xsl:function name="ou:get-parent-tags">
		<xsl:param name="tag" />

		<xsl:variable name="tags-api" select="concat('ou:/Tag/GetParents?tag=', $tag)" />

		<xsl:sequence select="ou:get-tags($tags-api)" />	
	</xsl:function>

	<!--
	GET FILES WITH ANY TAGS
	Grabs any pages that contain one or more of the specified tags. The API call passes each tag individually through a URL query string. THe function appends '&amp;tag=' between each tag in the list.
	Passing one parameter into the function initially returns data about a specified list of tags on the same site.
	Passing two parameters into the function initially returns data about a specified list of tags on a specified site.
	-->
	
		<!-- PARAMETERS: Tag List -->
		<xsl:function name="ou:get-files-with-any-tags">
			<xsl:param name="tag-list" />

			<xsl:sequence select="ou:get-files-with-any-tags($tag-list, $ou:site)" />
		</xsl:function>

		<!-- PARAMETERS: Tag List, Site -->

		<xsl:function name="ou:get-files-with-any-tags">
			<xsl:param name="tag-list" />
			<xsl:param name="site" />
			
			<xsl:variable name="formatted-tags" select="replace($tag-list,'[,;]\s*','&amp;tag=')" />

			<xsl:variable name="tags-api" select="concat('ou:/Tag/GetFilesWithAnyTags?site=', $site, '&amp;tag=', $formatted-tags)" />
			<xsl:sequence select="ou:get-pages($tags-api)" />
		</xsl:function>	
	
	<!--
	GET FILES WITH ALL TAGS
	Grabs any pages that contain all of the specified tags. The API call passes each tag individually through a URL query string. THe function appends '&amp;tag=' between each tag in the list.
	Passing one parameter into the function initially returns data about a specified list of tags on the same site.
	Passing two parameters into the function initially returns data about a specified list of tags on a specified site.
	-->
	
		<!-- PARAMETERS: Tag List -->
		<xsl:function name="ou:get-files-with-all-tags">
			<xsl:param name="tag-list" />

			<xsl:sequence select="ou:get-files-with-all-tags($tag-list, $ou:site)" />
		</xsl:function>

		<!-- PARAMETERS: Tag List, Site -->

		<xsl:function name="ou:get-files-with-all-tags">
			<xsl:param name="tag-list" />
			<xsl:param name="site" />
			
			<xsl:variable name="formatted-tags" select="replace($tag-list,'[,;]\s*','&amp;tag=')" />

			<xsl:variable name="tags-api" select="concat('ou:/Tag/GetFilesWithAllTags?site=', $site, '&amp;tag=', $formatted-tags)" />
			<xsl:sequence select="ou:get-pages($tags-api)" />
		</xsl:function>

	<!--
	TAGS API DOC CALL
	Outputs an XML file with the following format:
	<tags>
		<tag>
			<name>tagName</name>
			<disabled>true|false</disabled>
			<children>[integer value]</children>
		</tag>
		<tag>
			...
		</tag>
	</tags>
	-->
	
	<xsl:function name="ou:get-tags">
		<xsl:param name="api" />

		<xsl:try>
			<xsl:sequence select="doc($api)/tags" />
			<xsl:catch>
				<tags></tags>
			</xsl:catch>
		</xsl:try>
	</xsl:function>

	<!--
	PAGES API DOC CALL
	Outputs an XML file with the following format:
	<pages>
		<page>
			<path>/root/relative/path/to/file.pcf</path>
			<last-pub-date>[date and time stamp]</last-pub-date>
		</page>
		<page>
			...
		</page>
	</pages>
	-->
	
	<xsl:function name="ou:get-pages">
		<xsl:param name="api" />

		<xsl:try>
			<xsl:sequence select="doc($api)/pages" />
			<xsl:catch>
				<pages></pages>
			</xsl:catch>
		</xsl:try>
	</xsl:function>

</xsl:stylesheet>
