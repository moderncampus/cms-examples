<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
Kitchen Sink v2.4 - 2/14/2014

PARAMETER EXPOSE
The purpose of the following two templates is to make page properties (PCF params), directory 
variables, and system parameters (such as ou:site) available to JS and PHP scripts running in a page.

Each template reads two parameters, named "global-props" and "page-props", which are defined at the 
bottom of this file. These parameters contain <property> nodes that essentially mirror the parameters 
we want to expose to scripts.

For each <property> child node of <xsl:param name="global-props">, the first template ("params-to-js") 
will add an equivalent property to an OUC.globalProps JavaScript object (which is created if it 
doesn't already exist). Similarly, for each <property> child node of <xsl:param name="page-props">, 
this template will add an equivalent property to an OUC.pageProps object. These properties are now 
available to any JS scripts running in the page.

The OUC.props object is created by combining all the properties of OUC.globalProps and OUC.pageProps. 
If a property with the same name exists in both objects, the value of the one from pageProps 
overwrites the value of the one from globalProps.

The second template ("params-to-php") does the equivalent for PHP, creating arrays 
$OUC['globalProps'], $OUC['pageProps'], and $OUC['props']
        
Contributors: Your Name Here
Last Updated: Enter Date Here
-->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://omniupdate.com/XSL/Functions"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="xsl xs fn ou ouc">

    <xsl:template name="params-to-js">
        <script type="text/javascript">
            var OUC = OUC || {};
            OUC.globalProps = OUC.globalProps || {};
            OUC.pageProps = OUC.pageProps || {};
            OUC.props = OUC.props || {};
            
            <xsl:for-each select="$global-props/property[not(@private)]">
                OUC.globalProps['<xsl:value-of select="./@name"/>'] = "<xsl:value-of select="."/>";</xsl:for-each>
            <xsl:for-each select="$page-props/property">
                OUC.pageProps['<xsl:value-of select="./@name"/>'] = "<xsl:value-of select="."/>";</xsl:for-each>
            
            var key;
            for (key in OUC.globalProps) {
            OUC.props[key] = OUC.globalProps[key];
            }
            for (key in OUC.pageProps) {
            OUC.props[key] = OUC.pageProps[key];
            }
        </script>
    </xsl:template>
    
    <!-- 
        NOTE: You should call the following "params_to_php" template only on publish. If it is called on 
        preview, everything after the first ">" character in the PHP script will appear on the page as text.
        If you can figure out a good, clean way to avoid this problem, go for it and let everyone know how.
    -->
    
    <xsl:template name="params-to-php">
        <xsl:text disable-output-escaping="yes">
            &lt;?php
            if (!$OUC)                $OUC = array();
            if (!$OUC['globalProps']) $OUC['globalProps'] = array();
            if (!$OUC['pageProps'])   $OUC['pageProps'] = array();
            if (!$OUC['props'])       $OUC['props'] = array();
        </xsl:text>
        <xsl:for-each select="$global-props/property[not(@private)]">
            $OUC['globalProps']['<xsl:value-of select="./@name"/>'] = "<xsl:value-of select="."/>";</xsl:for-each>
        <xsl:for-each select="$page-props/property">
            $OUC['pageProps']['<xsl:value-of select="./@name"/>'] = "<xsl:value-of select="."/>";</xsl:for-each>
        <xsl:text disable-output-escaping="yes">
            
            foreach ($OUC['globalProps'] as $key => $val) $OUC['props'][$key] = $val;
            foreach ($OUC['pageProps']   as $key => $val) $OUC['props'][$key] = $val;
        ?></xsl:text>
    </xsl:template>
    
    <!--
        The <xsl:param> element below contains, for every system parameter, an equivalent <property> node 
        whose name is the same but without the "ou:" prefix.
        
        Other variables that you want to expose to page scripts must also have <property> entries
        within this <xsl:param> element.
    -->
    <xsl:param name="global-props">
        
        
        <!-- system defined variables (see ouvariables.xsl) -->
		
<!--        <property name="action" private="true"><xsl:value-of select="$ou:action"/></property>-->
<!--        <property name="created"><xsl:value-of select="$ou:created"/></property>-->
<!--        <property name="dirname"><xsl:value-of select="$ou:dirname"/></property>-->
<!--        <property name="feed"><xsl:value-of select="$ou:feed"/></property>-->
<!--        <property name="filename"><xsl:value-of select="$ou:filename"/></property>-->
<!-- 		<property name="httproot"><xsl:value-of select="$ou:httproot"/></property>-->
<!--        <property name="modified"><xsl:value-of select="$ou:modified"/></property>-->
        	<property name="path"><xsl:value-of select="$ou:path"/></property>
<!--        <property name="root" private="true"><xsl:value-of select="$ou:root"/></property>-->
<!--        <property name="site"><xsl:value-of select="$ou:site"/></property>-->
<!--        <property name="firstname" private="true"><xsl:value-of select="$ou:firstname"/></property>-->
<!--        <property name="lastname" private="true"><xsl:value-of select="$ou:lastname"/></property>-->
<!--        <property name="username" private="true"><xsl:value-of select="$ou:username"/></property>-->
<!--        <property name="email" private="true"><xsl:value-of select="$ou:email"/></property>-->
        
        <!-- other variables -->
        
			<property name="domain"><xsl:value-of select="$domain"/></property>
<!--        <property name="serverType" private="true"><xsl:value-of select="$server-type"/></property>-->
        	<property name="index-file"><xsl:value-of select="$index-file"/></property>
       	 	<property name="extension"><xsl:value-of select="$extension"/></property>
        	<!--<property name="production_root"><xsl:value-of select="$ou:production_root"/></property>-->
<!--        <property name="navigationStart"><xsl:value-of select="$ou:navigation-start"/></property>-->
<!--        <property name="breadcrumbStart"><xsl:value-of select="$ou:breadcrumb-start"/></property>-->
<!--        <property name="pageType" private="true"><xsl:value-of select="$page-type"/></property>-->
<!--        <property name="pageTitle"><xsl:value-of select="$page-title"/></property>-->
        
    </xsl:param>
    
    <!-- 
        The <xsl:param> element below is for page properties (PCF parameters). Since the matching
        <property> nodes are generated programmatically, there is no need to manually create them. 
        The code depends on the availability of the "ou:pcfparam" function, which must therefore 
        be available to this stylesheet. (The function is usually in pcf-params.xsl.)
    -->
    <xsl:param name="page-props">
		<xsl:for-each select="/document/parameter|/document/ouc:properties/parameter">
            <property name="{./@name}"><xsl:value-of select="ou:pcf-param(./@name)"/></property>
        </xsl:for-each>
    </xsl:param>
    
</xsl:stylesheet>
