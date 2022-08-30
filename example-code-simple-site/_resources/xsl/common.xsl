<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- Simple Site Skeleton 10/2/18 -->
<xsl:stylesheet version="3.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:fn="http://omniupdate.com/XSL/Functions"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou fn ouc">
	
	<xsl:import href="variables.xsl"/>
	<xsl:import href="functions.xsl"/>
	<xsl:import href="breadcrumb.xsl"/>
	
	<!-- Default: for HTML5 use below output declaration -->
	<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no"/>
	
	<xsl:template match="/document">
		<html lang="en">
			<head>
				<xsl:copy-of select="ou:include-file('/_resources/includes/headcode.inc')"/>
				<xsl:apply-templates select="headcode/node()" mode="copy"/>
				<title><xsl:value-of select="$pageTitle"/></title>			
				<xsl:apply-templates select="/document/ouc:properties[@label='metadata']/meta[string-length(@content)>0]" mode="copy"/>
			</head>
			<body>
				<xsl:apply-templates select="bodycode/node()" mode="copy"/>
				<div class="container">
					<div class="row">
						<div class="col-md-12 column">
							<xsl:copy-of select="ou:include-file('/_resources/includes/header.inc')"/>
							<xsl:call-template name="page-content"/>
						</div>
					</div>
				</div>
				<xsl:copy-of select="ou:include-file('/_resources/includes/footer.inc')"/>
				<xsl:copy-of select="ou:include-file('/_resources/includes/footcode.inc')"/>
				<div style="display:none;" id="de"><xsl:comment> com.omniupdate.ob </xsl:comment><xsl:comment> /com.omniupdate.ob </xsl:comment></div>
				<xsl:apply-templates select="footcode/node()" mode="copy"/>	
			</body>	
		</html>
	</xsl:template>
	<!-- Identity Matches -->
	<xsl:mode on-no-match="shallow-copy" name="copy"/>
	<xsl:template match="processing-instruction('pcf-stylesheet')" mode="#all" />
	<xsl:template match="ouc:*[$ou:action !='edt']" mode="#all">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	<xsl:template name="page-content" />
</xsl:stylesheet>