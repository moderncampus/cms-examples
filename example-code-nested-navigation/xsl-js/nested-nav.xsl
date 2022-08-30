<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">
<!-- 
Kitchen Sink v2.4 - 2/18/2014
    
NESTED NAVIGATION
Recursively outputs side navigation files starting from a top-level directory until the current directory is reached.
Javascript is required to actually nest the navigation into the correct parent li items. 

Contributors: Your Name Here
Last Updated: Enter Date Here
-->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:fn="http://omniupdate.com/XSL/Functions"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="ou xsl xs fn ouc">

    <xsl:variable name="root" as="xs:string" select="concat($ou:root,$ou:site)" /> 
	<xsl:variable name="section-index-filename" select="concat($index-file,'.',$extension)"/>
	<xsl:variable name="section-nav-filename" select="'_nav.inc'"/> 
    
		<xsl:template name="nav-builder">
       
        <!-- initiates parameters, sets a default value if no parameters were passed in -->
        <xsl:param name="top-level" as="xs:string">/</xsl:param>
        <xsl:param name="path" as="xs:string">/</xsl:param>
        <xsl:param name="last-crumb" as="xs:string">last</xsl:param>
        
        
        <xsl:call-template name="nav">
            <xsl:with-param name="top-level" select="$top-level"/>
            <xsl:with-param name="path" select="$path"/>
            <xsl:with-param name="last-crumb" select="$last-crumb"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="nav">
        <xsl:param name="top-level" as="xs:string" />
        <xsl:param name="path" as="xs:string" required="yes"/>
        <xsl:param name="last-crumb" as="xs:string" required="yes"/>
        
        <!-- Check if the current path has parent directories. If it does, send the path of the parent directory to the template again. -->
        <xsl:if test="$path != $top-level and $path != '/'">
            <xsl:variable name="list" select="tokenize(substring($path, 2), '/')"/>
            <xsl:variable name="parent" select="concat('/', string-join(remove($list, count($list)), '/'))"/>
            
            <xsl:call-template name="nav">
                <xsl:with-param name="top-level" select="$top-level"/>
                <xsl:with-param name="path" select="$parent"/>
                <xsl:with-param name="last-crumb" select="$ou:dirname"/>
            </xsl:call-template>
        </xsl:if>   
        
        <xsl:variable name="href" select="if ($path = '/') then $path else concat($path, '/')"/>
  
        <!-- HTML OUTPUT FOR EACH SECTION -->      
		<ul data-nav-path="{$link-start}{$href}{$section-index-filename}" >
   			<xsl:copy-of select="ou:include-file(concat($href,$section-nav-filename))"/>
        </ul>
     
    </xsl:template>
    
</xsl:stylesheet>

