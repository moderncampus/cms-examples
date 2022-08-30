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
Implementations Skeleton - 01/10/2017
=========================
FUNCTIONS 
Repository of active functions
=========================
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">

	<!--
	ou:include-file()
	The following function takes in two parameters
	(directory name and file name) and outputs the 
	proper code to include the file on the page.
	-->
	<xsl:function name="ou:include-file">
		<!-- directory name + file name -->
		<xsl:param name="fullpath" />
		<!-- on publish, it will output the proper SSI code, but on staging we require the omni div tag -->
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:copy-of select="ou:ssi($fullpath)" />
			</xsl:when>
			<xsl:otherwise>
				<!-- <ouc:div label="{$fullpath}" path="{$fullpath}" /> -->
				<xsl:comment> ouc:div label="<xsl:value-of select="$fullpath"/>" path="<xsl:value-of select="$fullpath"/>"</xsl:comment> <xsl:comment> /ouc:div </xsl:comment> 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ou:ssi">
		<xsl:param name="fullpath"/>
		<!--<xsl:comment>#include virtual="<xsl:value-of select="$fullpath" />" </xsl:comment>-->
		<xsl:processing-instruction name="php"> include($_SERVER['DOCUMENT_ROOT'] . "<xsl:value-of select="$fullpath" />"); ?</xsl:processing-instruction>
	</xsl:function>

	<!-- function that is the full include path to a script -->
	<xsl:function name="ou:ssi-full">
		<xsl:param name="fullpath"/>
		<!-- example of c#, read file in as a string and display the content from two levels, you might have to change if you go up a different amount of levels -->
		<!-- <xsl:text disable-output-escaping="yes">&lt;% </xsl:text> 
			wwwftproot = @"<xsl:value-of select="$ou:www-ftproot"/>";
			fullpath = @"<xsl:value-of select="$fullpath"/>";
			root = Server.MapPath("~");
			parent = System.IO.Path.GetDirectoryName(root);
			grandParent = System.IO.Path.GetDirectoryName(System.IO.Path.GetDirectoryName(parent));
			global = string.Concat(grandParent,wwwftproot, fullpath);
			contents = System.IO.File.ReadAllText(global);
			Response.Write(contents);
		<xsl:text disable-output-escaping="yes">%&gt;</xsl:text> -->
		<xsl:processing-instruction name="php"> include("<xsl:value-of select="concat($ou:www-ftproot, $fullpath)" />"); ?</xsl:processing-instruction>
	</xsl:function>
		

	<!-- 
	Grab file from production on staging and output a server side include on publish 
	-->
	<xsl:template name="unparsed-include-file">
		<xsl:param name="path"/>
		<xsl:param name="global" select="false()" />
		<xsl:variable name="prod-path" select="concat($domain, $path)" />
		<xsl:variable name="main-prod-path" select="concat($ou:www-domain, $path)" />
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
						<xsl:if test="not($ou:action = 'pub')">
							<p><xsl:value-of select="concat('File not available. Please make sure the path ( ' ,$main-prod-path ,' ) is correct and the file is published.')" /></p>
						</xsl:if>
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
						<xsl:if test="not($ou:action = 'pub')">
							<p><xsl:value-of select="concat('File not available. Please make sure the path ( ' ,$prod-path ,' ) is correct and the file is published.')" /></p>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
	PCF PARAMS
	An extremely useful function for getting page properties without needing to type the full xpath.
	How to use:
	The pcf has a parameter, name="page-type". To get the value and store it in an XSL param : 	
	<xsl:param name="page-type" select="ou:pcf-param('page-type')"/> 
	<xsl:param name="props-tile" select="ou:pcf-param('section-title',$props-doc)"/> 	
	-->
	<xsl:param name="pcf-params" select="/document/descendant::parameter"/> <!-- save all page properties in a variable -->
	
	<!-- Get PCF params from an external document -->
	<xsl:function name="ou:pcf-param">
		<xsl:param name="name" as="xs:string"/>
		<xsl:param name="doc" as="document-node()"/>		
		<xsl:variable name="external-params" select="$doc/descendant::parameter"/>
		<xsl:call-template name="pcf-param">
			<xsl:with-param name="name" select="$name"/>
			<xsl:with-param name="pcf-params" select="$external-params"/>
		</xsl:call-template>
	</xsl:function>
	
	<!-- Get a param from default parmaeter list -->
	<xsl:function name="ou:pcf-param">
		<xsl:param name="name"/>
		<xsl:call-template name="pcf-param">
			<xsl:with-param name="name" select="$name"/>
		</xsl:call-template>
	</xsl:function>
	
	<!-- Get a param from a provided parmaeter list -->
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
	ou:multiedit-field()		
	Grab field from multiedit by providing ouc:div label.
	Specify a second string argument - this is useful for 
	loops where multi-edit fields are the same except for a 
	position suffix in the ouc:div label.
	
	ex:
	<xsl:param name="var-1" select="ou:multiedit-field('hero-image')"/> => <ouc:div label="hero-image"/>  
	<xsl:param name="var-2" select="ou:multiedit-field('button',$position)"/> => <ouc:div label="button-1"/>  
	-->

	<xsl:param name="multiedit-fields" select="/document/descendant::ouc:div[ouc:multiedit]"/>
	
	<xsl:function name="ou:multiedit-field">
		<xsl:param name="name"/>
		<xsl:copy-of select="$multiedit-fields[@label=$name]"/>
	</xsl:function>

	<xsl:function name="ou:multiedit-field"> 
		<xsl:param name="name"/>
		<xsl:param name="position"/>		
		<xsl:copy-of select="$multiedit-fields[@label=concat($name,'-',$position)]"/>
	</xsl:function>

	<!-- 
	ASSIGN VARIABLE
	Concisely assign fallback variables to prevent unexpected errors in development and post implementation.
	
	How to use:
	<xsl:param name="galleryType" select="ou:assign-variable('galleryType','PrettyPhoto')"/>	
	<xsl:variable name="navfile" select="ou:assign-variable('page-nav',$ou:navigation,$local-nav)"/>
	
	Third parameter may be a string or variable. The first parameter must always be a string, as required by the pcf-param function.
	
	Second version requires overwrite-directory variable, which is typically defined in vars xsl.
	
	<xsl:variable name="overwrite-directory" select="ou:assign-variable('overwrite-directory','no')"/> 
	
	
	Note: requires the function ou:pcf-param
	-->
	<xsl:function name="ou:assign-variable"> <!-- test if page property has value, give default value if none -->
		<xsl:param name="var"/>
		<xsl:param name="fallback"/>
		<xsl:variable name="pcf-var" select="ou:pcf-param($var)"/>
		<xsl:choose>	
			<xsl:when test="string-length($pcf-var) > 0"><xsl:value-of select="$pcf-var"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$fallback"/></xsl:otherwise>
		</xsl:choose>	
	</xsl:function>		
	
	<xsl:function name="ou:assign-variable"> <!-- pcf - dir var - fallback precedence, also tests if there is a value for each -->
		<xsl:param name="var"/>
		<xsl:param name="dir-var"/>
		<xsl:param name="fallback"/>
		<xsl:variable name="overwrite-directory" select="ou:pcf-param('overwrite-directory')"/>
		<xsl:variable name="pcf-var" select="ou:pcf-param($var)"/>
		<xsl:choose>	
			<xsl:when test="string-length($pcf-var) > 0 and $overwrite-directory='yes'"><xsl:value-of select="$pcf-var"/></xsl:when>
			<xsl:when test="string-length($dir-var) > 0 and $dir-var!='[auto]'" ><xsl:value-of select="$dir-var"/></xsl:when> 
			<xsl:otherwise><xsl:value-of select="$fallback"/></xsl:otherwise>
		</xsl:choose>	
	</xsl:function>
		
	<!-- 
	TEST VARIABLE
	A simpler version of Assign Variable, if you are not dealing with page properties.
	-->		
	<xsl:function name="ou:test-variable"> <!-- test if variable has value, give default value if none -->
		<xsl:param name="var"/>
		<xsl:param name="fallback"/>
		<xsl:choose>	
			<xsl:when test="string-length($var) > 0"><xsl:value-of select="$var"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$fallback"/></xsl:otherwise>
		</xsl:choose>	
	</xsl:function>	
		
	<!--
	FIND PREVIOUS DIRECTORY
	Used by breadcrumbs xsl.
	-->
	<xsl:function name="ou:find-prev-dir"> <!-- outputs parent directory path with trailing '/': /path/to/parent/ -->
		<xsl:param name="path" />
		<xsl:variable name="token-path" select="tokenize(substring($path, 2), '/')[if(substring($path,string-length($path)) = '/') then position() != last() else position()]" />
		<xsl:variable name="new-path" select="concat('/', string-join(remove($token-path, count($token-path)), '/') ,'/')"/>
		<xsl:value-of select="if($new-path = '//') then '/' else $new-path" />
	</xsl:function>

	<!--
	HAS CLASS
	boolean that returns whether an element contains a class, much like JQuery's hasClass function
	-->
	<xsl:function name="ou:has-class">
		<xsl:param name="element"/>
		<xsl:param name="class-name"/>
		<xsl:value-of select="boolean($element/@class) and contains(concat(' ', $element/@class, ' '), concat(' ', $class-name, ' '))"/>
	</xsl:function>	
	
	<!--
	GET CURRENT FOLDER
	-->
	<xsl:function name="ou:current-folder">
		<xsl:param name="string"/>
		<xsl:variable name="chars" select="tokenize(substring-after($string,'/'), '/')"/>
		<xsl:for-each select="$chars">
			<xsl:if test="position()=last()">
				<xsl:variable name="result"><xsl:value-of select="."/></xsl:variable>
				<!-- <xsl:value-of select="ou:capital(replace($result,'-',' '))" /> -->
				<!-- copy the when statement for more cleaning options -->
				<xsl:choose>
					<xsl:when test="contains($result,'_')">
						<xsl:value-of select="ou:clean($result,'_')"/>
					</xsl:when>
					<xsl:when test="contains($result,'-')">
						<xsl:value-of select="ou:clean($result,'-')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="ou:capital($result)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	
	<!--
	CAPITALIZE THE FIRST LETTER OF EVERY WORD
	-->
	<xsl:function name="ou:capital">
		<xsl:param name="string"/>
		<xsl:variable name="chars" select="tokenize($string, ' ')"/>
		<xsl:for-each select="$chars">
			<xsl:variable name="key"><xsl:value-of select="."/></xsl:variable>
			<xsl:variable name="first-letter-1"><xsl:value-of select="upper-case(substring($key,1,1))" /></xsl:variable>
			<xsl:variable name="rest-1"><xsl:value-of select="lower-case(substring($key,2))" /></xsl:variable>
			<xsl:variable name="result"><xsl:value-of select="concat($first-letter-1,$rest-1,' ')" /> </xsl:variable>
			<xsl:value-of select="normalize-space($result)" />
		</xsl:for-each>
	</xsl:function>
	
	<!--
	Clean content by replacing content with space
	-->
	<xsl:function name="ou:clean">
		<xsl:param name="string"/>
		<xsl:param name="deliminator"/>
		<xsl:variable name="chars" select="tokenize($string,$deliminator)"/>
		<xsl:for-each select="$chars">
			<xsl:variable name="key"><xsl:value-of select="."/></xsl:variable>
			<xsl:variable name="first-letter-1"><xsl:value-of select="upper-case(substring($key,1,1))" /></xsl:variable>
			<xsl:variable name="rest-1"><xsl:value-of select="lower-case(substring($key,2))" /></xsl:variable>
			<xsl:variable name="result"><xsl:value-of select="concat($first-letter-1,$rest-1,' ')" /> </xsl:variable>
			<xsl:value-of select="$result" />
		</xsl:for-each>
	</xsl:function>

	<!--
	Truncate variable amounts of text with a special symbol
	-->
	<xsl:function name="ou:truncate">
		<xsl:param name="text" as="xs:string"/> <!-- the text to be truncated -->
		<xsl:param name="limit" as="xs:integer"/> <!-- the max number of chars -->
		<xsl:param name="symbol" as="xs:string"/> <!-- the symbol to show after truncating (i.e. '...') -->

		<xsl:choose>
			<xsl:when test="string-length(normalize-space($text)) gt $limit">
				<xsl:value-of select="concat(normalize-space(substring($text, 1, $limit)), $symbol)" />
			</xsl:when>	
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($text)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!--
		OU GET TEXTUAL CONTENT
		Use when checking for any content (prep for an "if empty" check)
		Gets string representation of any node and its subnodes, replaces &nbsp; with space, and trims all whitespace
	-->
	<xsl:function name="ou:textual-content">
		<xsl:param name="element" />
		<xsl:variable name="string"><xsl:value-of select="$element" /></xsl:variable>
		<xsl:value-of select="normalize-space(replace($string, '&nbsp;', ' '))" />
	</xsl:function>
	
	
	<!-- 
		Tag API Calls 
	 -->	
	<xsl:function name="ou:get-tags">
		<xsl:param name="path" />
		<xsl:variable name="tagapi" select="concat('ou:/Tag/GetTags?site=', $ou:site, '&amp;path=', $path)" />
		<xsl:if test="doc($tagapi)/tags != ''">
			<xsl:apply-templates select="doc($tagapi)/tags/tag">
				<xsl:sort select="./name" />
			</xsl:apply-templates>
		</xsl:if>		
	</xsl:function>
	
	<xsl:function name="ou:get-collection-children-tags">
		<xsl:param name="collection" />
		<xsl:variable name="tagapi" select="concat('ou:/Tag/GetChildren?tag=', $collection)" />
		<xsl:if test="doc($tagapi)/tags != ''">
			<xsl:apply-templates select="doc($tagapi)/tags/tag">
				<xsl:sort select="./name" />
			</xsl:apply-templates>
		</xsl:if>		
	</xsl:function>	
</xsl:stylesheet>
