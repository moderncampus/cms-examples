<cfcomponent displayname="LDP-Connector" output="false" hint="LDP-Connector">

<cffunction name="init" access="public" returntype="struct">
	<cfreturn this>
</cffunction>
<cffunction
name="createStruct"
access="public"
returntype="array"
output="false"
hint="structure for the poster">
  
<cfargument
name="form_input"
type="struct"
required="true"
hint="Raw form structure"
/>
<cfargument
name="site_uuid"
type="string"
required="true"
hint="site UUID"
/>
<cfargument
name="form_content"
required="true"
hint="GetHttpRequestData().content string"
/>
<cfset formInput=contentSplitter(form_content)>
<cfset keysToStruct = StructKeyArray(formInput)>
  <cfloop index = "i" from = "1" to = "#ArrayLen(keysToStruct)#"> 
    <cfif ((keysToStruct[i] NEQ "FIELDNAMES") XOR (keysToStruct[i] NEQ "BUTTON") XOR (keysToStruct[i] NEQ "FORM_UUID"))>
      <cfset fields["#keysToStruct[i]#"]=#form_input[keysToStruct[i]]# >
    </cfif>
  </cfloop>
   
<cfset dataSet = ArrayNew(1)> 

<cfset cgiConfig["OXLDP_FORM_SERVER_NAME"]="#Cgi.SERVER_NAME#" >
<cfset cgiConfig["OXLDP_FORM_SERVER_IP"]="#Cgi.SERVER_ADDR#" >
<cfset cgiConfig["OXLDP_FORM_REQUEST_TIME"]="#Cgi.REQUEST_TIME#" >
<cfset cgiConfig["OXLDP_FORM_HTTP_HOST"]="#Cgi.HTTP_HOST#" >
<cfset cgiConfig["OXLDP_FORM_HTTP_REFERER"]="#Cgi.HTTP_REFERER#" >
<cfset cgiConfig["OXLDP_FORM_HTTP_USER_AGENT"]="#Cgi.HTTP_USER_AGENT#" >
<cfset cgiConfig["OXLDP_FORM_REMOTE_IP"]="#Cgi.REMOTE_ADDR#" >
<cfset cgiConfig["OXLDP_FORM_SCRIPT_NAME"]="#Cgi.SCRIPT_FILENAME#" >
<cfset cgiConfig["OXLDP_FORM_REMOTE_PORT"]="#Cgi.REMOTE_PORT#" >

<cfset dataSet[1] = 'ldp.form.submit'> 
<cfset dataSet[2] = '#site_uuid#'><!-- Site UUID -->
<cfset dataSet[3] = "#form_input.form_uuid#"><!-- Form UUID -->
<cfset dataSet[4] = "#fields#">
<cfset dataSet[5] = '#cgiConfig#'>
<cfreturn dataSet />
  
</cffunction>

<cffunction
name="contentSplitter"
access="public"
returntype="struct"
output="false"
hint="split content to preserve case">
  
<cfargument
name="form_content"
required="true"
hint="form structure"
/>
 
<cfloop list="#form_content#" index="i" delimiters="&">
	<cfif ArrayLen(ListToArray(i,'=')) LT 2>
		<cfset fieldStruct[#ListToArray(i,'=')[1]#]="">
	<cfelse>
		<cfset fieldStruct[#ListToArray(i,'=')[1]#]=#ListToArray(i,'=')[2]#>
	</cfif>
</cfloop>
<cfreturn fieldStruct />
  
</cffunction>

<cffunction
name="createResponse"
access="public"
returntype="struct"
output="false"
hint="Create response for JSON output">
  
<cfargument
name="CFMLRes"
required="true"
hint="XML-RPC Response"
/>
 
<cfset msg = StructNew()>
<cfif #StructKeyExists(CFMLRes.PARAMS[1],"success")# NEQ "NO">
       <cfoutput>#CFMLRes.PARAMS[1].success#</cfoutput>
       <cfif #CFMLRes.PARAMS[1].success# EQ "No">
              <cfset msg["active"]="false">
              <cfset msg["message"]="#CFMLRes.PARAMS[1].message#">
              <cfset msg["data"]="#CFMLRes.PARAMS[1].errors#">  
       <cfelseif #CFMLRes.PARAMS[1].success# EQ "Yes">
              <cfoutput>Got Here</cfoutput>
              <cfset msg["active"]="true">
              <cfset msg["message"]="#CFMLRes.PARAMS[1].message#">
              <cfset msg["data"]="#CFMLRes.PARAMS[1].errors#">  
       <cfelse><!--- Unknown Error --->
              <cfset msg["active"]="false">
              <cfset msg["message"]="#CFMLRes.PARAMS[1].faultString#">
              <cfset msg["data"]="#CFMLRes.PARAMS[1].faultCode#">
       </cfif>
<cfelse>
	<cfset msg["active"]="false">
        <cfset msg["message"]="#CFMLRes.PARAMS[1].faultString#">
	<cfset msg["data"]="#CFMLRes.PARAMS[1].faultCode#">
</cfif>
<cfreturn msg />
  
</cffunction>

</cfcomponent>