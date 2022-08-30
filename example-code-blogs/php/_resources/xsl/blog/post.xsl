<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE stylesheet [
	<!ENTITY nbsp  "&#160;" >
]>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou ouc">
	
	<!--	Importing files to acquire their functionality of templates and parameters. All imported templates and parameters have lower priority. 
	This makes it possible to define templates or parameters with the same name/match conditions and redefine their functionality.
	This XSL file is called first by the PCF file to guarantee that it will maintain the highest priority for all templates and parameters. -->
	<xsl:import href="blog-functions.xsl" />
	<xsl:import href="../common.xsl"/>
	
	<xsl:template name="page-content">
		<xsl:variable name="author" select="if (normalize-space(post-info/ouc:div[@label='post-author']) != '') then post-info/ouc:div[@label='post-author'] else $ou:username"/>
		<xsl:variable name="email" select="if (normalize-space(post-info/ouc:div[@label='post-email']) != '') then post-info/ouc:div[@label='post-email'] else $ou:email"/>
		<div class="row">
			<div class="large-12 columns">
				<h1><xsl:value-of select="$page-title"/></h1>
			</div>
		</div>
		<div class="row">
			<div class="{if (ou:pcf-param('right-enable') = 'true') then 'large-8' else 'large-12'} columns">
				<p><xsl:value-of select="ou:display-long-date(post-info/ouc:div[@label='post-date'])" />&nbsp;<a href="mailto:{$email}"><xsl:value-of select="$author"/></a></p>
				<!-- Main Content Region -->
				<xsl:apply-templates select="ouc:div[@label='maincontent']" />
				<xsl:if test="ouc:properties[@label='config']/parameter[@name='disqus-enable']/option[@value='true']/@selected='true'">
				<!-- Insert LDP Comment asset here -->
				</xsl:if>
			</div>
			<xsl:if test="ou:pcf-param('right-enable') = 'true'">
				<aside class="large-4 columns">
					<xsl:if test="ou:pcf-param('regions') = 'panel'">
						<xsl:call-template name="panel-region"/>
					</xsl:if>
					<xsl:if test="ou:pcf-param('regions') = 'region'">
						<xsl:call-template name="right-column"/>
					</xsl:if>
				</aside>
			</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template name="panel-region">
		<div class="panel">
			<xsl:apply-templates select="ouc:div[@label='panel']"/>
		</div>
	</xsl:template>
	
	<xsl:template name="right-column">
		<xsl:apply-templates select="ouc:div[@label='right-content']" />
	</xsl:template>
	
	<xsl:template name="template-headcode">
		<meta property="og:title" content="{/document/post-info/ouc:div[@label='post-title']}"/>
		<meta property="og:description" content="{/document/post-info/ouc:div[@label='post-description']}"/>
		<meta property="og:image" content="{concat($domain, /document/post-info/ouc:div[@label='post-image'])}"/>
		<meta property="og:url" content="{concat($domain,$ou:path)}"/>
		<meta name="twitter:title" content="{/document/post-info/ouc:div[@label='post-title']}"/>
		<meta name="twitter:description" content="{/document/post-info/ouc:div[@label='post-description']}"/>
		<meta name="twitter:image" content="{concat($domain, /document/post-info/ouc:div[@label='post-image'])}"/>
		<meta name="twitter:card" content="summary"/>
		<meta name="Author" content="{post-info/ouc:div[@label='post-author']}"/>
		<link rel="stylesheet" type="text/css" href="/_resources/css/blog/blog.css"/>
		<xsl:if test="$ou:action = 'pub' and /document[descendant::blog]">
			<xsl:processing-instruction name="php">
				require_once($_SERVER["DOCUMENT_ROOT"] . "/_resources/php/blog/listing.php");
			?</xsl:processing-instruction>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
