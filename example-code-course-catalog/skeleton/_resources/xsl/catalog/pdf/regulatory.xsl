<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
Course Catalog - 05/2016
=========================
REGULATORY PAGE (PDF)
Individual PDF page output.
=========================
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	exclude-result-prefixes="xsl xs ou fn ouc">

<xsl:import href="common.xsl" />

<xsl:param name="page-type">1col</xsl:param>

<xsl:template name="page-content">
	<fo:flow xsl:use-attribute-sets="text" flow-name="xsl-region-body">
		<!-- remove heading if part of wysiwyg region -->
		<fo:block xsl:use-attribute-sets="h1"><xsl:value-of select="ou:pcf-param('heading')"/></fo:block>		
		<!-- wysiwyg content -->
		<xsl:apply-templates select="ouc:div[@label='maincontent']/node()" />
	</fo:flow>
</xsl:template>

</xsl:stylesheet>