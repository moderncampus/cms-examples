<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"	
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xs ou ouc">

	<xsl:function name="ou:convert-pr-link">
		<xsl:param name="link" />
		<xsl:param name="current-path" />
		<xsl:variable name="path" select="tokenize($current-path, '/')"/>
		<xsl:variable name="link-seq" select="tokenize($link,'\.\./')" />
		<!-- The line below sometimes creates a double slash in the URL. Need to be looked into. -->
		<xsl:value-of select="concat(string-join(subsequence($path,1,count($path) - count($link-seq) + 1),'/'),'/',$link-seq[last()])" />
	</xsl:function>
	
	<xsl:function name="ou:remove-last-token">
		<xsl:param name="str" />
		<xsl:param name="token" />
		<xsl:variable name="sequence" select="tokenize($str,$token)" />
		<xsl:value-of select="string-join(remove($sequence,count($sequence)),$token)" />
	</xsl:function>

	<xsl:function name="ou:fix-title">
		<xsl:param name="str"/>
		<xsl:for-each select="tokenize($str,'[-_\s]')">
			<xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(.,2),' ')" />
		</xsl:for-each>
	</xsl:function>
	
	<xsl:function name="ou:toc-page">
		<xsl:param name="title" />
		<xsl:param name="reference" />
		<xsl:if test="$title!='' and $reference!=''">
			<fo:block text-align-last="justify">
				<fo:basic-link internal-destination="{$reference}">
					<xsl:value-of select="$title" />
					<fo:leader leader-pattern="dots" />
					<fo:page-number-citation ref-id="{$reference}" />
				</fo:basic-link>
			</fo:block>			
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="ou:toc-index">
		<xsl:param name="title" />
		<xsl:param name="reference" />
		<xsl:if test="$title!='' and $reference!=''">
			<fo:block xsl:use-attribute-sets="h3" space-after="0" text-align-last="justify">
				<fo:basic-link internal-destination="{$reference}">
					<xsl:value-of select="$title" />
					<fo:leader leader-pattern="dots" />
					<fo:page-number-citation ref-id="{$reference}" />
				</fo:basic-link>
			</fo:block>			
		</xsl:if>
	</xsl:function>
	
</xsl:stylesheet>