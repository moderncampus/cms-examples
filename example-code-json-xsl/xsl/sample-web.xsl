<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>

<!--
A simple xsl file for outputting a web preview.
-->
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables" exclude-result-prefixes="xsl xs ou fn ouc">

	<!-- Default: for HTML5 use below output declaration -->
	<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no"/>

	<xsl:mode on-no-match="shallow-copy"/>
	<xsl:template match="processing-instruction('pcf-stylesheet')" mode="#all" />
	<xsl:template match="ouc:*[$ou:action != 'edt']">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:param name="ou:action"/>

	<xsl:template match="/document">
		<html lang="en">
			<head>
				<xsl:call-template name="headcode"/>
				<xsl:apply-templates select="headcode/node()"/>
				<!-- pcf -->
			</head>
			<body>
				<ouc:div label="fake"/>
				<xsl:apply-templates select="bodycode/node()"/>
				<!-- pcf -->
				<xsl:call-template name="header"/>
				<div class="container-fluid">
					<xsl:call-template name="page-content"/>
					<!-- each page type has a unique version of this template -->
				</div>
				<xsl:call-template name="footer"/>
				<xsl:call-template name="footcode"/>
				<xsl:apply-templates select="footcode/node()"/>
				<!-- pcf -->
			</body>
		</html>
	</xsl:template>

	<!-- in case not defined in page type xsl -->
	<xsl:template name="page-content">
		<section class="row">
			<aside class="col-md-2">
			</aside>
			<main class="col-md-8" role="main">
				<xsl:apply-templates select="ouc:div[@label='maincontent']" />
			</main>
			<aside class="col-md-2" role="complementary">
			</aside>
		</section>
	</xsl:template>

	<xsl:template name="headcode">
		<xsl:param name="page-title" select="ouc:properties[@label='metadata']/title[1]"/>
		<meta charset="UTF-8"/>
		<title>
			<xsl:value-of select="$page-title"/>
		</title>
		<!-- copy meta tags from pcf, but only those with content -->
		<xsl:apply-templates select="ouc:properties[@label='metadata']/meta[string-length(@content)>0]"/>
		<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous"/>
	</xsl:template>

	<xsl:template name="header">
		<xsl:param name="heading" select="ouc:properties/parameter[@name='heading']"/>
		<header>
			<nav class="navbar navbar-dark bg-dark">
				<div class="container-fluid">
					<!-- Brand and toggle get grouped for better mobile display -->
					<div class="navbar-header">
						<span class="navbar-brand">Outputting PCF in JSON via XSL</span>
					</div>
					<span class="navbar-brand">
						<xsl:value-of select="$heading"/>
					</span>
				</div>
				<!-- /.container-fluid -->
			</nav>
		</header>
	</xsl:template>

	<xsl:template name="footer">
		<footer id="footer" class="bg-light fixed-bottom">
			<div class="container">
				<div class="row">
					<div class="col-md-12 py-3 text-center" xsl:expand-text="yes">
						<span>Powered by {system-property('xsl:vendor')} {system-property('xsl:product-name')} {system-property('xsl:product-version')}</span><br/>
						<span>XPath {system-property('xsl:xpath-version')}</span>
					</div>
				</div>
			</div>
		</footer>
		<div class="d-none">
			<xsl:comment>com.omniupdate.ob</xsl:comment>
			<xsl:comment>/com.omniupdate.ob</xsl:comment>
		</div>
	</xsl:template>

	<xsl:template name="footcode"/>

</xsl:stylesheet>
