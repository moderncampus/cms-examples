<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
Course Catalog - 05/2016
=========================
COURSES BY SUBJECT (Web)
Listing courses for particular subject.
=========================
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<!-- catalog common -->							
	<xsl:import href="common.xsl"/>	
	
	<xsl:template name="template-headcode"/>
	
	<xsl:param name="courses-doc" select="document($courses-xml)"/>
	<xsl:param name="subject-code" select="upper-case(normalize-space(ou:pcf-param('subject-code')))"/>
	
	<xsl:template name="page-content"> 		
		<!-- see breadcrumbs xsl -->
		<xsl:call-template name="breadcrumb">
			<xsl:with-param name="path" select="$ou:dirname"/>								
		</xsl:call-template>
		<xsl:apply-templates select="ouc:div[@label='maincontent']" />
		<!-- Example -->
		<xsl:value-of select="$subject-code"/>
		<xsl:apply-templates select="$courses-doc/descendant::Subject[@code=$subject-code]" mode="display-courses"/>							
	</xsl:template>
	
</xsl:stylesheet>