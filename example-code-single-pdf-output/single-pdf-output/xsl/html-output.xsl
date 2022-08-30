<?xml version="1.0" encoding="utf-8"?>
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
HTML example
Example structure for webpage with potential secondary output of PDF
=========================
-->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:fn="http://omniupdate.com/XSL/Functions"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="xsl xs ou fn ouc">

	<xsl:import href="_shared/template-matches.xsl"/>
	<xsl:import href="_shared/variables.xsl"/>
	<xsl:import href="_shared/functions.xsl"/>

	<!-- Default: for HTML5 use below output declaration -->
	<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no"/>

	<xsl:template match="/document"> 
		<html lang="en">
			<head>
				<xsl:call-template name="common-headcode"/> <!-- common headcode -->
				<xsl:call-template name="template-headcode"/> <!-- each page type may have a version of this template -->
				<xsl:apply-templates select="headcode/node()"/>
				<title><xsl:value-of select="$page-title"/></title>
				<!-- copy meta tags from pcf, but only those with content -->
				<xsl:apply-templates select="/document/ouc:properties[@label='metadata']/meta[string-length(@content)>0]"/>
			</head>
			<body>
				<xsl:apply-templates select="bodycode/node()"/> <!-- pcf -->
				<div class="container">
					<xsl:call-template name="common-header"/>
					<xsl:call-template name="page-content"/> <!-- each page type has a unique version of this template -->
					<xsl:call-template name="common-footer"/>
				</div>
				<xsl:call-template name="template-footcode"/> <!-- each page type may have a version of this template -->
				<xsl:apply-templates select="footcode/node()"/> <!-- pcf -->	
			</body>	
		</html>
	</xsl:template>
			
	<xsl:template name="common-headcode">
		<!-- Bootstrap minified CSS -->
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous" />
	</xsl:template>
	
	<xsl:template name="common-header">
		<header class="clearfix">
			<div class="row">
				<div class="col-md-12">
					<xsl:if test="ou:pcf-param('display-button') = 'true'">
						<xsl:attribute name="class">col-md-9</xsl:attribute>
					</xsl:if>
					<h1><a href="https://omniupdate.com/">PDF Example</a></h1>
				</div>
				<!-- making the print pdf button on the HTML webpage, only if page parameter is checked "true" -->
				<xsl:if test="ou:pcf-param('display-button') = 'true'">
					<div class="col-md-3">
						<a style="float: right; margin-top: 20px;" class="btn btn-default" href="{replace($ou:path, $extension, 'pdf')}">Print PDF Button</a>
					</div>
				</xsl:if>
			</div>
		</header>
	</xsl:template>
	
	<xsl:template name="common-footer">
		<!-- direct edit button output -->
		<div id="hidden" style='display:none;'><xsl:comment> com.omniupdate.ob </xsl:comment><xsl:comment> /com.omniupdate.ob </xsl:comment></div>
	</xsl:template>

	<xsl:template name="page-content">
		<main>
			<xsl:if test="normalize-space(ou:pcf-param('heading')) != ''">
				<h2><xsl:value-of select="ou:pcf-param('heading')" /></h2>
			</xsl:if>
			<xsl:apply-templates select="ouc:div[@label='maincontent']" />
		</main>
	</xsl:template>
	
	<xsl:template name="template-headcode"/>
	<xsl:template name="template-footcode"/>
	
</xsl:stylesheet>
