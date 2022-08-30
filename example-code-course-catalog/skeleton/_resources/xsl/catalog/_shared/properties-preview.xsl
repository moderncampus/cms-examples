<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
Course Catalog - 05/2016
=========================
FILE PROPERTIES PREVIEW
Preview display for non-publish property files.
=========================
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<!-- main site properties -->
	<xsl:import href="../../properties.xsl"/>
	
	<xsl:template name="properties-description">
		<h1>File Properties</h1>
		To edit the following section properties, please check out this page and go to Page Parameters.<br/> 	
	</xsl:template>
	
</xsl:stylesheet>