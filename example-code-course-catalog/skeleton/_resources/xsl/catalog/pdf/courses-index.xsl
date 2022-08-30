<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
Course Catalog - 05/2016
=========================
COURSES INDEX (PDF)
Listing of subjects & courses.
=========================
-->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ou="http://omniupdate.com/XSL/Variables" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:ouc="http://omniupdate.com/XSL/Variables" exclude-result-prefixes="xs ou ouc">

	<xsl:import href="common.xsl"/>

	<xsl:param name="page-type">2col</xsl:param>
	<xsl:param name="courses-doc" select="document($courses-xml)"/>

	<xsl:template name="page-content">
		<fo:flow flow-name="xsl-region-body">
			<!-- remove heading if part of wysiwyg region -->
			<fo:block xsl:use-attribute-sets="h1"><xsl:value-of select="ou:pcf-param('heading')"/></fo:block>		
			<!-- wysiwyg content -->
			<xsl:apply-templates select="ouc:div[@label='maincontent']/node()" />
			<xsl:apply-templates select="$courses-doc/descendant::Subject" mode="toc"/>
			<xsl:apply-templates select="$courses-doc/descendant::Subject" mode="display-courses"/>
		</fo:flow>
	</xsl:template>

</xsl:stylesheet>
