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


<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc"
				expand-text="yes">

	<xsl:import href="common.xsl"/>

	<xsl:template name="template-headcode"/>
	<xsl:template name="template-footcode"/>

	<xsl:param name="current-breadcrumb">
		<xsl:choose>
			<xsl:when test="ou:not-empty(ou:pcf-param('breadcrumb'))">{normalize-space(substring(ou:pcf-param('breadcrumb'), 1, 40))}<xsl:if test="string-length(ou:pcf-param('breadcrumb')) &gt; 40">...</xsl:if></xsl:when>
			<xsl:otherwise>{normalize-space(substring(ou:multiedit-field('title'), 1, 40))}<xsl:if test="string-length(ou:multiedit-field('title')) &gt; 40">...</xsl:if></xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:template name="page-content" expand-text="yes">
		<main class="content" id="main-content">
			<div class="page-header">
				<xsl:if test="ou:pcf-param('hero-img') != ''">
					<xsl:attribute name="class">page-header image-header</xsl:attribute>
					<xsl:attribute name="style">background:linear-gradient(0deg, rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)),no-repeat center center/cover  url({ou:pcf-param('hero-img')})</xsl:attribute>
				</xsl:if>
				<div class="container">
					<div class="row">
						<div class="col-12">
							<h1>{ou:pcf-param('heading')}</h1>
						</div>
					</div>
				</div>
			</div>

			<div class="container">
				<div class="row">
					<div class="col-12">
						<nav aria-label="breadcrumb">
							<!-- see breadcrumbs xsl -->
							<xsl:call-template name="output-breadcrumbs" />
						</nav>
					</div>
				</div>

				<div class="row">
					<div class="col-lg-3 pe-5">
						<div class="sidenav-accordion">
							<div class="accordion" id="SidenavAccordionPanels">
								<div>
									<button class="sidenav-heading accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#sidenav-mobile" aria-expanded="false" aria-controls="sidenav-mobile">
										University Policies
									</button>
								</div>
								<xsl:call-template name="side-navigation" />
							</div>
						</div>
					</div>
					<div class="col-lg-6">
						<xsl:apply-templates select="ouc:div[@label='main-content']" />
					</div>
					<div class="col-lg-3">
						<h2>{ou:get-folder-properties($dirname)//folder[position() = last()]/breadcrumb} Index</h2>
						<xsl:call-template name="dmc">
							<xsl:with-param name="options">
								<datasource>policies</datasource>
								<xpath>items/item</xpath>
								<type>sidebar</type>
								<directory>{$dirname}</directory>
								<querystring_control>true</querystring_control>
							</xsl:with-param>

							<xsl:with-param name="script-name">policies</xsl:with-param>
							<xsl:with-param name="debug" select="false()" />
						</xsl:call-template>
					</div>
				</div>
			</div>
		</main>
	</xsl:template>

</xsl:stylesheet>
