<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="xsl xs ou ouc">
	
	<xsl:template name="output-cms-breadcrumbs">
		<xsl:param name="current-dir" select="$ou:dirname" as="xs:string"/>
		<!-- get the breadcrumbs -->
		<xsl:apply-templates select="ou:get-folder-properties($current-dir)" mode="cms-breadcrumbs" />
		<!-- only output the current crumb if not the index file -->
		<xsl:if test="$ou:filename != $index-filename">
			<xsl:call-template name="cms-breadcrumb-output">
				<xsl:with-param name="type" select="'current'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="folders" mode="cms-breadcrumbs" expand-text="yes">
		<!-- gather all the breadcrumb-stop folder levels -->
		<xsl:variable name="all-stops" select="folder[breadcrumb-stop = 'true']/@level"/>
		<!-- get the nearst stop -->
		<xsl:variable name="nearest-stop" select="$all-stops[last()]" />
		<!-- check to see if there is actually any stops, otherwise go all the way to the root -->
		<xsl:variable name="cleanned-stop" select="if (number($nearest-stop) = $nearest-stop) then 
												$nearest-stop
												else 0" as="xs:integer"/>
		<!-- start the loop at the last value in the stop -->
		<xsl:for-each select="folder[number(@level) >= $cleanned-stop]">
			<xsl:choose>
				<xsl:when test="breadcrumb-skip = 'true'">
					<xsl:if test="$is-edt">
						<xsl:call-template name="cms-breadcrumb-output">
							<xsl:with-param name="folder" select="current()" />
							<xsl:with-param name="message">System Message: Breadcrumb Skipped at {@path}.</xsl:with-param>
							<xsl:with-param name="type" select="'skipped'" />
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@path = '/'">
					<xsl:call-template name="cms-breadcrumb-output">
						<xsl:with-param name="folder" select="current()" />
						<xsl:with-param name="type" select="'root'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="cms-breadcrumb-output">
						<xsl:with-param name="folder" select="current()" />
						<xsl:with-param name="type" select="if ((@path || $index-filename) = $ou:path) then 'index' else 'general'" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>