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
					Implementation Core Skeleton - 08/24/2018, Do NOT Change
					
					IMPLEMENTATION VARIABLES
					Define global implementation variables here, so that they may be accessed by all page types and in the info/debug tabs.
					This also provides a convenient area for complicated logic to exist without clouding up the general xsl/html structure.
-->

<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<!-- OU CAMPUS SYSTEM PARAMETERS - don't edit -->
	<!-- Current Page Info -->
	
	<!-- Page 'state' in OU Campus (prv = Preview, pub = Publish, edt = Edit, cmp = Compare) -->
	<xsl:param name="ou:action"/>
	<!-- Unique Page ID -->
	<xsl:param name="ou:uuid"/>
	<!-- Root-relative path to page output -->
	<xsl:param name="ou:path"/>
	<!-- Root-relative path to current folder (USE "dirname" BELOW INSTEAD) -->
	<xsl:param name="ou:dirname"/>
	<!-- Filename of output -->
	<xsl:param name="ou:filename"/>
	<!-- Page Creation date/time -->
	<xsl:param name="ou:created" as="xs:dateTime"/>
	<!-- Last Page Modification date/time -->
	<xsl:param name="ou:modified" as="xs:dateTime"/>
	<!-- Path (root-relative) to RSS Feed that's assigned to current page -->
	<xsl:param name="ou:feed"/>
	
	<!-- Staging Server Info -->
	<!-- Staging Server's Domain Name -->
	<xsl:param name="ou:servername"/>
	<!-- Path from root of staging server -->
	<xsl:param name="ou:root"/>
	<!-- Site Name (same as foldername on staging server) -->
	<xsl:param name="ou:site"/>
	<!-- Staging path of the file -->
	<xsl:param name="ou:stagingpath"/>
	
	<!-- Production Server Info -->
	<!-- Name of Target Production Server -->
	<xsl:param name="ou:target"/>
	<!-- Address of Target Production Server (from site settings) -->
	<xsl:param name="ou:httproot"/>
	<!-- Folder path to site root on Production Server (from site settings) -->
	<xsl:param name="ou:ftproot"/>
	<!-- Initial subdirectory for site root on Production Server (from site settings) -->
	<xsl:param name="ou:ftphome"/>
	
	<!-- User Info -->
	<!-- Active user/publisher username-->
	<xsl:param name="ou:username"/>
	<!-- Active user/publisher last name-->
	<xsl:param name="ou:lastname"/>
	<!-- Active user/publisher first name -->
	<xsl:param name="ou:firstname"/>
	<!-- Active user/publisher email address-->
	<xsl:param name="ou:email"/>
	
	<!-- custom directory variables for reading global include files -->
	<!-- for multisite setups they need to exist on the same server -->
	<!-- where is the main domain for multisite setup -->
	<xsl:param name="ou:www-domain" />
	<!-- where is the main ftp root for multisite setup -->
	<xsl:param name="ou:www-ftproot" />
	
	<!-- for the following, all are set with start and end slash: /folder/ -->
	<!-- top level breadcrumb start position used in the breadcrumb.xsl -->
	<xsl:param name="ou:breadcrumb-start"/>
	<!-- top level breadcrumb in a cleaned fashion -->
	<xsl:variable name="breadcrumb-start" select="if (ends-with($ou:breadcrumb-start, '/')) then $ou:breadcrumb-start else concat($ou:breadcrumb-start, '/')"/>
	
	<!-- standard navigation start directory variable for navigation, must start with a slash -->
	<xsl:param name="ou:navigation-start"/>
	<!-- $ou:navigation-start directory variable cleaned with a slash as the end -->
	<xsl:variable name="navigation-start" select="if ($ou:navigation-start = '') then $dirname
		else (if (ends-with($ou:navigation-start, '/'))
				then $ou:navigation-start else concat($ou:navigation-start, '/'))"/>
	
	<!-- navigation file for the implementation -->
	<xsl:variable name="nav-file" select="'_nav.inc'" />
	<!-- current navigation location for the implementation -->
	<xsl:variable name="navigation-path" select="$navigation-start || $nav-file" />
	
	<!-- GLOBAL VARIABLES - Implementation Specific -->
	<!-- Stores a body class that can be used on the HTML -->
	<xsl:variable name="body-class" />
	
	<!-- for various concatenation purposes -->
	<!-- Returns the $ou:dirname with a slash appended to it -->
	<xsl:variable name="dirname" select="if(string-length($ou:dirname) = 1) then $ou:dirname else concat($ou:dirname,'/')" />
	<!-- Returns the $ou:httproot without a slash -->
	<xsl:variable name="domain" select="substring($ou:httproot,1,string-length($ou:httproot)-1)" />
	
	<!-- section property files -->
	<!-- Returns the props file filename -->
	<xsl:variable name="props-file" select="'_props.pcf'"/>
	<!-- Returns the current props file path -->
	<xsl:variable name="props-path" select="concat($ou:root, $ou:site, $dirname, $props-file)"/>
	<!-- Returns the doc() of current props file path -->
	<xsl:variable name="props-doc" select="if(doc-available($props-path)) then doc($props-path) else ()"/>
	
	<!-- page information -->
	<!-- Returns the page type pcf param -->
	<xsl:variable name="page-type" select="ou:pcf-param('page-type')"/>
	<!-- Returns the page title from properties -->
	<xsl:variable name="page-title" select="/document/ouc:properties/title" />
	<xsl:variable name="breadcrumb" select="ou:pcf-param('breadcrumb')" />
	<!-- Returns the page heading pcf param -->
	<xsl:variable name="page-heading" select="ou:pcf-param('heading')" />
	<!-- Returns the full page publish path -->
	<xsl:variable name="page-pub-path" select="$domain || $ou:path" />
	
	<!-- OU Campus action state variables -->
	<!-- Returns true if the page is in Publish Mode -->
	<xsl:variable name="is-pub" select="$ou:action = 'pub'"/>
	<!-- Returns true if the page is in Edit Mode -->
	<xsl:variable name="is-edt" select="$ou:action = 'edt'"/>
	<!-- Returns true if the page is in Preview Mode -->
	<xsl:variable name="is-prv" select="$ou:action = 'prv'"/>
	<!-- Returns true if the page is in Compare Mode -->
	<xsl:variable name="is-cmp" select="$ou:action = 'cmp'"/>
	<!-- Returns true if the page is NOT in Publish or Compare Mode -->
	<xsl:variable name="not-pub" select="not($is-pub)"/>
	<!-- Returns true if the page is NOT in Edit Mode -->
	<xsl:variable name="not-edt" select="not($is-edt)"/>
	<!-- Returns true if the page is NOT in Preview Mode -->
	<xsl:variable name="not-prv" select="not($is-prv)"/>
	<!-- Returns true if the page is NOT in Compare Mode -->
	<xsl:variable name="not-cmp" select="not($is-cmp)"/>
	
	<!-- Debug mode -->
	<xsl:variable name="debug" select="0"/>
	
</xsl:stylesheet>