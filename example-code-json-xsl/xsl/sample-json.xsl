<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>

<!--
The JSON rendering XSL file showing how to use the xsl-map-templates.xsl file.
-->
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables" exclude-result-prefixes="xsl xs ou fn ouc">

	<xsl:import href="xsl-map-templates.xsl"/>
	<xsl:output method="text" encoding="utf-8"/>

	<xsl:variable name="json-escape-map" select="map{'method': 'json', 'json-node-output-method': 'html', 'indent': true()}" as="map(*)"/>

	<xsl:template match="/">
		<xsl:variable name="pcf-map" as="map(*)?">
			<xsl:apply-templates mode="pcf-to-xsl-map"/>
		</xsl:variable>

		<xsl:value-of select="serialize($pcf-map, $json-escape-map)"/>
	</xsl:template>

</xsl:stylesheet>
