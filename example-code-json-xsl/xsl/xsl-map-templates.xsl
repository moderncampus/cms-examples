<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
This file houses templates that convert a PCF into an <xsl:map> object.

Version: 1.0.0
Last Updated: 2019/05/21

Usage:

<xsl:import href="./path/to/xsl-map-templates.xsl"/>
<xsl:variable name="pcf-map" as="map(*)?">
	<xsl:apply-templates mode="pcf-to-xsl-map"/>
</xsl:variable>

<xsl:value-of select="serialize($pcf-map, $json-escape-map)"/>
-->
<xsl:stylesheet version="3.0" expand-text="yes"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables" exclude-result-prefixes="xs ou fn ouc">

	<xsl:param name="ou:stagingpath"/>
	<xsl:mode on-no-match="shallow-copy" />
	<xsl:mode on-no-match="shallow-skip" name="pcf-to-xsl-map"/>
	<xsl:mode on-no-match="shallow-skip" name="param-to-xsl-map"/>
	<xsl:mode on-no-match="shallow-skip" name="multiedit-to-xsl-map"/>
	<xsl:mode on-no-match="shallow-skip" name="edit-region-to-xsl-map"/>

	<xsl:template match="/document" mode="pcf-to-xsl-map">
		<xsl:param name="src" select="$ou:stagingpath" tunnel="true"/>

		<xsl:map>
			<xsl:map-entry key="'src'" select="$src"/>
			<xsl:map-entry key="'title'" select="string(descendant::title[1])"/>

			<xsl:map-entry key="'meta'">
				<xsl:map>
					<xsl:apply-templates select="descendant::meta" mode="meta-to-xsl-map"/>
				</xsl:map>
			</xsl:map-entry>

			<xsl:map-entry key="'properties'">
				<xsl:map>
					<xsl:apply-templates select="descendant::parameter" mode="param-to-xsl-map"/>
				</xsl:map>
			</xsl:map-entry>

			<xsl:map-entry key="'multiedit'">
				<xsl:map>
					<xsl:apply-templates select="descendant::ouc:div[ouc:multiedit]" mode="multiedit-to-xsl-map"/>
				</xsl:map>
			</xsl:map-entry>

			<xsl:map-entry key="'content'">
				<xsl:map>
					<xsl:apply-templates select="ouc:div[ouc:editor]" mode="edit-region-to-xsl-map"/>
				</xsl:map>
			</xsl:map-entry>
		</xsl:map>
	</xsl:template>

	<!--
		Templates for <meta> nodes
	-->
	<xsl:template match="meta" mode="meta-to-xsl-map">
		<xsl:map-entry key="@name" select="string(@content)"/>
	</xsl:template>

	<!--
		Templates for <parameter> nodes
		Asset fields are ignored
	-->
	<xsl:template match="parameter[not(@type=('asset'))]" mode="param-to-xsl-map">
		<xsl:map-entry key="@name" select="string(.)"/>
	</xsl:template>
	<xsl:template match="parameter[@type=('radio', 'select')]" mode="param-to-xsl-map">
		<xsl:map-entry key="@name" select="string(option[@selected='true']/@value)"/>
	</xsl:template>
	<xsl:template match="parameter[@type='checkbox']" mode="param-to-xsl-map">
		<xsl:map-entry key="@name">
			<xsl:map>
				<xsl:for-each select="option">
					<xsl:map-entry key="@value" select="@selected = 'true'"/>
				</xsl:for-each>
			</xsl:map>
		</xsl:map-entry>
	</xsl:template>

	<!--
		Templates for ouc:div/ouc:multiedit nodes
	-->
	<xsl:template match="ouc:div[ouc:multiedit]" mode="multiedit-to-xsl-map">
		<xsl:map-entry key="@label" select="string(.)"/>
	</xsl:template>
	<xsl:template match="ouc:div[ouc:multiedit[@type='image']]" mode="multiedit-to-xsl-map">
		<xsl:map-entry key="@label">
			<xsl:map>
				<xsl:map-entry key="'src'" select="string(img/@src)"/>
				<xsl:map-entry key="'alt'" select="string(img/@alt)"/>
			</xsl:map>
		</xsl:map-entry>
	</xsl:template>
	<xsl:template match="ouc:div[ouc:multiedit[@type='textarea'][@editor='yes']]" mode="multiedit-to-xsl-map">
		<xsl:variable name="content">
			<xsl:apply-templates select="node()[not(starts-with(name(), 'ouc:'))]"/>
		</xsl:variable>
		<xsl:map-entry key="@label">
			<xsl:copy-of select="$content" copy-namespaces="no"/>
		</xsl:map-entry>
	</xsl:template>
	<xsl:template match="ouc:div[ouc:multiedit[@type='checkbox']]" mode="multiedit-to-xsl-map">
		<xsl:variable name="selected" select="tokenize(., ',')"/>
		<xsl:map-entry key="@label">
			<xsl:map>
				<xsl:for-each select="tokenize(ouc:multiedit/@options, ';')">
					<xsl:variable name="option" select="tokenize(., ':')"/>
					<xsl:map-entry key="$option[1]" select="$option[2] = $selected"/>
				</xsl:for-each>
			</xsl:map>
		</xsl:map-entry>
	</xsl:template>

	<xsl:template match="ouc:div[ouc:editor]" mode="edit-region-to-xsl-map">
		<xsl:variable name="content">
			<xsl:apply-templates select="node()[not(starts-with(name(), 'ouc:'))]"/>
		</xsl:variable>
		<xsl:map-entry key="@label">
			<xsl:copy-of select="$content" copy-namespaces="no"/>
		</xsl:map-entry>
	</xsl:template>

</xsl:stylesheet>
