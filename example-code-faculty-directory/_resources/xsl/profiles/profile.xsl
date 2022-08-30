<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY laquo  "&#171;">
<!ENTITY raquo  "&#187;">
<!ENTITY copy   "&#169;">
<!ENTITY times	"&#215;">
]>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xs ou ouc">

	<xsl:import href="../common.xsl"/>
	<xsl:import href="helper.xsl" />

	<xsl:template name="extra-headcode">
		<!--Checks to see if there is a not a profile node then it knows it is on the listing page, so it needs the jQuery dataTables code-->
		<xsl:if test="not(profile)">
			<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
			<link href="/_resources/css/jquery.dataTables.css" rel="stylesheet" />
			<script src="/_resources/js/jquery.dataTables.js"></script>
			<script>
				<!--ADD IN FOR FILTER DROP DOWN FOR DATATABLES-->
				<!--$(document).ready(function() {
			    /* Initialise datatables */
			    var oTable = $('#profiles').dataTable();

			    /* Add event listener to the dropdown input */
			    $('select#location').change( function() { oTable.fnFilter( $(this).val() ); } );
			    } );--> 

			    $(document).ready(function(){
			    $('#profiles').dataTable();
			    });
			</script>
		</xsl:if>
	</xsl:template>

	<xsl:template name="page-content">
		<div id="breadcrumbs-wrap">
			<div id="breadcrumbs">
				<xsl:call-template name="breadcrumb">
					<xsl:with-param name="path" select="$ou:dirname"/>								
				</xsl:call-template>
			</div>
		</div>
		<div id="content-background">
			<div class="footer-wrap">
				<!--xsl:call-template name="sidenav"/-->
				<div id="content-area">
					<h1><xsl:value-of select="ou:pcf-param('heading')" /></h1>
					<div id="landing-page-content">
						<xsl:call-template name="faculty-profile" />
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- ************* begin employee profile *************** -->
	<xsl:template name="faculty-profile">
		<xsl:choose>
			<xsl:when test="profile">  <!-- Check to see if Profile Page (profile node exists) -->
				<xsl:copy-of select="ou:multiedit-button()" />
				<xsl:apply-templates select="ou:get-profile(/document)" mode="single"/>
				<xsl:apply-templates select="ouc:div[@label='maincontent']" />
			</xsl:when>
			<xsl:otherwise> <!-- LISTING VIEW -->
				<xsl:if test="$ou:action = 'edt' or $ou:action = 'prv'">
					<div class="alert-box warning radius">
						<span style="margin-right:1em" class="icon icon-refresh pull-left"></span><span> Directory listing will only be updated upon publish. It is recommended that you set this page to 'Schedule Publish' on a recurring basis.</span>
						<a href="javascript:close();" class="close">&times;</a>
					</div>
				</xsl:if>

				<xsl:if test="$ou:action = 'edt' or $ou:action = 'prv'">
					<div class="alert-box secondary radius">
						<span style="margin-right:1em" class="icon icon-exclamation-sign pull-left"></span> Only published profile pages will be displayed.
						<a href="javascript:close();" class="close">&times;</a>
					</div>
				</xsl:if>
				<xsl:variable name="varname" select="ou:get-profiles($dirname, $ou:filename)"/>
				<div>
					<!--ADD IN FOR FILTER DROP DOWN ON DATATABLES-->
					<!--<table>
						<tbody>
							<tr>
								<td>
									<p>
									Filter by location:
									</p>
									<select id="location">
										<option value="">- Select -</option>
										<option value="Charity School of Nursing">Charity School of Nursing</option>
										<option value="City Park">City Park</option>
										<option value="Gretna Facility">Gretna Facility</option>
										<option value="Jefferson Site (Technical Division)">Jefferson Site (Technical Division)</option>
										<option value="Maritime, Fire and Industrial Facility">Maritime, Fire and Industrial Facility</option>
										<option value="Northshore - Covington">Northshore - Covington</option>
										<option value="Northshore - Slidell">Northshore - Slidell</option>
										<option value="West Bank">West Bank</option>
										<option value="West Jefferson Site (Technical Division)">West Jefferson Site (Technical Division)</option>
									</select>
								</td>
							</tr>
						</tbody>
					</table>--> 

					<!--Table for for the listing page using jQuery dataTables-->	
					<table id="profiles" width="100%" cellpadding="10">
						<thead>
							<tr>
								<th>
									<span>Name</span>
								</th>
								<th>
									<span>Department</span>
								</th>
								<th>
									<span>Building</span>
								</th>
								<th>
									<span>Room</span>
								</th>
								<th>
									<span>Phone</span>
								</th>
								<th>
									<span>Location</span>
								</th>
							</tr>
						</thead>
						<tbody>
							<xsl:apply-templates select="$varname/profile" mode="listing" />
						</tbody>
					</table>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		<!-- ************ end employee profile *************** -->
	</xsl:template>
	
	<!-- ************ Output for the individual profile page *************** -->
	<xsl:template match="profile" mode="single">
		<div>
			<h2>
				<xsl:if test="not(./image/img/@src='')">
					<img src="{./image/img/@src}" alt="{./image/img/@alt}" align="left" border="1" height="229" hspace="20" vspace="0" width="179" />
				</xsl:if>
				<xsl:if test="not(firstname='')">
					<xsl:value-of select="firstname" />&nbsp;
				</xsl:if>
				<xsl:if test="not(lastname='')">
					<xsl:value-of select="lastname"/>
				</xsl:if>
			</h2>
			<p><strong>
				<xsl:if test="not(title='')">
					<xsl:value-of select="title"/>, 
				</xsl:if>
				<xsl:if test="not(department='')">
					<xsl:value-of select="department"/>
				</xsl:if>
			</strong></p>
			<xsl:if test="not(location='')">
				<p>Location: <xsl:value-of select="location"/></p>
			</xsl:if>
			<xsl:if test="not(phone='')">
				<p>Phone: <a href="tel:{phone/text()}"><xsl:value-of select="phone"/></a></p>
			</xsl:if>
			<xsl:if test="not(fax='')">
				<p>Fax: <xsl:value-of select="fax"/></p>
			</xsl:if>
			<xsl:if test="not(email='')">
				<p>E-mail: <a href="mailto:{email/text()}"><xsl:value-of select="email"/></a></p>
			</xsl:if>
			<xsl:if test="not(office-hours='')">
				<h3><strong>Office Hours</strong>:</h3>
				<p><xsl:value-of select="office-hours" /></p>	
			</xsl:if>
		</div>
	</xsl:template>
	<!-- ************ END Output for the individual profile page *************** -->

	<!-- ************ Output for the aggregrate listing page *************** -->
	<xsl:template match="profile" mode="listing">
		<tr>
			<td><a href="{@href}"><xsl:value-of select="lastname"/>,&nbsp;<xsl:value-of select="firstname"/></a></td>
			<td><xsl:value-of select="department"/></td>
			<td><xsl:value-of select="building"/></td>
			<td><xsl:value-of select="room"/></td>
			<td><a href="tel:{phone/text()}"><xsl:value-of select="phone"/></a></td>
			<td><xsl:value-of select="location"/></td>
		</tr>
	</xsl:template>	
	<!-- ************ END Output for the aggregrate listing page *************** -->

</xsl:stylesheet>
