<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
Course Catalog - 05/2016
=========================
CATALOG COMMMON STYLESHEET (Web)
Imported by all catalog web page stylesheets.
=========================
-->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:fn="http://omniupdate.com/XSL/Functions"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="xsl xs ou fn ouc">

	<!-- Path to main website common.xsl -->
	<xsl:import href="../../common.xsl"/>
	
	<!-- Path to catalog shared resources -->
	<xsl:import href="../_shared/variables.xsl"/>
		
    <!-- ============================================		
		Catalog Snippets/Styles
	=============================================== -->
    
    <!-- don't display pdf formatting -->
    <xsl:template match="element()[contains(@class,'ou-exclude-web')]|hr[@class='ou-catalog-page-break']|hr[@class='ou-catalog-column-break']" priority="2"/>
    
    <!-- ============================================		
		XML to HTML Templates
		This is just an Example...
	=============================================== -->
    <xsl:template match="Subject" mode="display-subject">
        <li><a href="{@code}"><xsl:value-of select="@code"/></a></li>	
    </xsl:template>
    <xsl:template match="Subject" mode="display-courses">
        <h2><xsl:value-of select="@code"/></h2>		
        <xsl:apply-templates mode="display-courses"/>
    </xsl:template>
    <xsl:template expand-text="yes" match="CourseInventory" mode="display-courses">
        <p><strong>{CourseNumber}. {CourseLongTitle}</strong></p>
        <p>{CourseCreditMinimumValue} Credit<xsl:if test="CourseCreditMinimumValue!='1'">s</xsl:if>. {CourseDescription}</p>       
    </xsl:template>	

</xsl:stylesheet>