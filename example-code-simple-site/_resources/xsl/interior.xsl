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
		<div class="row">
			<div class="col-md-12">
				<ul class="breadcrumb">
					<xsl:call-template name="breadcrumb">
						<xsl:with-param name="path" select="$ou:dirname"/>
					</xsl:call-template>
				</ul>
			</div>
		</div>
		<div class="row">
			<xsl:if test="$layout = 'two'">
				<div class="col-md-3">
					<ul id="sidenav" class="nav nav-pills nav-stacked">
						<xsl:copy-of select="ou:include-file(concat($dirname,'_nav.inc'))" />
					</ul>
				</div>
			</xsl:if>
			<div class="col-md-12 content">
				<xsl:if test="$layout = 'two'"><xsl:attribute name="class">col-md-9 content</xsl:attribute></xsl:if>
				<h2><xsl:value-of select="$pageHeading" /></h2>
				<xsl:apply-templates select="ouc:div[@label='maincontent']" mode="copy" />
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>