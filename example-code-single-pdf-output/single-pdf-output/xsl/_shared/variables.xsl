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
=========================
Variables
System variables and other variables
Applicable to individual pdf output and web output.
=========================
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
	<xsl:param name="ou:action"/>		<!-- Page 'state' in OU Campus (prv = Preview, pub = Publish, edt = Edit, cmp = Compare) -->
	<xsl:param name="ou:uuid"/>		<!-- Unique Page ID -->
	<xsl:param name="ou:path"/>		<!-- Root-relative path to page output -->
	<xsl:param name="ou:dirname"/>		<!-- Root-relative path to current folder (USE "dirname" BELOW INSTEAD) -->
	<xsl:param name="ou:filename"/>		<!-- Filename of output -->
	<xsl:param name="ou:created" as="xs:dateTime"/>		<!-- Page Creation date/time -->
	<xsl:param name="ou:modified" as="xs:dateTime"/> 	<!-- Last Page Modification date/time -->
	<xsl:param name="ou:feed"/>		<!-- Path (root-relative) to RSS Feed that's assigned to current page -->
	
	<!-- Staging Server Info -->
	<xsl:param name="ou:servername"/>	<!-- Staging Server's Domain Name -->
	<xsl:param name="ou:root"/>		<!-- Path from root of staging server -->
	<xsl:param name="ou:site"/>		<!-- Site Name (same as foldername on staging server) -->
	<xsl:param name="ou:stagingpath"/>		<!-- Staging path of the file -->
	
	<!-- Production Server Info -->
	<xsl:param name="ou:target"/>		<!-- Name of Target Production Server -->
	<xsl:param name="ou:httproot"/>		<!-- Address of Target Production Server (from site settings) -->
	<xsl:param name="ou:ftproot"/>		<!-- Folder path to site root on Production Server (from site settings) -->
	<xsl:param name="ou:ftphome"/>		<!-- Initial subdirectory for site root on Production Server (from site settings) -->
	
	<!-- User Info -->
	<xsl:param name="ou:username"/>		<!-- Active user/publisher -->
	<xsl:param name="ou:lastname"/>		<!-- Active user/publisher -->
	<xsl:param name="ou:firstname"/> 	<!-- Active user/publisher -->
	<xsl:param name="ou:email"/>		<!-- Active user/publisher -->	
	
	<!-- for various concatenation purposes -->
	<xsl:variable name="dirname" select="if(string-length($ou:dirname) = 1) then $ou:dirname else concat($ou:dirname,'/')" />
	<xsl:variable name="domain" select="substring($ou:httproot,1,string-length($ou:httproot)-1)" />
	
	<!-- extension -->
	<xsl:variable name="extension" select="'html'" />
	
	<!-- page information -->
	<xsl:variable name="page-title" select="/document/ouc:properties/title" />
	<xsl:variable name="heading" select="ou:pcf-param('heading')" />
	
	<!-- OU Campus action state variables -->
	<xsl:variable name="is-pub" select="$ou:action = ('pub')"/> <!-- Returns true if the page is in Publish -->
	<xsl:variable name="is-edt" select="$ou:action = 'edt'"/> 	<!-- Returns true if the page is in Edit Mode -->
	<xsl:variable name="is-prv" select="$ou:action = 'prv'"/> 	<!-- Returns true if the page is in Preview Mode -->
	<xsl:variable name="is-cmp" select="$ou:action = 'cmp'"/> 	<!-- Returns true if the page is in Compare Mode -->
	<xsl:variable name="not-pub" select="not($is-pub)"/> 		<!-- Returns true if the page is NOT in Publish -->
	<xsl:variable name="not-edt" select="not($is-edt)"/> 		<!-- Returns true if the page is NOT in Edit Mode -->
	<xsl:variable name="not-prv" select="not($is-prv)"/> 		<!-- Returns true if the page is NOT in Preview Mode -->
	<xsl:variable name="not-cmp" select="not($is-cmp)"/> 		<!-- Returns true if the page is NOT in Compare Mode -->
	
</xsl:stylesheet>