<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	
	<!--	Importing files to acquire their functionality of templates and parameters. All imported templates and parameters have lower priority. 
	This makes it possible to define templates or parameters with the same name/match conditions and redefine their functionality.
	This XSL file is called first by the PCF file to guarantee that it will maintain the highest priority for all templates and parameters. -->
	<xsl:import href="../common.xsl" />
	<xsl:import href="blog-functions.xsl" />
	
	<!-- The template that will contain all of the specific HTML template transformations.  Called by common.xsl. -->
	<xsl:template name="page-content">
		<xsl:variable name="post-link" select="concat($domain,$ou:path,'l')" />
		<!--xsl:variable name="post-date" select="ou:adjust-blog-date(post-info/ouc:div[@label='post-date'])" /-->
		
		<p>$post-link: <xsl:value-of select="$post-link"></xsl:value-of></p>
		<p>$post-date: <xsl:value-of select="$post-date"></xsl:value-of></p>
	</xsl:template>

</xsl:stylesheet>
