<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
<!ENTITY copy   "&#169;">
]>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou fn ouc">

	<xsl:import href="_shared/template-matches.xsl"/>
	<xsl:import href="_shared/ouvariables.xsl"/>
	<xsl:import href="_shared/functions.xsl"/>
	<xsl:import href="_shared/breadcrumb.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/document">
		<xsl:call-template name="page-directive" />
		<xsl:text disable-output-escaping="yes">&lt;</xsl:text>!DOCTYPE html<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
		<html class="no-js" lang="en">
			<head>
				<xsl:call-template name="common-headcode"/> <!-- common headcode -->
				<xsl:call-template name="template-headcode"/> <!-- each pagetype may have a version of this template -->
				<xsl:apply-templates select="headcode/node()"/>
				<title><xsl:value-of select="$page-title"/></title>
				<!-- copy meta tags from pcf, but only those with content -->
				<xsl:apply-templates select="/document/ouc:properties[@label='metadata']/meta[string-length(@content)>0]"/>
			</head>
			<body>
				<div class="row">
					<div class="large-12 columns">
						<xsl:apply-templates select="bodycode/node()"/>
						<!-- pcf -->
						<xsl:call-template name="common-header"/>
						<xsl:call-template name="page-content"/>
						<!-- each pagetype has a unique version of this template -->
						<xsl:call-template name="common-footer"/>
						<xsl:call-template name="template-footcode"/>
						<xsl:apply-templates select="footcode/node()"/>
						<!-- pcf -->
					</div>
				</div>
			</body>
		</html>
		<!-- end html -->
	</xsl:template>

	<xsl:template name="page-directive">
		<xsl:if test="($ou:action = 'pub') or ($ou:action = 'cmp')">
			<xsl:text disable-output-escaping="yes">&lt;%@ Page Language="C#" %&gt;</xsl:text>
			<!-- <xsl:text disable-output-escaping="yes">&lt;%@ Import namespace="OUC" %&gt;</xsl:text> -->
		</xsl:if>
	</xsl:template>

	<xsl:template name="common-headcode">
		<xsl:copy-of select="ou:include-file('/_resources/includes/headcode.inc')"/>
	</xsl:template>

	<xsl:template name="common-header">
		<xsl:copy-of select="ou:include-file('/_resources/includes/header.inc')"/>
	</xsl:template>

	<xsl:template name="common-footer">
		<xsl:copy-of select="ou:include-file('/_resources/includes/footer.inc')"/>
		<xsl:copy-of select="ou:include-file('/_resources/includes/footcode.inc')"/>
		<xsl:copy-of select="ou:include-file('/_resources/includes/analytics.inc')"/>
		<div id="hidden" style='display:none;'><xsl:comment> com.omniupdate.ob </xsl:comment><xsl:comment> /com.omniupdate.ob </xsl:comment></div>
	</xsl:template>

	<!-- in case not defined in pagetype xsl -->
	<xsl:template name="page-content"><p>No template defined.</p></xsl:template><!-- leave for debugging purposes -->
	<xsl:template name="template-headcode"/>
	<xsl:template name="template-footcode"/>

</xsl:stylesheet>
