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

<!-- 
	Implementation Core Skeleton - 08/24/2018, Do NOT Change

	Functions XSL
	Repository of active functions
-->

<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">

	<!-- This function takes in one parameter and outputs the proper code to include the file on the page. -->
	<xsl:function name="ou:include-file">
		<!-- directory name + file name -->
		<xsl:param name="fullpath" />

		<!-- make click tip button -->
		<xsl:call-template name="ou-click-tip-button">
			<xsl:with-param name="id" select="$fullpath" />
		</xsl:call-template>
		<!-- output the search tag starting -->
		<xsl:copy-of select="ou:search-ignore-tag-start()" />
		<!-- on publish, it will output the proper SSI code, but on staging we require the omni div tag -->
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:copy-of select="ou:ssi($fullpath)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment> ouc:div label="<xsl:value-of select="$fullpath"/>" path="<xsl:value-of select="$fullpath"/>"</xsl:comment> <xsl:comment> /ouc:div </xsl:comment> 
			</xsl:otherwise>
		</xsl:choose>
		<!-- output the search tag ending -->
		<xsl:copy-of select="ou:search-ignore-tag-end()" />
	</xsl:function>

	<!-- this function output the server side include for the published pages, uses the variable $include-type to determine the output <br/> supported $include-type are: 'php' - PHP, 'c#' - ASP/C# , 'cf' - Cold Fusion -->
	<xsl:function name="ou:ssi">
		<xsl:param name="fullpath"/>
		<xsl:choose>
			<xsl:when test="$include-type = 'php'">
				<xsl:processing-instruction name="php"> include($_SERVER['DOCUMENT_ROOT'] . "<xsl:value-of select="$fullpath" />"); ?</xsl:processing-instruction>
			</xsl:when>
			<xsl:when test="$include-type = 'c#'">
				<xsl:comment>#include virtual="<xsl:value-of select="$fullpath" />" </xsl:comment>
			</xsl:when>
			<xsl:when test="$include-type = 'cf'">
				<cfoutput><cfinclude template="{$fullpath}" /></cfoutput>
			</xsl:when>
			<xsl:otherwise>
				<p>Include type not defined correctly. Please verify in the variables.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- function that is the full include path to a script -->
	<xsl:function name="ou:ssi-full">
		<xsl:param name="fullpath"/>
		<xsl:choose>
			<xsl:when test="$include-type = 'php'">
				<xsl:processing-instruction name="php"> include("<xsl:value-of select="concat($ou:www-ftproot, $fullpath)" />"); ?</xsl:processing-instruction>
			</xsl:when>
			<xsl:when test="$include-type = 'c#'">
				<!-- example of c#, read file in as a string and display the content from two levels, you might have to change if you go up a different amount of levels -->
				<xsl:text disable-output-escaping="yes">&lt;% </xsl:text> 
				wwwftproot = @"<xsl:value-of select="$ou:www-ftproot"/>";
				fullpath = @"<xsl:value-of select="$fullpath"/>";
				root = Server.MapPath("~");
				parent = System.IO.Path.GetDirectoryName(root);
				grandParent = System.IO.Path.GetDirectoryName(System.IO.Path.GetDirectoryName(parent));
				global = string.Concat(grandParent,wwwftproot, fullpath);
				contents = System.IO.File.ReadAllText(global);
				Response.Write(contents);
				<xsl:text disable-output-escaping="yes">%&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<p>Include type not defined correctly. Please verify in the variables.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Grab file from production on staging and output a server side include on publish -->
	<xsl:template name="unparsed-include-file">
		<xsl:param name="path"/>
		<xsl:param name="global" select="false()" />
		<xsl:variable name="prod-path" select="concat($domain, $path)" />
		<xsl:variable name="main-prod-path" select="concat($ou:www-domain, $path)" />

		<!-- make click tip button -->
		<xsl:call-template name="ou-click-tip-button">
			<xsl:with-param name="id" select="$path" />
		</xsl:call-template>
		
		<!-- output the search tag starting -->
		<xsl:copy-of select="ou:search-ignore-tag-start()" />
		<!-- is the file global or not? -->
		<xsl:choose>
			<xsl:when test="$global = true()">
				<xsl:choose>
					<xsl:when test="unparsed-text-available($main-prod-path)">
						<xsl:choose>
							<xsl:when test="not($ou:action = 'pub')">
								<xsl:value-of select="unparsed-text($main-prod-path)" disable-output-escaping="yes"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="ou:ssi-full($path)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="not($ou:action = 'pub')">
								<p style="word-break: break-word"><xsl:value-of select="concat('File not available. Please make sure the path ( ' ,$main-prod-path ,' ) is correct and the file is published.')" /></p>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="ou:ssi-full($path)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="unparsed-text-available($prod-path)">
						<xsl:choose>
							<xsl:when test="not($ou:action = 'pub')">
								<xsl:value-of select="unparsed-text($prod-path)" disable-output-escaping="yes"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="ou:ssi($path)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="not($ou:action = 'pub')">
								<p style="word-break: break-word"><xsl:value-of select="concat('File not available. Please make sure the path ( ' ,$prod-path ,' ) is correct and the file is published.')" /></p>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="ou:ssi($path)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<!-- output the search tag ending -->
		<xsl:copy-of select="ou:search-ignore-tag-end()" />
	</xsl:template>

	<!-- 
	PCF PARAMS
	An extremely useful function for getting page properties without needing to type the full xpath.
	How to use:
	The pcf has a parameter, name="page-type". To get the value and store it in an XSL param :
	<xsl:param name="page-type" select="ou:pcf-param('page-type')"/> 
	<xsl:param name="props-tile" select="ou:pcf-param('section-title',$props-doc)"/>
	-->

	<!-- save all page properties in a variable -->
	<xsl:param name="pcf-params" select="/document/descendant::parameter"/> 
	
	<!-- Get PCF params from an external document -->
	<xsl:function name="ou:pcf-param">
		<xsl:param name="name" as="xs:string"/>
		<xsl:param name="doc" as="document-node()?"/>
		
		<xsl:if test="$doc">
			<xsl:variable name="external-params" select="$doc/descendant::parameter"/>
			<xsl:call-template name="pcf-param">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="pcf-params" select="$external-params"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:function>
	
	<!-- Get a param from default parameter list -->
	<xsl:function name="ou:pcf-param">
		<xsl:param name="name"/>
		<xsl:call-template name="pcf-param">
			<xsl:with-param name="name" select="$name"/>
		</xsl:call-template>
	</xsl:function>
	
	<!-- Get a param from a provided parameter list -->
	<xsl:template name="pcf-param">
		<xsl:param name="name"/>
		<xsl:param name="pcf-params" select="$pcf-params"/>
		<xsl:variable name="parameter" select="$pcf-params[@name=$name]"/>
		<xsl:choose>
			<xsl:when test="$parameter/@type = 'select' or $parameter/@type = 'radio'">
				<xsl:value-of select="$parameter/option[@selected = 'true']/@value"/>
			</xsl:when>
			<xsl:when test="$parameter/@type = 'checkbox'">
				<xsl:copy-of select="$parameter/option[@selected = 'true']/@value"/>
			</xsl:when>
			<xsl:when test="$parameter/@type = 'asset'">
				<xsl:copy-of select="$parameter/node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$parameter/text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
	<!-- 
	Grab field from multiedit by providing ouc:div label.
	Specify a second string argument - this is useful for 
	loops where multi-edit fields are the same except for a 
	position suffix in the ouc:div label.
	
	ex:
	<xsl:param name="var-1" select="ou:multiedit-field('hero-image')"/> => <ouc:div label="hero-image"/>  
	<xsl:param name="var-2" select="ou:multiedit-field('button',$position)"/> => <ouc:div label="button-1"/>  
	-->

	<!-- save all multi edit fields in a variable <ouc:div label="hero-image"/> --> 
	<xsl:param name="multiedit-fields" select="/document/descendant::ouc:div[ouc:multiedit]"/>
	
	<!-- get the multi edit field by label of ouc:div -->
	<xsl:function name="ou:multiedit-field">
		<xsl:param name="name" as="xs:string"/>
		<xsl:copy-of select="$multiedit-fields[@label=$name]" copy-namespaces="no"/>
	</xsl:function>

	<!-- get the multi edit field by label of ouc:div, a pass a second parameter of a number and you will get <ouc:div label="button-1"/> -->
	<xsl:function name="ou:multiedit-field"> 
		<xsl:param name="name" as="xs:string"/>
		<xsl:param name="position"/>
		<xsl:copy-of select="$multiedit-fields[@label=concat($name,'-',$position)]"/>
	</xsl:function>

	<!--
		OU GET TEXTUAL CONTENT
		Use when checking for any content (prep for an "if empty" check)
		Gets string representation of any node and its subnodes, replaces &nbsp; with space, and trims all whitespace
	-->
	<xsl:function name="ou:textual-content" as="xs:string?">
		<xsl:param name="element" as="node()*"/>
		<xsl:copy-of select="normalize-space(replace(string-join($element, ' '), '&nbsp;', ' '))" />
	</xsl:function>
	
	<!-- get the individual tags for a specific page, does not include fixed tags-->
	<xsl:function name="ou:get-tags">
		<xsl:param name="path" as="xs:string" />
		<xsl:variable name="tagapi" select="concat('ou:/Tag/GetTags?site=', $ou:site, '&amp;path=', iri-to-uri($path))" />
		<xsl:if test="doc($tagapi)/tags != ''">
			<xsl:apply-templates select="doc($tagapi)/tags/tag">
				<xsl:sort select="./name" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:function>
	
	<!-- get the the collection children tags -->
	<xsl:function name="ou:get-collection-children-tags">
		<xsl:param name="collection" as="xs:string" />
		<xsl:variable name="tagapi" select="concat('ou:/Tag/GetChildren?tag=', $collection)" />
		<xsl:if test="doc($tagapi)/tags != ''">
			<xsl:apply-templates select="doc($tagapi)/tags/tag">
				<xsl:sort select="./name" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:function>
	
	<!-- Utility functions used by other standard skeleton files -->
	
	<!--
		Function: ou:parent-path($path)
		Used by breadcrumbs xsl. Parses a path as string and returns the path
	-->
	<xsl:function name="ou:parent-path"> <!-- outputs parent directory path with trailing '/': /path/to/parent/ -->
		<xsl:param name="path" as="xs:string?" />
		<xsl:variable name="token-path" select="tokenize(substring($path, 2), '/')[if(substring($path,string-length($path)) = '/') then position() != last() else position()]" />
		<xsl:variable name="new-path" select="concat('/', string-join(remove($token-path, count($token-path)), '/') ,'/')"/>
		<xsl:value-of select="if($new-path = '//') then '/' else $new-path" />
	</xsl:function>

	<!-- default template for the click tip button, makes it so you can call functions from any module -->
	<xsl:template name="ou-click-tip-button">
		<xsl:param name="id" />
	</xsl:template>

	<!-- variable to enable OU Search ignore tags -->
	<xsl:variable name="enable-ou-search-tags" select="false()"/>

	<!-- function to output the starting ignore tag for OU Search -->
	<xsl:function name="ou:search-ignore-tag-start">
		<xsl:if test="$enable-ou-search-tags">
			<xsl:comment> OU Search Ignore Start Here </xsl:comment>
		</xsl:if>
	</xsl:function>

	<!-- function to output the ending ignore tag for OU Search -->
	<xsl:function name="ou:search-ignore-tag-end">
		<xsl:if test="$enable-ou-search-tags">
			<xsl:comment> OU Search Ignore End Here </xsl:comment>
		</xsl:if>
	</xsl:function>

	<xsl:function name="ou:get-folder-properties" expand-text="yes">
		<xsl:param name="folder-path" />
		<xsl:variable name="dirapi" select="'ou:/Directories/GetProperties?site=' || $ou:site || '&amp;path=' || $folder-path" />
		<xsl:if test="doc-available($dirapi)">
			<xsl:copy-of select="doc($dirapi)" />
		</xsl:if>
	</xsl:function>

	<xsl:function name="ou:get-individual-folder-properties" expand-text="yes">
		<xsl:param name="folder-path" />
		<xsl:variable name="last-character" select="substring($folder-path, string-length($folder-path))" />
		<xsl:variable name="slash" select="'/'" />
		<xsl:variable name="all-folder-properties" select="ou:get-folder-properties($folder-path)" />
		<xsl:choose>
			<xsl:when test="$all-folder-properties">
				<xsl:choose>
					<xsl:when test="$folder-path = $slash or $last-character = $slash">
						<xsl:copy-of select="$all-folder-properties/folders/folder[@path = $folder-path]" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$all-folder-properties/folders/folder[@path = $folder-path || $slash]" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>System Message: Unable to find Folder Properties for "{$folder-path}".</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>