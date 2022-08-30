<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- Simple Site Skeleton 10/2/18 -->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:fn="http://omniupdate.com/XSL/Functions"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="ou xsl xs fn ouc">

	<!-- OU CAMPUS SYSTEM PARAMETERS - don't edit -->
	<xsl:param name="ou:action"/>
	<xsl:param name="ou:uuid"/>
	<xsl:param name="ou:path"/>
	<xsl:param name="ou:dirname"/>
	<xsl:param name="ou:filename"/>
	<xsl:param name="ou:created" as="xs:dateTime"/>
	<xsl:param name="ou:modified" as="xs:dateTime"/>
	<xsl:param name="ou:feed"/>
	<xsl:param name="ou:servername"/>
	<xsl:param name="ou:root"/>
	<xsl:param name="ou:site"/>
	<xsl:param name="ou:stagingpath"/>
	<xsl:param name="ou:target"/>
	<xsl:param name="ou:httproot"/>
	<xsl:param name="ou:ftproot"/>
	<xsl:param name="ou:ftphome"/>
	<xsl:param name="ou:username"/>
	<xsl:param name="ou:lastname"/>
	<xsl:param name="ou:firstname"/>
	<xsl:param name="ou:email"/>
	
	<!-- Implementation Specific Variables -->
	<!-- server information -->
	<xsl:param name="index-file" select="'index'"/> 
	<xsl:param name="extension" select="'php'"/>
	<!-- for various concatenation purposes -->
	<xsl:param name="dirname" select="if(string-length($ou:dirname) = 1) then $ou:dirname else concat($ou:dirname,'/')" />
	<xsl:param name="domain" select="substring($ou:httproot,1,string-length($ou:httproot)-1)" />
	<!-- section property files -->
	<xsl:param name="props-file" select="'_props.pcf'"/>
	<xsl:param name="props-path" select="concat($ou:root, $ou:site, $dirname, $props-file)"/>
	<!-- page information -->
	<xsl:variable name="pageTitle" select="/document/ouc:properties[@label='metadata']/title" />
	<xsl:variable name="pageHeading" select="/document/ouc:properties/parameter[@name='heading']"/>
	<xsl:variable name="layout" select="/document/ouc:properties/parameter[@name='layout']/option[@selected='true']/@value" />
</xsl:stylesheet>