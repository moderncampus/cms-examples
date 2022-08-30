<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
=========================
HTML to XSL:fo conversion
Interface to edit PDF styling via template matches.
Applicable to individual pdf output.
=========================
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"	
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	exclude-result-prefixes="xs ou">

	<!-- ============================================
		Text Elements
	=============================================== -->
	
	<!-- Headings -->
	
	<xsl:template match="h1">
		<fo:block role="H1" xsl:use-attribute-sets="h1">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>		
	<xsl:template match="h2">
		<fo:block role="H2" xsl:use-attribute-sets="h2">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>		
	<xsl:template match="h3">
		<fo:block role="H3" xsl:use-attribute-sets="h3">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	<xsl:template match="h4">
		<fo:block role="H4" xsl:use-attribute-sets="h4">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	<xsl:template match="h5">
		<fo:block role="H5" xsl:use-attribute-sets="h5">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	<xsl:template match="h6">
		<fo:block role="H6" xsl:use-attribute-sets="h6">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	
	<!-- Paragraph -->
	
	<xsl:template match="p|div">
		<fo:block xsl:use-attribute-sets="p">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	
	<!-- ============================================
		Inline Elements
	=============================================== -->

	<!-- ============================================
		Links
	=============================================== -->

	<!-- Links -->	
	<xsl:template match="a">
		<fo:inline xsl:use-attribute-sets="a"><xsl:apply-templates select="attribute()"/></fo:inline>
	</xsl:template>

	<!-- anchor with no paragraph around it -->
	<xsl:template match="/document/ouc:div/a">
		<fo:block xsl:use-attribute-sets="p"><fo:inline xsl:use-attribute-sets="a"><xsl:apply-templates select="attribute()"/></fo:inline></fo:block>
	</xsl:template>
	
	<!-- Page Relative -->
	<xsl:template match="a/@href">	
		<fo:basic-link external-destination="{ou:convert-pr-link(.,concat($domain,if(ancestor::*/@id) then ou:remove-last-token(ancestor::*/@id,'/') else $ou:dirname))}">
			<xsl:apply-templates select="parent::a/node()" />
		</fo:basic-link>
	</xsl:template>

	<!-- Absolute -->
	<xsl:template match="a/@href[starts-with(.,'http://') or starts-with(.,'https://') or starts-with(., '//')]" priority="1">	
		<fo:basic-link external-destination="{.}">
			<xsl:apply-templates select="parent::a/node()" />
		</fo:basic-link>
	</xsl:template>
	
	<!-- Root Relative -->
	<xsl:template match="a/@href[starts-with(., '/')]" priority="1">
		<fo:basic-link external-destination="{.}">
			<xsl:apply-templates select="parent::a/node()"/>
		</fo:basic-link>	
	</xsl:template>
	
	<!-- Anchor -->
	<xsl:template match="a/@href[starts-with(., '#')]" priority="1">
		<fo:basic-link internal-destination="{substring(., 2)}">
			<xsl:apply-templates select="parent::a/node()"/>
		</fo:basic-link>	
	</xsl:template>
	
	<!-- email addresses -->
	<xsl:template match="a/@href[contains(., 'mailto:')]" priority="1">
		<fo:basic-link external-destination="{.}">
			<xsl:apply-templates select="parent::a/node()"/>
		</fo:basic-link>    
	</xsl:template>

	<!-- Placeholder -->
	<xsl:template match="a/@href[. = '#']" priority="2">
		<xsl:apply-templates select="parent::a/node()"/>
	</xsl:template>

	<!-- Unknown attributes -->
	<xsl:template match="a/attribute()" priority="-1" />

	<!-- ============================================
		Styled inline elements
	=============================================== -->

	<!-- bold & italic -->
	<!-- Usage: Certain fonts families use different fonts for bold and italic styling  -->	
	<xsl:template match="em[strong]|strong[em]|em[b]|b[em]|i[strong]|strong[i]|i[b]|b[i]">
		<fo:inline xsl:use-attribute-sets="em-strong"><xsl:apply-templates /></fo:inline>
	</xsl:template>
	
	<!-- italic -->
	<xsl:template match="em|i|var|time|cite">
		<fo:inline xsl:use-attribute-sets="em"><xsl:apply-templates /></fo:inline>
	</xsl:template>
	
	<!-- bold -->
	<xsl:template match="b|strong|mark">
		<xsl:choose>
			<xsl:when test="not(parent::em)">
				<fo:inline xsl:use-attribute-sets="strong">
					<xsl:apply-templates />
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline>
					<xsl:apply-templates />
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- underline -->
	<xsl:template match="u|ins">
		<fo:inline xsl:use-attribute-sets="u">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>
	
	<!-- Abbreviation -->
	<xsl:template match="abbr">
		<fo:inline xsl:use-attribute-sets="u">
			<xsl:value-of select="."/>
		</fo:inline>
		<fo:inline xsl:use-attribute-sets="em"> (<xsl:value-of select="@title"/>)</fo:inline>
	</xsl:template>
	
	<!-- strikethrough -->
	<xsl:template match="s|del">
		<fo:inline xsl:use-attribute-sets="s">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>
	
	<!-- subscript -->
	<xsl:template match="sub"> 
		<fo:inline xsl:use-attribute-sets="sub">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>
	
	<!-- super script -->
	<xsl:template match="sup"> 
		<fo:inline xsl:use-attribute-sets="sup">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>

	<!-- code-->
	<xsl:template match="code|kbd|samp"> 
		<fo:inline xsl:use-attribute-sets="code">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>
	
	<!-- small-->
	<xsl:template match="small"> 
		<fo:inline xsl:use-attribute-sets="small">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>
	
	<!-- small-->
	<xsl:template match="q"> 
		<fo:inline>&#8220;<xsl:value-of select="."/>&#8221;</fo:inline>
	</xsl:template>
	
	<!-- ============================================
		Styled Inline Elements without surrounding block at the root ouc:div node. Uses xsl:next-match which needs xsl 3.0
		=============================================== -->
	
	<xsl:variable name="html-elements" select="('em', 'i', 'var', 'cite', 'b', 'strong', 'mark', 'u', 'ins', 'abbr', 's', 'del', 'sub', 'sup', 'code', 'samp', 'small', 'q', 'a')" />
	
	<xsl:template match="/document/ouc:div/element()[name() = $html-elements]|content/element()[name() = $html-elements]" priority="1">
		<fo:block xsl:use-attribute-sets="p">
			<xsl:next-match />
		</fo:block>
	</xsl:template>
	
	<!-- ============================================
		Block Elements
	=============================================== -->

	<!-- ============================================
		Image element
	=============================================== -->

	<xsl:template match="img">
		<fo:external-graphic content-width="scale-to-fit" content-height="100%" width="100%" scaling="uniform">
			<xsl:apply-templates select="@src"/>
		</fo:external-graphic>
	</xsl:template>
	
	<!-- Page Relative -->
	<xsl:template match="img/@src">
		<xsl:attribute name="src" select="ou:convert-pr-link(.,concat($domain,if(ancestor::*[@path]) then ou:remove-last-token(ancestor::*[@path][1]/@path,'/') else $ou:dirname))"/>
	</xsl:template>
	
	<!-- Absolute -->
	<xsl:template match="img/@src[starts-with(.,'http://') or starts-with(.,'//') or starts-with(.,'https://')]" priority="2">
		<xsl:attribute name="src" select="."/>
	</xsl:template>
	
	<!-- Root Relative -->
	<xsl:template match="img/@src[starts-with(.,'/')]" priority="3">
		<xsl:attribute name="src" select="concat($domain,.)"/>
	</xsl:template>

	<!-- ============================================
		Styled block elements.
	=============================================== -->
	
	<xsl:template match="pre">
		<fo:block xsl:use-attribute-sets="pre">
			<xsl:value-of select="."/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="address">
		<fo:block xsl:use-attribute-sets="address">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	
	<xsl:template match="blockquote"> 
		<fo:block xsl:use-attribute-sets="blockquote">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	
	<!-- ============================================
		Tables.
	=============================================== -->
	
	<xsl:template match="table">
		<fo:table xsl:use-attribute-sets="table">
			<xsl:if test="thead">
				<fo:table-header xsl:use-attribute-sets="thead">
					<xsl:apply-templates select="thead/tr" />
				</fo:table-header>
			</xsl:if>
			<!-- Build the table according to how valid the structure is -->
			<xsl:choose>
				<xsl:when test="tbody or tfoot"> <!-- valid -->
					<fo:table-body>
						<xsl:apply-templates select="tbody/tr" />
						<xsl:apply-templates select="tfoot/tr" />
					</fo:table-body>
				</xsl:when>
				<xsl:when test="tr"> <!-- not valid -->
					<fo:table-body>
						<xsl:apply-templates select="tr" />
					</fo:table-body>
				</xsl:when>
				<xsl:when test="td or th"> <!-- not valid -->
					<fo:table-row>
						<xsl:apply-templates />
					</fo:table-row>
				</xsl:when>
			</xsl:choose>	
		</fo:table>
	</xsl:template>
	
	<xsl:template match="tfoot/tr">
		<fo:table-row xsl:use-attribute-sets="thead tr">
			<xsl:apply-templates />
		</fo:table-row>
	</xsl:template>
	
	<xsl:template match="tr">
		<fo:table-row xsl:use-attribute-sets="tr">
			<xsl:apply-templates />
		</fo:table-row>
	</xsl:template>

	<xsl:template match="td">
		<fo:table-cell xsl:use-attribute-sets="td">
			<xsl:call-template name="td-th"/>
		</fo:table-cell>
	</xsl:template>
	
	<xsl:template match="th">
		<fo:table-cell xsl:use-attribute-sets="th">
			<xsl:call-template name="td-th"/>
		</fo:table-cell>
	</xsl:template>

	<xsl:template name="td-th">
		<xsl:if test="@colspan"><xsl:attribute name="number-columns-spanned" select="@colspan" /></xsl:if>		
		<fo:block><xsl:apply-templates /></fo:block>
	</xsl:template>

	<!-- ============================================
		Lists (unordered, ordered, definition).
	=============================================== -->

	<!-- ordered lists -->
	<xsl:template match="ol">
		<fo:list-block xsl:use-attribute-sets="ol-ul">
			<xsl:apply-templates />
		</fo:list-block>
	</xsl:template>
	
	<!-- unordered lists -->
	<xsl:template match="ul">
		<fo:list-block xsl:use-attribute-sets="ol-ul">
			<xsl:apply-templates />
		</fo:list-block>
	</xsl:template>
	
	<!-- ignores the improper listing and creates a list item at the same level, but some users may want it created in the next level -->
	<xsl:template match="ol[parent::ul|parent::ol]|ul[parent::ul|parent::ol]">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- list items inside of the unordered list -->
	<xsl:template match="li[parent::ul]">
		<fo:list-item>
			<fo:list-item-label>
				<fo:block>&#8226;</fo:block>
			</fo:list-item-label>
			<fo:list-item-body xsl:use-attribute-sets="ul-li">			
				<fo:block><xsl:apply-templates /></fo:block>
			</fo:list-item-body>
		</fo:list-item>	
	</xsl:template>
	
	
	<!-- list items inside of the ordered list -->
	<xsl:template match="li[parent::ol]">
		<fo:list-item>
			<fo:list-item-label>
				<fo:block>
					<xsl:number format="{if(count(ancestor::li) mod 2 = 0) then '1' else 'a'}" />.
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body xsl:use-attribute-sets="ol-li">			
				<fo:block>
					<xsl:apply-templates />
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>

	<!-- Definition lists -->
	<xsl:template match="dl"> 
		<fo:block space-after="8pt" start-indent="3mm"><xsl:apply-templates /></fo:block>
	</xsl:template>

	<xsl:template match="dt">
		<fo:block font-weight="bold" space-before="8pt" keep-with-next="always">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	
	<xsl:template match="dd">
		<fo:block start-indent="5mm" keep-with-previous="always">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<!-- ============================================
		Page formatting elements.
	=============================================== -->
	
	<xsl:template match="br">
		<fo:block />
	</xsl:template>
	
	<xsl:template match="hr">
		<fo:block xsl:use-attribute-sets="hr" />
	</xsl:template>

	<!-- ============================================
		Snippets & Custom Styles
	=============================================== -->
	
	<!-- insert items here -->
	<xsl:template match="element()[contains(@class, 'ou-exclude-from-pdf')]" />
	
	
</xsl:stylesheet>