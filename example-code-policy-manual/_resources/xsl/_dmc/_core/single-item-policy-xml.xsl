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
				exclude-result-prefixes="xs ou ouc"
				expand-text="yes">

	<xsl:import href="/var/staging/OMNI-INF/stylesheets/implementation/v1/template-matches.xsl"/> <!-- global template matches -->
	<xsl:import href="/var/staging/OMNI-INF/stylesheets/implementation/v1/variables.xsl"/> <!-- global variables -->
	<xsl:import href="/var/staging/OMNI-INF/stylesheets/implementation/v1/functions.xsl"/> <!-- global functions -->
	<xsl:import href="../../_shared/variables.xsl"/> <!-- customer variables -->
	<xsl:import href="functions.xsl"/> <!-- DMC functions -->
	<xsl:include href="xml-beautify.xsl" />

	<xsl:template match="/document">
		<xsl:copy-of select="ou:get-item(.)" />
	</xsl:template>
	
	<xsl:template name="dmc-item-data">
		<xsl:param name="document"/>
		<xsl:if test="contains($ou:path, $index-file)">
			<content><xsl:apply-templates select="$document//ouc:div[@label='main-content']/node()"/></content>
		</xsl:if>
	</xsl:template>
	
<!-- 	change was needed to give the dmc-item-data template the proper context for the document node -->
	<xsl:function name="ou:get-item">
		<xsl:param name="document" />
		<item>
			<xsl:attribute name="href" select="concat($dirname, replace($ou:filename, 'xml', $extension))" />
			<xsl:attribute name="dsn" select="ou:pcf-param('dsn')" />
			<xsl:for-each select="$document/item/ouc:div[not(@xml = 'exclude')]">
				<xsl:element name="{translate(./@label, ' ', '_')}"><xsl:apply-templates select="node()[not(self::ouc:multiedit)]" /></xsl:element>
			</xsl:for-each>
			<xsl:if test="$tags != ''">		
				<tags>		
					<xsl:for-each select="tokenize($tags, ',')">
						<xsl:sort select="." />
						<tag>{.}</tag>		
					</xsl:for-each>		
				</tags>		
			</xsl:if>
			<xsl:call-template name="dmc-item-data">
				<xsl:with-param name="document" select="$document"/>
			</xsl:call-template>
		</item>
	</xsl:function>
	
</xsl:stylesheet>
