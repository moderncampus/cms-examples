<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
Course Catalog - 05/2016
=========================
IMPLEMENTATION VARIABLES 
Define global implementation variables here for both web and pdf output
=========================
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<!-- Current Catalog Version (ie, /working, /current -->
	<xsl:param name="version" select="tokenize($ou:dirname,'/')[2]" /> 
	
	<!-- HTTP path to main Website -->
	<xsl:param name="root-url" select="substring-before($ou:httproot,'catalog')"/>
	
	<!-- HTTP path to Catalog -->
	<xsl:param name="catalog-path" select="concat($ou:httproot,$version)"/>
	
	<!-- Path to converted xml -->
	<xsl:param name="converted-xml" select="concat($catalog-path,'/_config.xml')"/>
	
	<!-- Path to config file on staging -->
	<xsl:param name="config-file" select="document(concat($ou:root, $ou:site, '/', $version , '/_config.pcf'))"/>
	
	<!-- Data files -->
	<!-- 
		Either link directly to the XML, 
		or link to a reformatted version that the config file publishes.
		Examples...
			 Direct:	<xsl:param name="departments-xml" select="concat($ou:httproot,ou:pcf-param('departments-xml',$config-file))"/>
		Reformatted:	<xsl:param name="courses-xml" select="concat($ou:httproot,$version,'/_config.courses.xml')"/>
	-->
	<xsl:param name="courses-xml" select="concat($ou:httproot,$version,'/_config.courses.xml')"/>
	
	<!-- text for PDF display -->
	<xsl:param name="first-page" select="$config-file/document/ouc:properties/parameter[@name='first-page']"/>	
	<xsl:param name="last-page" select="$config-file/document/ouc:properties/parameter[@name='last-page']"/>
	<xsl:param name="catalog-heading" select="$config-file/document/ouc:properties/parameter[@name='catalog-heading']"/>
	<xsl:param name="catalog-title" select="$config-file/document/ouc:properties/parameter[@name='catalog-title']"/>
	<xsl:param name="catalog-years" select="$config-file/document/ouc:properties/parameter[@name='catalog-years']"/>
	
	<!-- default page layout for pdf xsl-->
	<xsl:param name="page-type">1col</xsl:param>
	
</xsl:stylesheet>