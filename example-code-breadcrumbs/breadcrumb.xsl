<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE xsl:stylesheet SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">

<!--
	Implementation Skeleton - 06/15/2023

	Breadcrumb XSL

	Dependencies:
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
		<ul>
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
				<li>{$message}</li>
			</xsl:when>
			<xsl:when test="$type = 'root'">
				<li><a href="{$folder/@path}{$index-filename}">{$folder/breadcrumb} (Level: {$folder/@level})</a></li>
			</xsl:when>
			<xsl:when test="$type = 'index'">
				<li>{$folder/breadcrumb} (Level: {$folder/@level})</li>
			</xsl:when>
			<xsl:when test="$type = 'current'">
				<li>{$current-breadcrumb}</li>
			</xsl:when>
			<!-- type will be 'general' -->
			<xsl:otherwise>
				<li><a href="{$folder/@path}{$index-filename}">{$folder/breadcrumb} (Level: {$folder/@level})</a></li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>