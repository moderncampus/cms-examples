<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>

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
	
	<!-- Grab page parameter data for use in ou:pcf-param. -->
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
		
	<!-- Find Previous Directory -->
	<xsl:function name="ou:find-prev-dir"> <!-- outputs parent directory path with trailing '/': /path/to/parent/ -->
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

	<!-- 
	Concisely assign fallback variables to prevent unexpected errors in development and post implementation. Requires ou:pcf-param.
	-->
	<xsl:function name="ou:assign-variable"> <!-- test if page property has value, give default value if none -->
		<xsl:param name="var"/>
		<xsl:param name="fallback"/>
		<xsl:variable name="pcf-var" select="ou:pcf-param($var)"/>
		<xsl:choose>
			<xsl:when test="string-length($pcf-var) > 0"><xsl:value-of select="$pcf-var"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$fallback"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ou:assign-variable"> <!-- pcf - dir var - fallback precedence, also tests if there is a value for each -->
		<xsl:param name="var"/>
		<xsl:param name="dir-var"/>
		<xsl:param name="fallback"/>
		<xsl:variable name="overwrite-directory" select="ou:pcf-param('overwrite-directory')"/>
		<xsl:variable name="pcf-var" select="ou:pcf-param($var)"/>
		<xsl:choose>
			<xsl:when test="string-length($pcf-var) > 0 and $overwrite-directory='yes'"><xsl:value-of select="$pcf-var"/></xsl:when>
			<xsl:when test="string-length($dir-var) > 0 and $dir-var!='[auto]'" ><xsl:value-of select="$dir-var"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$fallback"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
		
	<!--
	TEST VARIABLE
	A simpler version of Assign Variable, if you are not dealing with page properties.
	-->
	<xsl:function name="ou:test-variable"> <!-- test if variable has value, give default value if none -->
		<xsl:param name="var"/>
		<xsl:param name="fallback"/>
		<xsl:choose>
			<xsl:when test="string-length($var) > 0"><xsl:value-of select="$var"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$fallback"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
</xsl:stylesheet>