<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xs ou ouc">
	
	<xsl:function name="ou:file-exists">
		<xsl:param name="path" />
		<xsl:value-of select="unparsed-text-available(concat($domain,$path))" />
	</xsl:function>

	<xsl:function name="ou:name-to-file">
		<xsl:param name="name" />
		<xsl:value-of select="replace(lower-case(normalize-space($name)),'\s','-')" />
	</xsl:function>
	
	<!--RSS requires "RFC822" formated dateTime, http://www.w3.org/Protocols/rfc822/#z28 -->
	<xsl:function name="ou:to-pub-date" as="xs:string">
		<xsl:param name="dateTime"/>
		<!--eg. xs:dateTime('2015-01-01T20:26:39-08:00')-->
		<xsl:variable name="date" select="ou:to-dateTime($dateTime)"/>
				
		<!-- Proper Format: Wed, 02 Oct 2002 15:00:00 +0200 -->
		<xsl:value-of select="format-dateTime($date, '[FNn,*-3], [D01] [MNn,*-3] [Y0001] [H01]:[m01]:[s01] [Z0000]', 'en', 'AD', 'US')"/>
	</xsl:function>
	
	<!-- A date formatting option for displaying the date to the user. -->
	<xsl:function name="ou:to-display-date" as="xs:string">
		<xsl:param name="dateTime"/>
		<xsl:variable name="date" select="ou:to-dateTime($dateTime)"/>
		<!-- Current Format: October 02, 2002 -->
		<xsl:value-of select="format-dateTime($date, '[MNn,*] [D01],  [Y0001]', 'en', 'AD', 'US')"/>
	</xsl:function>
	
	<!--use format-dateTime() with ou:to-dateTime eg: <xsl:value-of select="format-dateTime($dateTime, ', [D01] [M] [Y0001] [H01]:[m01]:[s01] [z]')"/>-->
	<xsl:function name="ou:to-dateTime" as="xs:dateTime">
		<xsl:param name="pcf-date"/>
		<!--define time zone-->
		<xsl:variable name="time-zone" select="'-08:00'"/>
		<!--tokenize date from PCF, which uses datetime param-->
		<xsl:variable name="token-date" select="tokenize($pcf-date, ' ')"/>
		<!--calculate date depending on TCF or PCF dateTime-->
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="matches($pcf-date,'^\S+, \S+ \d{1,2}, \d{4} \d{1,2}:\d{2}:\d{2} [AP]M [A-Z]{3}$')">
					<!--TCF format 'Monday, January 26, 2015 2:13:39 PM PST' to '2015-01-26'-->
					<xsl:value-of select="concat($token-date[4], '-', ou:month-num($token-date[2], 'long'), '-', ou:double-digit(substring-before($token-date[3], ',')))"/>
				</xsl:when>
				<xsl:otherwise>
					<!--PCF format '01/26/2015 08:26:39 PM' to '2015-01-26'-->
					<xsl:value-of select="concat(tokenize($token-date[1], '/')[3], '-', ou:double-digit(tokenize($token-date[1], '/')[1]), '-', ou:double-digit(tokenize($token-date[1], '/')[2]))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="time">
			<xsl:choose>
				<xsl:when test="matches($pcf-date,'^\S+, \S+ \d{1,2}, \d{4} \d{1,2}:\d{2}:\d{2} [AP]M [A-Z]{3}$')">
					<!--convert 'Monday, January 26, 2015 2:13:39 PM PST' to '2015-01-26'-->
					<xsl:value-of select="concat(ou:double-digit(if ($token-date[6] = 'PM' and number(tokenize($token-date[5], ':')[1]) &lt; 12) then number(tokenize($token-date[5], ':')[1]) + 12 else if ($token-date[6] = 'PM' and number(tokenize($token-date[5], ':')[1]) = 12) then '00' else tokenize($token-date[5], ':')[1]), ':', ou:double-digit(tokenize($token-date[5], ':')[2]), ':', ou:double-digit(tokenize($token-date[5], ':')[3]))"/>
				</xsl:when>
				<xsl:otherwise>
					<!--convert '01/26/2015 08:26:39 PM' to '20:26:39'-->
					<xsl:value-of select="concat(ou:double-digit(if ($token-date[3] = 'PM' and number(tokenize($token-date[2], ':')[1]) &lt; 12) then number(tokenize($token-date[2], ':')[1]) + 12 else if ($token-date[3] = 'PM' and number(tokenize($token-date[2], ':')[1]) = 12) then '00' else tokenize($token-date[2], ':')[1]), ':', ou:double-digit(tokenize($token-date[2], ':')[2]), ':', ou:double-digit(tokenize($token-date[2], ':')[3]))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--new object xs:dateTime('2015-01-01T20:26:39-08:00')-->
		<xsl:value-of select="dateTime(xs:date($date), xs:time(concat($time, $time-zone)))" />
	</xsl:function>
	
	<xsl:function name="ou:double-digit">
		<xsl:param name="num"/>
		<xsl:value-of select="format-number(number($num), '00')"/>
	</xsl:function>
	
	<xsl:function name="ou:month-abbrev-en" as="xs:string?">
		<xsl:param name="date" as="xs:anyAtomicType?"/>
		<xsl:sequence select="('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[month-from-date(xs:date($date))]"/>
	</xsl:function>
	
	<xsl:function name="ou:day-of-week" as="xs:integer?">
		<xsl:param name="date" as="xs:anyAtomicType?"/>
		<xsl:sequence select="if (empty($date)) then () else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7"/>
	</xsl:function>
	
	<xsl:function name="ou:day-of-week-abbrev-en" as="xs:string?">
		<xsl:param name="date" as="xs:anyAtomicType?"/>
		<xsl:sequence select="('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')[ou:day-of-week($date) + 1]"/>
	</xsl:function>
	
	<xsl:function name="ou:month-name">
		<xsl:param name="month-num" />
		<xsl:value-of select="ou:month-name($month-num,'long')" />	
	</xsl:function>
	
	<xsl:function name="ou:month-name">
		<xsl:param name="month-num" />
		<xsl:param name="length" />
		<xsl:variable name="months" select="('January','February','March','April','May','June','July','August','September','October','November','December')" />
		<xsl:variable name="months-short" select="('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')" />
		<xsl:value-of select="if($length = 'short') then $months-short[number($month-num)] else $months[number($month-num)]" />
	</xsl:function>
	
	<xsl:function name="ou:month-num">
		<xsl:param name="month-name" />
		<xsl:value-of select="ou:month-num($month-name,'long')" />	
	</xsl:function>
	
	<xsl:function name="ou:month-num">
		<xsl:param name="month-name" />
		<xsl:param name="length" />
		<xsl:variable name="months" select="('January','February','March','April','May','June','July','August','September','October','November','December')" />
		<xsl:variable name="months-short" select="('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')" />
		<xsl:value-of select="ou:double-digit(if ($length = 'short') then index-of($months-short,$month-name) else index-of($months,$month-name))" />
	</xsl:function>
	
	<xsl:function name="ou:display-long-date">
		<xsl:param name="str" />
		<xsl:variable name="dateTime" select="ou:to-dateTime($str)"/>
		<xsl:variable name="day" select="format-dateTime($dateTime, '[D1]')"/>
		<xsl:variable name="month" select="format-dateTime($dateTime, '[M1]')"/>
		<xsl:variable name="year" select="format-dateTime($dateTime, '[Y0001]')"/>
		<xsl:try>
			<xsl:value-of select="concat(ou:month-name($month),' ',$day,', ',$year)" />
			<xsl:catch />
		</xsl:try>
	</xsl:function>

	<!-- ***************************************************************
						TAG API FUNCTIONS
	 *************************************************************** -->
	 
	<!-- PARAMETERS: None -->
	<xsl:function name="ou:get-page-tags">
		<xsl:sequence select="ou:get-page-tags($ou:stagingpath, $ou:site)" />	
	</xsl:function>

	<!-- PARAMETERS: Staging Path -->
	<xsl:function name="ou:get-page-tags">
		<xsl:param name="path" />
		<xsl:sequence select="ou:get-page-tags($path, $ou:site)" />
	</xsl:function>

	<!-- PARAMETERS: Staging Path, Site -->
	<xsl:function name="ou:get-page-tags">
		<xsl:param name="path" />
		<xsl:param name="site" />

		<xsl:variable name="tags-api" select="concat('ou:/Tag/GetTags?site=', $site,'&amp;path=', encode-for-uri($path))" />
		<xsl:copy-of select="ou:get-tags($tags-api)" />
	</xsl:function>

	<!-- TAGS API DOC CALL -->
	<xsl:function name="ou:get-tags">
		<xsl:param name="api" />
		<xsl:try>
			<xsl:sequence select="doc($api)/tags" />
			<xsl:catch>
			   <tags></tags>
			</xsl:catch>
		</xsl:try>
	</xsl:function>
	
</xsl:stylesheet>
