<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY amp   "&#38;">
<!ENTITY copy   "&#169;">
<!ENTITY gt   "&#62;">
<!ENTITY hellip "&#8230;">
<!ENTITY laquo  "&#171;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY lsquo   "&#8216;">
<!ENTITY lt   "&#60;">
<!ENTITY nbsp   "&#160;">
<!ENTITY quot   "&#34;">
<!ENTITY raquo  "&#187;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY rsquo   "&#8217;">
]>
<!-- 
=========================
Template matches
Default Template matches for editable content.
Applicable to individual html output.
=========================
-->
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ou="http://omniupdate.com/XSL/Variables"
  xmlns:fn="http://omniupdate.com/XSL/Functions"
  xmlns:ouc="http://omniupdate.com/XSL/Variables"
  exclude-result-prefixes="xs ou fn ouc">
	
    <!-- Copy the content on no match -->
	<xsl:mode on-no-match="shallow-copy"/>
	<!-- This resolves the issue with the edit mode of Modern Campus CMS -->
	<xsl:template match="processing-instruction('pcf-stylesheet')" mode="#all"/>
	
    <!-- MISC -->
    <!-- don't output ouc tags on publish. -->
    <xsl:template match="ouc:*[$ou:action !='edt']" mode="#all">
        <xsl:apply-templates mode="#current" />
    </xsl:template>
          
    <!-- Visual warning for broken dependencies tags -->
    <xsl:template match="a[contains(@href,'*** Broken')]" mode="#all">
        <a href="{@href}" style="color: red;"><xsl:value-of select="."/></a> <span style="color: red;">[BROKEN LINK]</span>
    </xsl:template>
    
    <!-- The following template matches processing instructions, outputs the proper syntax with the code escaped properly. -->
    <!-- Remove closing '?' mark if not HTML5 output. -->
    <xsl:template match="processing-instruction('php')" mode="#all">
        <xsl:processing-instruction name="php">
			<xsl:value-of select="." disable-output-escaping="yes" />
		?</xsl:processing-instruction>
    </xsl:template>
</xsl:stylesheet>
