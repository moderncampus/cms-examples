<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [ 
<!ENTITY nbsp "&#160;"> 
<!ENTITY mdash "&#8212;">
]>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="xs ou ouc">
    
    <!--Social Media Meta tags variables
        The values below must be added as directory variable-->
    <xsl:param name="ou:og-image" />
    <xsl:param name="ou:og-site-name" />
    <xsl:param name="ou:twitter-image" />
    <xsl:param name="ou:twitter-creator" />
    <xsl:param name="ou:twitter-site" />
    <xsl:param name="ou:fb-admins" />
    <xsl:param name="ou:fb-app_id" />
    
    <xsl:template name="social-meta">
        <!-- opengraph start -->
        <xsl:if test="$ou:og-image !=''"><meta property="og:image" content="{$ou:og-image}"/></xsl:if>
        <meta property="og:title" content="{ouc:properties/title/text()}"/>
        <meta property="og:url" content="{concat(string-join(remove(tokenize(substring($ou:httproot, 1), '/'), count(tokenize(substring($ou:httproot, 1), '/'))), '/'),$ou:path)}"/>
        <meta property="og:description" content="{ouc:properties/meta[@name='description']/@content}" />
        <xsl:if test="$ou:og-site-name !=''"><meta property="og:site_name" content="{$ou:og-site-name}"/></xsl:if>
        <meta property="og:type" content="website"/>
        <xsl:if test="$ou:fb-admins !=''"><meta property="fb:admins" content="{$ou:fb-admins}" /></xsl:if>
        <xsl:if test="$ou:fb-app_id !=''"><meta property="fb:app_id" content="{$ou:fb-app_id}" /></xsl:if> 
        <!-- opengraph end -->
        
        <!-- twitter start -->
        <meta name="twitter:card" content="summary"/>
        <xsl:if test="$ou:twitter-site !=''"><meta name="twitter:site" content="{$ou:twitter-site}"/></xsl:if>
        <xsl:if test="$ou:twitter-creator !=''"><meta name="twitter:creator" value="{$ou:twitter-creator}"/></xsl:if>
        <!-- 
            Twitter will pull the following information from the Open Graph tags above. 
            When used, these tags will take precendence over the Open Graph tags when the Twitter card processor looks for tags on a page. 
        -->
        <!--<meta name="twitter:url" content="{concat(string-join(remove(tokenize(substring($ou:httproot, 1), '/'), count(tokenize(substring($ou:httproot, 1), '/'))), '/'),$ou:path)}"/>
        <meta name="twitter:title" content="{ouc:properties/title/text()}"/>
        <meta name="twitter:description" content="{ouc:properties/meta[@name='description']/@content}"/>
        <xsl:if test="$ou:og-image !=''"><meta property="twitter:image" content="{if ($ou:twitter-image != '') then $ou:twitter-image else $ou:og-image}"/></xsl:if>-->
        <!-- twitter end -->
    </xsl:template>
    
</xsl:stylesheet>