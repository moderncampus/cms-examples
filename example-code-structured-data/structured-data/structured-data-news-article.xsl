<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY amp   "&#38;">
<!ENTITY copy   "&#169;">
<!ENTITY gt   "&#62;">
<!ENTITY hellip "&#8230;">
<!ENTITY laquo  "&#171;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY lsquo   "&#8216;">
<!ENTITY lt   "&#60;">
<!ENTITY nbsp   "&#160;">
<!ENTITY quot   "&#34;">
<!ENTITY raquo  "&#187;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY rsquo   "&#8217;">
]>
<!-- 
Structured Data JSON-LD output

News Article
Structured data for a News Article should contain the following:

	Type - hardcoded in XSL
	Headline - from page parameter heading
	datePublished - date created in Omni CMS
	dateModified - date published in Omni CMS
	image - first one in main content or hardcoded in XSL (Absolute URL w/ height and width to scale appropriately)
	author - page parameter or user First & Last name
	publisher - entity or university
	publisher logo - hardcoded in XSL (Absolute URL w/ height and width to scale appropriately)

****additional values and options can be included. See https://schema.org/NewsArticle for more information
Use Google's Structured Data Validation tool https://search.google.com/structured-data/testing-tool# to validate additional items 

Contributors: Modern Campus, Inc. Web Developers
Last Updated: 1/21/2019
-->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
	exclude-result-prefixes="xs ou fn ouc">
	
	<!-- dependencies, can be removed if you already have the following parameters/variable declared -->
	<!-- Active user/publisher last name-->
	<xsl:param name="ou:lastname"/>
	<!-- Active user/publisher first name -->
	<xsl:param name="ou:firstname"/>
	<!-- Page Creation date/time -->
	<xsl:param name="ou:created" as="xs:dateTime"/>
	<!-- Last Page Modification date/time -->
	<xsl:param name="ou:modified" as="xs:dateTime"/>
	<!-- Root-relative path to page output -->
	<xsl:param name="ou:path"/>
	<!-- Address of Target Production Server (from site settings) -->
	<xsl:param name="ou:httproot"/>
	<!-- Returns the $ou:httproot without a slash -->
	<xsl:variable name="domain" select="substring($ou:httproot,1,string-length($ou:httproot)-1)" />
	<!-- end dependencies -->
	
	<!-- News Article Publisher Settings. Includes the College Name, Logo Reference, Logo Height and Logo Width -->
	<xsl:variable name="news-publisher-settings">
		<settings>
			<name>College Name</name>
			<logo>http://www.example.edu/_resources/images/logo.png</logo>
			<logo-height>44</logo-height>
			<logo-width>244</logo-width>
		</settings>
	</xsl:variable>
	
	<!-- News Article Default Image Settings, when no image is provided. Includes Type, Full Image Path, Image Height, Image Width  -->
	<xsl:variable name="news-default-image-items">
		<defaults>
			<type>ImageObject</type>
			<image>http://www.example.edu/images/default.png</image>
			<height>44</height>
			<width>244</width>
		</defaults>
	</xsl:variable>
	
	<!-- News Article Custom Image Settings. Define where the news image should be pulled from. Includes Condition(when should this be used), Type, Full Image Path, Image Height, Image Width -->
	<xsl:variable name="news-custom-image-items">
		<xsl:variable name="first-image" select="/document/ouc:div[@label='maincontent']/descendant::img[1]" />
		<custom>
			<type>ImageObject</type>
			<!-- condition when should we use the custom news image, needs to be 'true' to be used -->
			<condition><xsl:value-of select="$first-image/@src != ''" /></condition>
			<image><xsl:value-of select="if (contains($first-image/@src,'//')) 
										then $first-image/@src else 
										concat($domain,$first-image/@src)"/></image>
			<height><xsl:value-of select="$first-image/@height"/></height>
			<width><xsl:value-of select="$first-image/@width"/></width>
		</custom>
	</xsl:variable>
	
	<!-- Function to help with the output of the XML structure for JSON conversion -->
	<xsl:function name="ou:create-string-key">
		<xsl:param name="key" />
		<xsl:param name="value" />
		<fn:string key="{$key}"><xsl:value-of select="$value" /></fn:string>
	</xsl:function>
	
	<!-- Function to help output the XML for JSON conversion with conditional -->
	<xsl:function name="ou:create-string-key">
		<xsl:param name="key" />
		<xsl:param name="value" />
		<xsl:param name="default-value" />
		<xsl:param name="condition" />
		<fn:string key="{$key}"><xsl:value-of select="if ($condition = 'true') then $value else $default-value" /></fn:string>
	</xsl:function>
	
	<!-- Check to see if News Article Author is a page parameter, otherwise pull from the author from the current user -->
	<xsl:variable name="news-author" select="if (/document/descendant::parameter[@name='author'] != '') then 
											 /document/descendant::parameter[@name='author'] else
											 concat($ou:firstname, ' ', $ou:lastname)" />
	
	<!-- Variable to hold the news headline or title -->
	<xsl:variable name="news-headline" select="/document/descendant::parameter[@name='heading']" />
	
	<!-- Output the News Article Structured Data -->
	<xsl:template name="news-article-structured-data">
		<xsl:text>&#xa;</xsl:text>
		<script type="application/ld+json">
			<!-- create a variable of XML structure to convert to JSON -->
			<xsl:variable name="news-xml-for-json">
				<map xmlns="http://www.w3.org/2005/xpath-functions">
					<xsl:copy-of select="ou:create-string-key('@context', 'https://schema.org')" />
					<xsl:copy-of select="ou:create-string-key('@type', 'newsArticle')" />
					<map key="mainEntityOfPage">
						<xsl:copy-of select="ou:create-string-key('@type', 'WebPage')" />
						<xsl:copy-of select="ou:create-string-key('@id', $domain || $ou:path)" />
					</map>
					<xsl:copy-of select="ou:create-string-key('headline', $news-headline)" />
					<map key="image">
						<xsl:copy-of select="ou:create-string-key('@type', $news-custom-image-items/custom/type, $news-default-image-items/defaults/type, $news-custom-image-items/custom/condition)" />
						<xsl:copy-of select="ou:create-string-key('url', $news-custom-image-items/custom/image, $news-default-image-items/defaults/image, $news-custom-image-items/custom/condition)" />
						<xsl:copy-of select="ou:create-string-key('height', $news-custom-image-items/custom/height, $news-default-image-items/defaults/height, $news-custom-image-items/custom/condition)" />
						<xsl:copy-of select="ou:create-string-key('width', $news-custom-image-items/custom/width, $news-default-image-items/defaults/width, $news-custom-image-items/custom/condition)" />
					</map>
					<xsl:copy-of select="ou:create-string-key('datePublished', $ou:created)" />
					<xsl:copy-of select="ou:create-string-key('dateModified', $ou:modified)" />
					<map key="author">
						<xsl:copy-of select="ou:create-string-key('@type', 'Person')" />
						<xsl:copy-of select="ou:create-string-key('name', $news-author)" />
					</map>
					<map key="publisher">
						<xsl:copy-of select="ou:create-string-key('@type', 'Organization')" />
						<xsl:copy-of select="ou:create-string-key('name', $news-publisher-settings/settings/name)" />
						<map key="logo">
							<xsl:copy-of select="ou:create-string-key('@type', 'ImageObject')" />
							<xsl:copy-of select="ou:create-string-key('url', $news-publisher-settings/settings/logo)" />
							<xsl:copy-of select="ou:create-string-key('height', $news-publisher-settings/settings/logo-height)" />
							<xsl:copy-of select="ou:create-string-key('width', $news-publisher-settings/settings/logo-width)" />
						</map>
					</map>
				</map>
			</xsl:variable>
			<!-- convert XML structure to JSON -->
			<xsl:value-of select="xml-to-json($news-xml-for-json)" />
		</script>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
</xsl:stylesheet>