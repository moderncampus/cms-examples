<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- Simple Site Skeleton 10/2/18 -->
<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<xsl:import href="common.xsl"/>

	<xsl:template name="page-content">
		<div style="margin-bottom: 30px;">
			<img alt="{$pageTitle}" src="{/document/ouc:properties/parameter[@name='banner-image']}" class="img-responsive"/>
		</div>
		<div class="well">
			<xsl:apply-templates select="ouc:div[@label='maincontent']" mode="copy" />
		</div>
	</xsl:template>
</xsl:stylesheet>
