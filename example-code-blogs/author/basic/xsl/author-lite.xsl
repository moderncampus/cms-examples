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
    <xsl:import href="../common.xsl"/>
    
    <xsl:template name="template-headcode"/>
    <xsl:template name="template-footcode"/>
	
    <xsl:template name="page-content">
        <xsl:if test="$ou:action = 'edt'"><xsl:apply-templates select="ouc:div"/></xsl:if>
		<div role="main" class="main">

				<div class="container">

					<div class="row">
						<div class="col-md-9">
						    <h2>Author Information - <small>Use Multiedit to manage author information.</small></h2>
						    <p><strong>Image:</strong>&nbsp;
						        <xsl:choose>
						            <xsl:when test="author/ouc:div[@label='a-image']/img">
						                <xsl:copy-of select="author/ouc:div[@label='a-image']/img"/>
						            </xsl:when>
						            <xsl:otherwise>none</xsl:otherwise>
						        </xsl:choose></p>
						    <p><strong>Use Image:</strong>&nbsp; <xsl:value-of select="author/ouc:div[@label='use-img']"/></p>
						    <p><strong>Name:</strong>&nbsp;<xsl:value-of select="author/ouc:div[@label='a-name']"/></p>
						    <p><strong>Bio:</strong>&nbsp;<xsl:value-of select="author/ouc:div[@label='a-bio']"/></p>
						</div>

					</div>

				</div>

			</div>
	</xsl:template>
</xsl:stylesheet>
