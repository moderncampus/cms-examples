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
VARIABLE DEBUG
A useful XSL for variable reference, testing, & debugging. It is not intended for all end users but rather source editors and xsl developers.
-->
<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<xsl:import href="common.xsl"/>

	<xsl:template name="debug" match="/">
		<html lang="en">
			<head>
				<link href="//netdna.bootstrapcdn.com/bootswatch/3.1.0/cerulean/bootstrap.min.css" rel="stylesheet"/>
				<link href="/_resources/css/oustaging.css" rel="stylesheet" />
				<style>
					body{
					font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
					}
					.ox-regioneditbutton {
					display: none;
					}
				</style>
			</head>
			<body id="info">

				<div class="container">

					<h1>Variable Debug Tab</h1>
					<p>The following is a list of XSL variables for this page or section for debugging and development purposes. 
						Feel free to add your own (globally defined) variables here. This page depends on the import of any XSL in which variables are
						defined, such as ouvariables, vars, and common XSL stylesheets.</p>
					<p><small><em>This view will not be published.</em></small></p>

					<div class="row">
						<div class="col-md-6">
							<h3>Modern Campus CMS System Variables</h3>
							<p>These are parameters provided by the system, instantiated in vars.xsl</p>
							<hr/>
							<h4>File/Directory</h4><em>Page or directory specific</em>
							<dl>
								<xsl:copy-of select="ou:display-variable('ou:filename',$ou:filename)"/>
								<xsl:copy-of select="ou:display-variable('ou:path',$ou:path)"/>
								<xsl:copy-of select="ou:display-variable('ou:created',$ou:created)"/>
								<xsl:copy-of select="ou:display-variable('ou:modified',$ou:modified)"/>
								<xsl:copy-of select="ou:display-variable('ou:feed',$ou:feed)"/>	
								<xsl:copy-of select="ou:display-variable('ou:dirname',$ou:dirname)"/>
							</dl>
							<!-- protected information -->
							<hr/>
							<h5>Staging</h5><em>Site specific, staging server information</em>
							<dl>
								<xsl:copy-of select="ou:display-variable('ou:action',$ou:action)"/>	
								<xsl:copy-of select="ou:display-variable('ou:root',$ou:root)"/>	
								<xsl:copy-of select="ou:display-variable('ou:site',$ou:site)"/>	
							</dl>
							<hr/>
							<h5>Production</h5><em>Site specific, production server informaiton</em>
							<dl>

								<xsl:copy-of select="ou:display-variable('ou:ftphome',$ou:ftphome)"/>
								<xsl:copy-of select="ou:display-variable('ou:httproot',$ou:httproot)"/>
								<xsl:copy-of select="ou:display-variable('ou:ftproot',$ou:ftproot)"/>
							</dl>
							<hr/>
							<h4>User</h4><em>User specific information, if available</em>
							<dl>
								<xsl:copy-of select="ou:display-variable('ou:username',$ou:username)"/>
								<xsl:copy-of select="ou:display-variable('ou:firstname',$ou:firstname)"/>
								<xsl:copy-of select="ou:display-variable('ou:lastname',$ou:lastname)"/>
								<xsl:copy-of select="ou:display-variable('ou:email',$ou:email)"/>
							</dl>
						</div>

						<div class="col-md-6">
							<h3>XSL Variables</h3>
							<p>Globally defined XSL variables or parameters, in vars.xsl</p>
							<hr/>
							<h4>Skeleton Variables</h4><em>Standard variable set</em>
							<dl>
								<xsl:copy-of select="ou:display-variable('Server Type',$server-type)"/>	
								<xsl:copy-of select="ou:display-variable('Index File',$index-file)"/>	
								<xsl:copy-of select="ou:display-variable('Extension',$extension)"/>	
								<xsl:copy-of select="ou:display-variable('Dirname',$dirname)"/>	
								<xsl:copy-of select="ou:display-variable('Domain',$domain)"/>

								<xsl:copy-of select="ou:display-variable('path',$path)"/>
								<xsl:copy-of select="ou:display-variable('Props File',$props-file)"/>
								<xsl:copy-of select="ou:display-variable('Props Path',$props-path)"/>
								<!--							<xsl:copy-of select="ou:display-variable('Production Root',$ou:production_root)"/>
<xsl:copy-of select="ou:display-variable('Navigation Start',$ou:navigation-start)"/>	-->
								<xsl:copy-of select="ou:display-variable('Breadcrumb Start',$ou:breadcrumb-start)"/>
							</dl>
							<hr/>
							<h4>Implementation Specific Variables</h4><em>These vary from project to project.</em>
							<xsl:copy-of select="ou:display-variable('Page Type',$page-type)"/>	
							<xsl:copy-of select="ou:display-variable('Page Title',$page-title)"/>

						</div>
					</div>


				</div>

				<em><small><p>This view is configured by debug.xsl</p></small></em>

			</body>
		</html>
	</xsl:template>

	<!-- display a variable for debug purposes -->
	<xsl:function name="ou:display-variable">
		<xsl:param name="name"/>
		<xsl:param name="var"/>
		<dt><xsl:value-of select="$name"/></dt>
		<dd><xsl:value-of select="$var"/></dd>
	</xsl:function>

</xsl:stylesheet>
