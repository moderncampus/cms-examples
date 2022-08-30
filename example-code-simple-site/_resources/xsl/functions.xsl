<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- Simple Site Skeleton 10/2/18 -->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">

	<!-- The following function takes in one parameter of a file path outputs the  proper code to include the file on the page. -->
	<xsl:function name="ou:include-file">
		<!-- directory name + file name -->
		<xsl:param name="fullpath" />
		<!-- on publish, it will output the proper SSI code, but on staging we require the omni div tag -->
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:copy-of select="ou:ssi($fullpath)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment> ouc:div label="<xsl:value-of select="$fullpath"/>" path="<xsl:value-of select="$fullpath"/>"</xsl:comment> <xsl:comment> /ouc:div </xsl:comment> 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ou:ssi">
		<xsl:param name="fullpath"/>
		<!--<xsl:comment>#include virtual="<xsl:value-of select="$fullpath" />" </xsl:comment>-->
		<xsl:processing-instruction name="php"> include($_SERVER['DOCUMENT_ROOT'] . "<xsl:value-of select="$fullpath" />"); ?</xsl:processing-instruction>
	</xsl:function>
		
	<!-- Find Previous Directory -->
	<xsl:function name="ou:findPrevDir"> <!-- outputs parent directory path with trailing '/': /path/to/parent/ -->
		<xsl:param name="path" />
		<xsl:variable name="tokenPath" select="tokenize(substring($path, 2), '/')[if(substring($path,string-length($path)) = '/') then position() != last() else position()]" />
		<xsl:variable name="newPath" select="concat('/', string-join(remove($tokenPath, count($tokenPath)), '/') ,'/')"/>
		<xsl:value-of select="if($newPath = '//') then '/' else $newPath" />
	</xsl:function>
	
	<!-- Get Current Folder -->
	<xsl:function name="ou:current_folder">
		<xsl:param name="string"/>
		<xsl:variable name="chars" select="tokenize(substring-after($string,'/'), '/')"/>
		<xsl:value-of select="ou:capital(string($chars[position() = last()]))" />
	</xsl:function>
	
	<!-- Capitalize The First Letter Of Every Word -->
	<xsl:function name="ou:capital">
		<xsl:param name="string"/>
		<xsl:variable name="chars" select="tokenize($string, ' ')"/>
		<xsl:for-each select="$chars">
			<xsl:variable name="key"><xsl:value-of select="."/></xsl:variable>
			<xsl:variable name="firstletter1"><xsl:value-of select="upper-case(substring($key,1,1))" /></xsl:variable>
			<xsl:variable name="rest1"><xsl:value-of select="lower-case(substring($key,2))" /></xsl:variable>
			<xsl:variable name="result"><xsl:value-of select="concat($firstletter1,$rest1,' ')" /> </xsl:variable>
			<xsl:value-of select="$result" />
		</xsl:for-each>
	</xsl:function>
</xsl:stylesheet>