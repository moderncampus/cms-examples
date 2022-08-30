<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
=========================
Functions
Helper function for output.
Applicable to individual pdf output and example web.
=========================
-->
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
	   <xsl:value-of select="concat(string-join(subsequence($path,1,count($path) - count($link-seq) + 1),'/'),'/',$link-seq[last()])" />
	</xsl:function>
	
	<xsl:function name="ou:remove-last-token">
		<xsl:param name="str" />
		<xsl:param name="token" />
		<xsl:variable name="sequence" select="tokenize($str,$token)" />
		<xsl:value-of select="string-join(remove($sequence,count($sequence)),$token)" />
	</xsl:function>
	
	<!-- 
	PCF PARAMS
	An extremely useful function for getting page properties without needing to type the full xpath.
	How to use:
	The pcf has a parameter, name="page-type". To get the value and store it in an XSL param : 	
	<xsl:param name="page-type" select="ou:pcf-param('page-type')"/> 
	<xsl:param name="props-tile" select="ou:pcf-param('section-title',$props-doc)"/> 	
	-->
	<xsl:param name="pcf-params" select="/document/descendant::parameter"/> <!-- save all page properties in a variable -->
	
	<!-- Get PCF params from an external document -->
	<xsl:function name="ou:pcf-param">
		<xsl:param name="name" as="xs:string"/>
		<xsl:param name="doc" as="document-node()"/>		
		<xsl:variable name="external-params" select="$doc/descendant::parameter"/>
		<xsl:call-template name="pcf-param">
			<xsl:with-param name="name" select="$name"/>
			<xsl:with-param name="pcf-params" select="$external-params"/>
		</xsl:call-template>
	</xsl:function>
	
	<!-- Get a param from default parmaeter list -->
	<xsl:function name="ou:pcf-param">
		<xsl:param name="name"/>
		<xsl:call-template name="pcf-param">
			<xsl:with-param name="name" select="$name"/>
		</xsl:call-template>
	</xsl:function>
	
	<!-- Get a param from a provided parmaeter list -->
	<xsl:template name="pcf-param">
		<xsl:param name="name"/>
		<xsl:param name="pcf-params" select="$pcf-params"/>
		<xsl:variable name="parameter" select="$pcf-params[@name=$name]"/>
		<xsl:choose>
			<xsl:when test="$parameter/@type = 'select' or $parameter/@type = 'radio'">
				<xsl:value-of select="$parameter/option[@selected = 'true']/@value"/>
			</xsl:when>
			<xsl:when test="$parameter/@type = 'checkbox'">
				<xsl:copy-of select="$parameter/option[@selected = 'true']/@value"/>
			</xsl:when>
			<xsl:when test="$parameter/@type = 'asset'">
				<xsl:copy-of select="$parameter/node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$parameter/text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
