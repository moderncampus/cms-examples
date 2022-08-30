<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY laquo  "&#171;">
<!ENTITY raquo  "&#187;">
<!ENTITY copy   "&#169;">
]>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xs ou ouc">
	
	<xsl:import href="../_shared/ouvariables.xsl" />
	<xsl:import href="helper.xsl" />
	
	<xsl:strip-space elements="*" />
	
	<xsl:output method="xhtml" />
	
	<xsl:template match="/document">
		<xsl:choose>
			<xsl:when test="profile">  <!-- Check to see if Profile Page (profile node exists) -->
				<xsl:call-template name="profile" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="listing" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="profile">
		<xsl:copy-of select="ou:get-profile(.)" />
	</xsl:template>
	
	<xsl:template name="listing">
		<xsl:copy-of select="ou:get-profiles($dirname, $ou:filename)" />
	</xsl:template>
	
	<!-- The following template matches all items except processing instructions, copies them, then processes any children. -->
	<xsl:template match="attribute()|text()|comment()">
		<xsl:copy />
	</xsl:template>
	
	<xsl:template match="element()">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="attribute()|node()" mode="#current" />
		</xsl:element>
	</xsl:template>	
	
</xsl:stylesheet>
