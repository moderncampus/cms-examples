<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE xsl:stylesheet SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">

<!--
	Breadcrumb XSL

	Dependencies:
	- cms-breadcrumbs.xml
	- variables.xsl
	- functions.xsl
-->

<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou ouc">
	
	<xsl:variable name="index-filename" select="concat($index-file, '.' , $extension)"/>

	<xsl:template name="output-breadcrumbs">
		<ul  class="breadcrumb">
			<xsl:call-template name="output-cms-breadcrumbs" />
		</ul>
	</xsl:template>
	
	<xsl:template name="cms-breadcrumb-output" expand-text="yes">
		<!-- contents of folder (will not be populated when $type is 'current')
			<folder path="/" level="0">
            	<breadcrumb>Home</breadcrumb>
            	<breadcrumb-stop>false||true</breadcrumb-stop>
            	<breadcrumb-skip>false||true</breadcrumb-skip>
         	</folder> 
		-->
		<xsl:param name="folder" />
		<xsl:param name="type" />
		<xsl:param name="message" />
		<xsl:choose>
			<xsl:when test="$type = 'skipped'">
				<span>{$message}</span>
			</xsl:when>
			<xsl:when test="$type = 'root'">
				<span><a href="{$folder/@path}{$index-filename}">{$folder/breadcrumb}</a> / </span>
			</xsl:when>
			<xsl:when test="$type = 'index'">
				<span> {$folder/breadcrumb} </span>
			</xsl:when>
			<xsl:when test="$type = 'current'">
				<span> {$current-breadcrumb}</span>
			</xsl:when>
			<!-- type will be 'general' -->
			<xsl:otherwise>
				<span> <a href="{$folder/@path}{$index-filename}">{$folder/breadcrumb}</a> / </span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>