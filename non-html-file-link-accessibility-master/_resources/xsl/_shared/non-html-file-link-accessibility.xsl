<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY amp   "&#38;">
]>
<!-- 
NON-HTML FILE LINK ACCESSIBILITY
XSL that will be used in conjunction with a server side script to display file information for linked binary files for accessibility purposes. 

Contributors: Kelly Leaveck, Brian Laird
Last Updated: May 2019
-->
<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<!-- If you change the location of the php script update the path here. -->
	<xsl:variable name="accessible-link-script-path" select="'/_resources/php/non-html-file-link-accessibility/non-html-file-link-accessibility.php'"/>
	

	<!-- Stripped down version of "unparsed-include-file" that accepts a full path to the file on production -->
	<xsl:template name="filesize-check">
		<xsl:param name="path" />
		<xsl:choose>
			<xsl:when test="unparsed-text-available($path)">
				<xsl:value-of select="unparsed-text($path)" disable-output-escaping="yes"/>
			</xsl:when>
			<xsl:otherwise>
				<p style="word-break: break-word"><xsl:value-of select="concat('File not available. Please make sure the path ( ' ,$path ,' ) is correct and the file is published.')" /></p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	

	<!-- BEGIN: template matches to target links with specific binary extensions -->
	<xsl:template match="a[@href => ends-with('.pdf')]">
		<xsl:call-template name="output-icon">
			<xsl:with-param name="href" select="@href" />
			<xsl:with-param name="file-type">PDF</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="a[@href => ends-with('.doc') or @href => ends-with('.docx')]">
		<xsl:call-template name="output-icon">
			<xsl:with-param name="href" select="@href" />
			<xsl:with-param name="file-type">Word</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="a[@href => ends-with('.xlsx') or @href => ends-with('.xls')]">
		<xsl:call-template name="output-icon">
			<xsl:with-param name="href" select="@href" />
			<xsl:with-param name="file-type">Excel</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="a[@href => ends-with('.pptx') or @href => ends-with('.ppt')]">
		<xsl:call-template name="output-icon">
			<xsl:with-param name="href" select="@href" />
			<xsl:with-param name="file-type">PowerPoint</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!-- END: template matches to target links with specific binary extensions -->

	
	<!-- 
		Outputs the filetype and filesize for a given link 

		@param	href	A path to the binary file we need to grab the stats from
		@param	file-type	This is the text that will output next to the file text
	-->
	<xsl:template name="output-icon">
		<!-- path to file -->
		<xsl:param name="href" />
		<xsl:param name="file-type" select="'.' || tokenize($href, '/')[last()] => substring-after('.')" />
		<a><xsl:apply-templates select="attribute()|node()" />
			<!-- Calling the server side script and passing file path -->
			<xsl:call-template name="filesize-check">
				<xsl:with-param name="path" select="$domain || $accessible-link-script-path || '?path=' || $href || '&amp;ftd=' || $file-type"></xsl:with-param>
			</xsl:call-template></a>
	</xsl:template>

</xsl:stylesheet>