<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
=========================	
FULL XML
Gathers XML for the entire user-editable section of the course catalog. 
Disable try-catch statements to debug.
=========================
-->
<xsl:stylesheet expand-text="yes" version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou ouc fo">

	<xsl:param name="root" select="concat($ou:root,$ou:site)"/>

	<!-- Gather catalog data -->
	<xsl:param name="full-xml">
		<xsl:variable name="top-dir">
			<directory>{$version}</directory>
		</xsl:variable>
		<catalog>
			<xsl:apply-templates select="$top-dir" mode="get-staging-files"/>
		</catalog>
	</xsl:param>

	<!-- Regulatory Directories -->
	<xsl:template match="directory[not(starts-with(text(),'_'))]" mode="get-staging-files">
		<xsl:param name="current-path"/>
		<xsl:variable name="new-path" select="concat($current-path,'/',.)"/>
		<!-- directory information comes from index file -->
		<directory type="regulatory">
			<!-- Set type to distinguish from special directories, just in case.... -->
			<!--			<xsl:try>-->
			<xsl:variable name="doc" select="document(concat($root,$new-path,'/index.pcf'))"/>
			<xsl:call-template name="document-info">
				<xsl:with-param name="doc" select="$doc"/>
				<xsl:with-param name="path" select="$new-path"/>
			</xsl:call-template>
			<xsl:if test="ou:pcf-param('full-pdf',$doc)='true'">
				<!-- INDEX PAGE NODE -->
				<index>
					<xsl:call-template name="page-info">
						<xsl:with-param name="doc" select="$doc"/>
						<xsl:with-param name="file-path" select="concat($new-path,'/index.pcf')"/>
					</xsl:call-template>
				</index>
				<!-- /INDEX PAGE NODE -->
			</xsl:if>
			<!--			<xsl:catch />-->
			<!--</xsl:try>-->
			<!-- Traverse any subdirectories -->
			<!-- if windows use this doc call
				<xsl:apply-templates select="doc(concat('file:',$root,$new-path))/list" mode="get-staging-files">
			-->
			<xsl:apply-templates select="doc(concat($root,$new-path))/list" mode="get-staging-files">
				<xsl:with-param name="current-path" select="$new-path"/>
			</xsl:apply-templates>
		</directory>
	</xsl:template>

	<!-- Special Directories -->
	<!-- 
		These directories generally only have Index page content ,
		w/ the rest of the content is pulled in from XML, or w/ pages that should be displayed in a special mode. 
		Example: <xsl:template match="directory[text()='courses' or text()='degrees-programs' or text()='faculty-staff']" priority="1" mode="get-staging-files">
	-->
	<xsl:template match="directory[text()='courses']" priority="1" mode="get-staging-files">
		<xsl:param name="current-path"/>
		<xsl:variable name="new-path" select="concat($current-path,'/',.)"/>
		<directory type="{.}">
			<!-- 
				Set a type="" to distinguish this directory from others.
				Example: Type is the foldername. 
			-->
			<xsl:try>
				<!-- directory information comes from index file -->
				<xsl:variable name="doc" select="document(concat($root,$new-path,'/index.pcf'))"/>
				<xsl:call-template name="document-info">
					<xsl:with-param name="doc" select="$doc"/>
					<xsl:with-param name="path" select="$new-path"/>
				</xsl:call-template>
				<xsl:if test="ou:pcf-param('full-pdf',$doc)='true'">
					<!-- INDEX PAGE NODE -->
					<index>
						<xsl:call-template name="page-info">
							<xsl:with-param name="doc" select="$doc"/>
							<xsl:with-param name="file-path" select="concat($new-path,'/index.pcf')"/>
						</xsl:call-template>
					</index>
					<!-- /INDEX PAGE NODE -->
				</xsl:if>
				<xsl:catch/>
			</xsl:try>
		</directory>
		<!-- No information about external data required here - it can be added in FULL-PDF based on TYPE flag. -->
	</xsl:template>

	<!-- Regulatory Pages -->
	<xsl:template match="file[not(starts-with(text(),'index'))]" mode="get-staging-files">
		<xsl:param name="current-path"/>
		<!-- acquire information from pcf -->
		<!--		<xsl:try>-->
		<xsl:variable name="doc" select="document(concat($root,$current-path,'/',.))"/>
		<xsl:if test="ou:pcf-param('full-pdf',$doc)='true'">
			<!-- PAGE NODE -->
			<page>
				<xsl:call-template name="page-info">
					<xsl:with-param name="doc" select="$doc"/>
					<xsl:with-param name="path" select="$current-path"/>
				</xsl:call-template>
			</page>
			<!-- /PAGE NODE -->
		</xsl:if>
		<!--		<xsl:catch />-->
		<!--</xsl:try>-->
	</xsl:template>

	<!-- A match for ignoring non-xml files like _nav.inc -->
	<xsl:template match="file[ends-with(text(), '.inc')]" mode="get-staging-files"/>


	<!-- ============================================
		Common page and section attributes
	=============================================== -->

	<xsl:template name="page-info">
		<xsl:param name="doc"/>
		<xsl:param name="path"/> <!-- directory-->
		<xsl:param name="file-path" select="concat($path,'/',.)"/>
		<!-- Special page types -->
		<xsl:if test="starts-with(.,'_')">
			<xsl:attribute name="type" select="substring-before(substring-after(.,'_'),'.')"/>
		</xsl:if>
		<!-- global attributes -->
		<xsl:attribute name="path" select="$file-path"/>
		<xsl:attribute name="weight" select="normalize-space(ou:pcf-param('page-weight',$doc))"/>	
		<!-- page contents -->
		<xsl:attribute name="title" select="ou:pcf-param('heading',$doc)"/>
		<xsl:call-template name="page-tags">
			<xsl:with-param name="tags" select="ou:pcf-param('index-keywords',$doc)"/>
		</xsl:call-template>
		<content>
			<xsl:apply-templates select="$doc/document/ouc:div[@label='maincontent']/node()" mode="copy-content"/>
		</content>
	</xsl:template>

	<xsl:template name="document-info">
		<xsl:param name="doc"/>
		<xsl:param name="path"/>
		<xsl:attribute name="title" select="ou:pcf-param('breadcrumb',document(concat($root,$path,'/',$props-file)))"/>
		<xsl:attribute name="path" select="$path"/>
		<xsl:attribute name="weight" select="normalize-space(ou:pcf-param('page-weight',$doc))"/>
	</xsl:template>

	<!-- ============================================
		Indentity Template & defaults
	=============================================== -->

	<xsl:template match="directory|file" mode="get-staging-files"/>
	<xsl:template match="element()" mode="copy-content">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="attribute()|node()" mode="#current"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="attribute()|text()|comment()" mode="copy-content">
		<xsl:copy/>
	</xsl:template>
	<xsl:template match="ouc:editor|processing-instruction()" mode="copy-content"/>

	<!-- ============================================
		Index Data
	=============================================== -->

	<!-- XML for each page that has tags -->
	<xsl:template name="page-tags">
		<xsl:param name="tags"/>
		<xsl:if test="$tags!=''">
			<tags>
				<xsl:for-each select="tokenize($tags,',')">
					<xsl:variable name="tag" select="normalize-space(.)"/>
					<!-- differentiate between original and normalized tag to allow some margin of user error -->
					<tag letter="{upper-case(substring($tag,1,1))}" original="{$tag}" normalized="{lower-case($tag)}"/>
				</xsl:for-each>
			</tags>
		</xsl:if>
	</xsl:template>
	
	<!-- Full listing of tags, grouped by letter and sorted by page weight -->
	<xsl:param name="index-xml">
		<index>
			<!-- group by letter -->
			<xsl:for-each-group select="$full-xml/descendant::tag" group-by="@letter">			
				<letter-group letter="{current-grouping-key()}">
					<!-- loop thru each distinct tag -->
					<xsl:for-each-group select="current-group()" group-by="@normalized">
						<xsl:variable name="this-tag" select="@normalized"/>
						<tag name="{@original}">
							<files>
								<xsl:apply-templates select="$full-xml/catalog/directory/index" mode="particular-tag">
									<xsl:with-param name="desired-tag" select="$this-tag"/>
								</xsl:apply-templates>
								<xsl:apply-templates select="$full-xml/catalog/directory/page|$full-xml/catalog/directory/directory" mode="particular-tag">
									<xsl:sort select="@weight" data-type="number" order="descending"/>
									<xsl:sort select="@title"/>
									<xsl:with-param name="desired-tag" select="$this-tag"/>
								</xsl:apply-templates>
							</files>	
						</tag>
					</xsl:for-each-group>				
				</letter-group>
			</xsl:for-each-group>
		</index>
	</xsl:param>
	
	<xsl:template mode="particular-tag top-tag" match="index|page">
		<xsl:param name="desired-tag"/>
		<xsl:if test="tags/tag[@normalized=$desired-tag]">		
			<file tag="{$desired-tag}" path="{@path}"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="particular-tag" match="directory">
		<xsl:param name="desired-tag"/>
		<xsl:apply-templates select="index" mode="particular-tag">
			<xsl:with-param name="desired-tag" select="$desired-tag"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="page" mode="particular-tag">
			<xsl:with-param name="desired-tag" select="$desired-tag"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="directory" mode="particular-tag">
			<xsl:with-param name="desired-tag" select="$desired-tag"/>
		</xsl:apply-templates>
	</xsl:template>
	
</xsl:stylesheet>