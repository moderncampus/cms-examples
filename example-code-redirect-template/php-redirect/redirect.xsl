<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
	Redirect Template
	
	Contributors: Brian Laird
	Last Updated: 06/2017
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<xsl:import href="functions.xsl"/>
	<xsl:import href="variables.xsl"/>
	
	<xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8" include-content-type="no" omit-xml-declaration="yes"/>
	
	<xsl:template match="/document">
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:processing-instruction name="php">
					header('Location: <xsl:value-of select="concat('', ou:pcf-param('redirect-url'))" />');
				</xsl:processing-instruction>
			</xsl:when>
			<xsl:otherwise>
				<html lang="en">
					
					<head>
						<link href="//netdna.bootstrapcdn.com/bootswatch/3.1.0/cerulean/bootstrap.min.css" rel="stylesheet"/>
						<link href="/_resources/css/oustaging.css" rel="stylesheet" />
						<style>
							body{
							font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
							}
							.ox-regioneditbutton {
							display: none;
							}
						</style>
					</head>
					
					<body id="properties">
						
						<div class="container">
							<h1>Redirect Updates</h1>
							To edit where this page will redirect to, please check out this page and go to the Page Properties screen.<br/>
							Changes will take effect upon publish. <br/>
							
							<br/>
							
							<h2>Properties for this template:</h2>
							
							<dl>	
								<xsl:for-each select="ouc:properties[@label='config']/parameter/@prompt">
									<dt><xsl:value-of select="../@prompt"/></dt>
									<dd><xsl:value-of select=".."/></dd>
								</xsl:for-each>
							</dl>	 
							
							
						</div>
						
						<div style="display:none;">
							<ouc:div label="fake" group="fake" button="hide"/>
						</div>
						
					</body>
				</html>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
