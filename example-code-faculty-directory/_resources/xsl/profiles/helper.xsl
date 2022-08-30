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

	<xsl:function name="ou:get-profile">
		<xsl:param name="document" />
		<profile href="{concat($dirname, replace($ou:filename, '.xml', '.html'))}">
			<xsl:for-each select="$document/profile/ouc:div">
				<xsl:element name="{translate(./@label, ' ', '_')}"><xsl:apply-templates select="node()[not(self::ouc:multiedit)]" /></xsl:element>
			</xsl:for-each>
		</profile>
	</xsl:function>

	<xsl:function name="ou:get-profiles">
		<xsl:param name="dir" />
		<xsl:param name="skip" />

		<xsl:variable name="profiles">
			<xsl:for-each select="doc(concat($ou:root, $ou:site, if ($ou:dirname = '/') then '' else $ou:dirname))/list/file[contains(., '.pcf')]">
				<xsl:variable name="file-path" select="concat($domain, $dirname, replace(., '.pcf', '.xml'))" />
				<xsl:if test="not(contains($file-path, $skip)) and doc-available($file-path)">
					<xsl:copy-of select="doc($file-path)/profile" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<profiles>
			<xsl:for-each select="$profiles/profile">
				<xsl:sort select="./lastname/text()" />
				<xsl:sort select="./firstname/text()" />
				<xsl:sort select="./middlename/text()" />

				<xsl:copy-of select="." />
			</xsl:for-each>
		</profiles>
	</xsl:function>

</xsl:stylesheet>
