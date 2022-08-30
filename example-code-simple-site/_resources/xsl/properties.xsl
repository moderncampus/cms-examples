<?xml version="1.0" encoding="UTF-8"?>
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

	<xsl:template match="/document">
		<html lang="en">
			<head>
				<link href="//netdna.bootstrapcdn.com/bootswatch/3.1.0/cerulean/bootstrap.min.css" rel="stylesheet"/>
			</head>
			<body id="properties">
				<div class="container">
					<h1>Section Properties</h1>
					<p>To edit the following section propeties, please check out this page and go to the Page Properties screen.<br />
					Changes will take effect immediately OU Campus - this file does not need to be published.<br /> 
					However, the PCF files in this folder must be republished for changes to appear on <xsl:value-of select="concat($domain,$dirname)"/>.</p>
					<h2>Properties for the folder "<xsl:value-of select="if ($ou:dirname!='/') then(normalize-space(ou:current_folder($ou:dirname))) else '/'"/>"</h2>
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
	</xsl:template>
</xsl:stylesheet>
