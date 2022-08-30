<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xs ou ouc">
	
	
	<xsl:function name="ou:get-authors">
		<xsl:param name="dir" />
		<xsl:param name="skip" />
		<xsl:variable name="authors">
			<xsl:for-each select="doc(concat($ou:root, $ou:site, $dir))/list/node()">
				<xsl:apply-templates select=".">
					<xsl:with-param name="dir" select="$dir"/>
					<xsl:with-param name="skip" select="$skip"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:variable>
		<authors>
			<xsl:for-each select="$authors/author-file">
				<xsl:sort select="tokenize(author/ouc:div[@label='a-name'], ' ')[last()]"/>
				<author>
					<name><xsl:value-of select="author/ouc:div[@label='a-name']"/></name>
					<title><xsl:value-of select="author/ouc:div[@label='a-title']"/></title>
					<department><xsl:value-of select="author/ouc:div[@label='a-department']"/></department>
					<bio><xsl:value-of select="author/ouc:div[@label='a-bio']"/></bio>
					<image><xsl:copy-of select="author/ouc:div[@label='a-image']/img"/></image>
					<link><xsl:value-of select="replace(filepath, '.pcf', '.html')"/></link>
				</author>
			</xsl:for-each>
		</authors>
		<xsl:copy-of select="$authors"/>
	</xsl:function>
	
	<!--<xsl:template match="directory">
		<xsl:param name="dir" />
		<xsl:param name="skip" />
		<xsl:variable name="subdir" select="concat($dir, '/', .)"/>
		<xsl:for-each select="doc(concat($ou:root, $ou:site, $subdir))/list/node()">
			<!-\- 			<xsl:variable name="file-path" select="concat($domain-st, $subdir, '/', replace(., '.pcf', '.xml'))" />
			<xsl:if test="not(contains($file-path, $skip)) and doc-available($file-path)">
				<xsl:copy-of select="doc($file-path)/scholarship" />
			</xsl:if> -\->
			<xsl:apply-templates select=".">
				<xsl:with-param name="dir" select="$subdir"/>
				<xsl:with-param name="skip" select="$skip"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>-->
	
	<xsl:template match="file[contains(., '.pcf')]">
		<xsl:param name="dir"/>
		<xsl:param name="skip"/>
<!--		<xsl:variable name="file-path" select="concat($domain-st, $dir, '/', replace(., '.pcf', '.xml'))" />-->
		<xsl:variable name="file-path" select="concat($ou:root, $ou:site, $dir, '/', .)" />
		<xsl:if test="not(contains($file-path, $skip)) and doc-available($file-path)">
			<xsl:if test="doc($file-path)/document/author">
				<author-file>
					<xsl:copy-of select="doc($file-path)/document/author" />
					<filepath><xsl:value-of select="$file-path"/></filepath>
				</author-file>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
