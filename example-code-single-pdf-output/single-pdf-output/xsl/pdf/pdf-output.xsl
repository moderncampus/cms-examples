<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
=========================
PDF output
Interface to edit the core structure and layout of the PDF output.
Applicable to individual pdf output.
=========================
-->
<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				xmlns:fo="http://www.w3.org/1999/XSL/Format"
				exclude-result-prefixes="xsl xs ou fn ouc">

	<!-- Omni CMS variables and other variables -->
	<xsl:import href="../_shared/variables.xsl"/>

	<!-- pdf functions (relative link convert...) -->
	<xsl:import href="../_shared/functions.xsl"/>

	<!-- pdf style (font family, size...) -->
	<xsl:import href="style.xsl"/>

	<!-- conversion from html to pdf format -->
	<xsl:import href="html-to-xslfo.xsl"/>

	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:strip-space elements="*"/>

	<!-- determine the page type from the page property dropdown -->
	<xsl:param name="page-type"><xsl:value-of select="ou:pcf-param('pdf-layout')" /></xsl:param>

	<!-- the document of the PDF -->
	<xsl:template match="/document">
		<fo:root role="document" xml:lang="en">
			<xsl:call-template name="master-set"/>
			<xsl:call-template name="metadata"/>
			<fo:page-sequence master-reference="document-{$page-type}" xsl:use-attribute-sets="text">
				<xsl:call-template name="header"/>
				<xsl:call-template name="footer"/>
				<xsl:call-template name="page-content"/>
			</fo:page-sequence>
		</fo:root>
	</xsl:template>

	<!-- the PDF content on output -->
	<xsl:template name="page-content">
		<fo:flow flow-name="xsl-region-body">
			<fo:block xsl:use-attribute-sets="h1">PDF Example</fo:block>
			<xsl:if test="normalize-space(ou:pcf-param('heading')) != ''">
				<fo:block xsl:use-attribute-sets="h2"><xsl:value-of select="ou:pcf-param('heading')"/></fo:block>
			</xsl:if>
			<fo:block>
				<xsl:apply-templates select="ouc:div[@label='maincontent']/node()" />
			</fo:block>
		</fo:flow>
	</xsl:template>

	<!-- outputs the PDF metadata -->
	<xsl:template name="metadata">
		<!-- fo:declarations must be declared after fo:layout-master-set and before the first page-sequence. -->
		<fo:declarations>
			<x:xmpmeta xmlns:x="adobe:ns:meta/">
				<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
					<rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
						<!-- Dublin Core properties go here -->
						<dc:title><xsl:value-of select="if (ou:pcf-param('meta-title') != '') then ou:pcf-param('meta-title') else /document/ouc:properties/title" /></dc:title>
						<dc:creator><xsl:value-of select="ou:pcf-param('meta-author')" /></dc:creator>
						<dc:description><xsl:value-of select="if (ou:pcf-param('meta-subject') != '') then ou:pcf-param('meta-subject') else ouc:properties[@label='metadata']/meta[@name='description']/@content" /></dc:description>
					</rdf:Description>
					<rdf:Description rdf:about="" xmlns:xmp="http://ns.adobe.com/xap/1.0/">
						<!-- XMP Basic properties go here -->
						<xmp:CreatorTool>Omni CMS</xmp:CreatorTool><!-- Tool used to make the PDF -->
					</rdf:Description>
					<rdf:Description rdf:about="" xmlns:pdf="http://ns.adobe.com/pdf/1.3/">
						<!-- Adobe PDF Schema properties go here -->
						<pdf:Keywords><xsl:value-of select="ou:pcf-param('meta-keywords')" /></pdf:Keywords>
					</rdf:Description>
				</rdf:RDF>
			</x:xmpmeta>
		</fo:declarations>
	</xsl:template>

	<xsl:template name="master-set">
		<!--
			A master set consists of definitions for templates (that define content layout) and patterns (that define multiple templates in a section). 

			<fo:simple-page-master> defines a template, or layouts.
			In a template, a region start, end, before, after may be defined with the appropriate size, or extent. 
			Following that, the region body must be defined with optional margins.

			<fo:page-sequence-master> defines the pattern of templates used in a section.

			For example, there may be a different template used for even/odd pages and/or the first/last. (as defined by ordered <fo:conditional-page-master-reference>).
			In the output of a PDF, a <fo:page-sequence-master> must be referenced for each section (instance of <fo:page-sequence>) 
		-->
		<fo:layout-master-set>
			<!-- 1 column -->
			<fo:simple-page-master master-name="PDF" xsl:use-attribute-sets="default-page-attributes">
				<fo:region-body xsl:use-attribute-sets="region-body-defaults"/>
				<fo:region-before region-name="header" extent="0.25in"/>
				<fo:region-after region-name="footer" extent="0.25in"/>
			</fo:simple-page-master>
			<fo:simple-page-master master-name="PDF-even" xsl:use-attribute-sets="default-page-attributes">
				<fo:region-body xsl:use-attribute-sets="region-body-defaults"/>
				<fo:region-before region-name="header-even" extent="0.25in"/>
				<fo:region-after region-name="footer-even" extent="0.25in"/>
			</fo:simple-page-master>

			<!-- 2 column -->
			<fo:simple-page-master master-name="PDF-2col" xsl:use-attribute-sets="default-page-attributes">
				<fo:region-body xsl:use-attribute-sets="region-body-defaults" column-count="2" column-gap="0.25in"/>
				<fo:region-before region-name="header" extent="0.25in"/>
				<fo:region-after region-name="footer" extent="0.25in"/>
			</fo:simple-page-master>
			<fo:simple-page-master master-name="PDF-2col-even" xsl:use-attribute-sets="default-page-attributes">
				<fo:region-body xsl:use-attribute-sets="region-body-defaults" column-count="2" column-gap="0.25in"/>
				<fo:region-before region-name="header-even" extent="0.25in"/>
				<fo:region-after region-name="footer-even" extent="0.25in"/>
			</fo:simple-page-master>

			<!-- 3 column -->
			<fo:simple-page-master master-name="PDF-3col" xsl:use-attribute-sets="default-page-attributes">
				<fo:region-body xsl:use-attribute-sets="region-body-defaults" column-count="3" column-gap="0.25in"/>
				<fo:region-before region-name="header" extent="0.25in"/>
				<fo:region-after region-name="footer" extent="0.25in"/>
			</fo:simple-page-master>
			<fo:simple-page-master master-name="PDF-3col-even" xsl:use-attribute-sets="default-page-attributes">
				<fo:region-body xsl:use-attribute-sets="region-body-defaults" column-count="3" column-gap="0.25in"/>
				<fo:region-before region-name="header-even" extent="0.25in"/>
				<fo:region-after region-name="footer-even" extent="0.25in"/>
			</fo:simple-page-master>

			<!-- 1 Column Sequence -->
			<fo:page-sequence-master master-name="document-1col">
				<fo:repeatable-page-master-alternatives>
					<fo:conditional-page-master-reference odd-or-even="odd" master-reference="PDF"/>
					<fo:conditional-page-master-reference odd-or-even="even" master-reference="PDF-even"/>
				</fo:repeatable-page-master-alternatives>
			</fo:page-sequence-master>

			<!-- 2 Column Sequence -->
			<fo:page-sequence-master master-name="document-2col">
				<fo:repeatable-page-master-alternatives>
					<fo:conditional-page-master-reference odd-or-even="odd" master-reference="PDF-2col"/>
					<fo:conditional-page-master-reference odd-or-even="even" master-reference="PDF-2col-even"/>
				</fo:repeatable-page-master-alternatives>
			</fo:page-sequence-master>

			<!-- 3 Column Sequence -->
			<fo:page-sequence-master master-name="document-3col">
				<fo:repeatable-page-master-alternatives>
					<fo:conditional-page-master-reference odd-or-even="odd" master-reference="PDF-3col"/>
					<fo:conditional-page-master-reference odd-or-even="even" master-reference="PDF-3col-even"/>
				</fo:repeatable-page-master-alternatives>
			</fo:page-sequence-master>
		</fo:layout-master-set>
	</xsl:template>

	<!-- the PDF header region -->
	<xsl:template name="header">
		<xsl:param name="header" select="if (ou:pcf-param('meta-title') != '') then ou:pcf-param('meta-title') else $page-title"/>
		<!-- header odd pages -->
		<fo:static-content flow-name="header">
			<fo:block border-bottom="1pt solid #000" text-align="right">
				<fo:inline>
					<xsl:value-of select="$header"/>
				</fo:inline>
				<fo:leader leader-length="0.5in"/>
				<fo:page-number/>
			</fo:block>
		</fo:static-content>
		<!-- header even pages -->
		<fo:static-content flow-name="header-even">
			<fo:block border-bottom="1pt solid #000">
				<fo:page-number/>
				<fo:leader leader-length="0.5in"/>
				<fo:inline>
					<xsl:value-of select="$header"/>
				</fo:inline>
			</fo:block>
		</fo:static-content>
	</xsl:template>

	<!-- the PDF footer region -->
	<xsl:template name="footer">
		<xsl:param name="footer" select="if (ou:pcf-param('meta-footer') != '') then ou:pcf-param('meta-footer') else $page-title"/>
		<!-- footer odd pages -->
		<fo:static-content flow-name="footer">
			<fo:block-container display-align="after" height="0.25in">
				<fo:block text-align-last="justify">
					<fo:inline>
						<xsl:value-of select="$footer"/>
					</fo:inline>
					<fo:leader leader-pattern="space"/>
					<fo:page-number/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<!-- footer even pages -->
		<fo:static-content flow-name="footer-even">
			<fo:block-container display-align="after" height="0.25in">
				<fo:block text-align-last="justify">
					<fo:inline>
						<fo:page-number/>
					</fo:inline>
					<fo:leader leader-pattern="space"/>
					<xsl:value-of select="$footer"/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>
</xsl:stylesheet>
