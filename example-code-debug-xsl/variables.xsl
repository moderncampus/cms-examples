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
	Implementations Skeleton - 07/24/2018

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
	
	<!-- Omni CMS SYSTEM PARAMETERS - don't edit -->
	<!-- Current Page Info -->
	<xsl:param name="ou:action"/>					 <!-- Page 'state' in Omni CMS (prv = Preview, pub = Publish, edt = Edit, cmp = Compare) -->
	<xsl:param name="ou:uuid"/>						 <!-- Unique Page ID -->
	<xsl:param name="ou:path"/>						 <!-- Root-relative path to page output -->
	<xsl:param name="ou:dirname"/>					 <!-- Root-relative path to current folder (USE "dirname" BELOW INSTEAD) -->
	<xsl:param name="ou:filename"/>					 <!-- Filename of output -->
	<xsl:param name="ou:created" as="xs:dateTime"/>	 <!-- Page Creation date/time -->
	<xsl:param name="ou:modified" as="xs:dateTime"/> <!-- Last Page Modification date/time -->
	<xsl:param name="ou:feed"/>						 <!-- Path (root-relative) to RSS Feed that's assigned to current page -->
	
	<!-- Staging Server Info -->
	<xsl:param name="ou:servername"/>	<!-- Staging Server's Domain Name -->
	<xsl:param name="ou:root"/>			<!-- Path from root of staging server -->
	<xsl:param name="ou:site"/>			<!-- Site Name (same as foldername on staging server) -->
	<xsl:param name="ou:stagingpath"/>	<!-- Staging path of the file -->
	
	<!-- Production Server Info -->
	<xsl:param name="ou:target"/>	<!-- Name of Target Production Server -->
	<xsl:param name="ou:httproot"/>	<!-- Address of Target Production Server (from site settings) -->
	<xsl:param name="ou:ftproot"/>	<!-- Folder path to site root on Production Server (from site settings) -->
	<xsl:param name="ou:ftphome"/>	<!-- Initial subdirectory for site root on Production Server (from site settings) -->
	
	<!-- User Info -->
	<xsl:param name="ou:username"/>		<!-- Active user/publisher -->
	<xsl:param name="ou:lastname"/>		<!-- Active user/publisher -->
	<xsl:param name="ou:firstname"/> 	<!-- Active user/publisher -->
	<xsl:param name="ou:email"/>		<!-- Active user/publisher -->
	
	<!-- custom directory variables for reading global include files -->
	<!-- for multisite setups they need to exist on the same server -->
	<xsl:param name="ou:www-domain" /> <!-- where is the main domain -->
	<xsl:param name="ou:www-ftproot" /> <!-- where is the main ftp root -->
	
	<!-- DIRECTORY VARIABLES (add "ou:" before variable name - in XSL only)
		Example: 
		<xsl:param name="ou:theme-color" /> 
		... Where "theme-color" is the actual Directory Variable name
	-->
	
	<!-- for the following, all are set with start and end slash: /folder/ -->
	<xsl:param name="ou:breadcrumb-start"/> <!-- top level breadcrumb -->
	<xsl:variable name="breadcrumb-start" select="if (ends-with($ou:breadcrumb-start, '/')) then $ou:breadcrumb-start else concat($ou:breadcrumb-start, '/')"/>
	
	<!-- standard navigation start directory variable for navigation -->
	<xsl:param name="ou:navigation-start"/>
	<xsl:variable name="navigation-start" select="if ($ou:navigation-start = '') then $dirname 
		else (if (ends-with($ou:navigation-start, '/')) 
		then $ou:navigation-start else concat($ou:navigation-start, '/'))"/>
	
	<!-- GLOBAL VARIABLES - Implementation Specific -->
	<xsl:variable name="body-class" />	<!-- Stores a CSS class to be assigned to a wysiwyg region -->
	
	<!-- server information -->
	<xsl:variable name="server-type" select="'php'"/> 
	<xsl:variable name="index-file" select="'index'"/> 
	<xsl:variable name="extension" select="'html'"/>
	
	<!-- for various concatenation purposes -->
	<xsl:variable name="dirname" select="if(string-length($ou:dirname) = 1) then $ou:dirname else concat($ou:dirname,'/')" />
	<xsl:variable name="domain" select="substring($ou:httproot,1,string-length($ou:httproot)-1)" />
	
	<!-- navigation info -->
	<xsl:variable name="nav-file" select="'_nav.inc'" />
	
	<!-- section property files -->
	<xsl:variable name="props-file" select="'_props.pcf'"/>
	<xsl:variable name="props-path" select="concat($ou:root, $ou:site, $dirname, $props-file)"/>
	
	<!-- page information -->
	<xsl:variable name="page-type" select="ou:pcf-param('page-type')"/>
	<xsl:variable name="page-title" select="/document/ouc:properties/title" />
	<xsl:variable name="breadcrumb" select="ou:pcf-param('breadcrumb')" />
	<xsl:variable name="heading" select="ou:pcf-param('heading')" />
	
	<!-- Omni CMS action state variables -->
	<xsl:variable name="is-pub" select="$ou:action = ('pub','cmp')"/> 	<!-- Returns true if the page is in Publish or Compare Mode -->
	<xsl:variable name="is-edt" select="$ou:action = 'edt'"/> 			<!-- Returns true if the page is in Edit Mode -->
	<xsl:variable name="is-prv" select="$ou:action = 'prv'"/> 			<!-- Returns true if the page is in Preview Mode -->
	<xsl:variable name="is-cmp" select="$ou:action = 'cmp'"/> 			<!-- Returns true if the page is in Compare Mode -->
	<xsl:variable name="not-pub" select="not($is-pub)"/> 				<!-- Returns true if the page is NOT in Publish or Compare Mode -->
	<xsl:variable name="not-edt" select="not($is-edt)"/> 				<!-- Returns true if the page is NOT in Edit Mode -->
	<xsl:variable name="not-prv" select="not($is-prv)"/> 				<!-- Returns true if the page is NOT in Preview Mode -->
	<xsl:variable name="not-cmp" select="not($is-cmp)"/> 				<!-- Returns true if the page is NOT in Compare Mode -->
	
</xsl:stylesheet>