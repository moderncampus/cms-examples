<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- Simple Site Skeleton 12/8/25 -->
<xsl:stylesheet version="3.0" expand-text="yes"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:fn="http://omniupdate.com/XSL/Functions"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="ou xsl xs fn ouc">

	<xsl:import href="common.xsl"/>

	<xsl:param name="current-breadcrumb">
		<xsl:choose>
			<xsl:when test="normalize-space(ou:pcf-param('breadcrumb')) != '' ">{ou:pcf-param('breadcrumb')}</xsl:when>
			<xsl:otherwise>{ou:pcf-param('heading')}</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:template name="page-content">
		<div class="row">
			<div class="col-md-12">
				<xsl:call-template name="output-breadcrumbs" />
			</div>
		</div>
		<div class="row">
			<xsl:if test="$layout = 'two'">
				<div class="col-md-3">
					<ul id="sidenav" class="nav nav-pills nav-stacked">
						<xsl:copy-of select="ou:include-file(concat($dirname,'_nav.ounav'))" />
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