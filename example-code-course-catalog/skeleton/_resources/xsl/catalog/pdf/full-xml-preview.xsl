<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
FULL XML PREVIEW
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"	
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xs ou ouc">

	<xsl:import href="common.xsl" />
	<xsl:import href="full-xml.xsl" />
	
	<xsl:template match="/">
		<xsl:copy-of select="$index-xml"/>
		<xsl:copy-of select="$full-xml"/>
	</xsl:template>
	
</xsl:stylesheet>
