<cfobject component="xmlrpc" name="cfc.xmlrpc"> 
<cfobject component="ldp_connector" name="cfc.connector">
<cfinclude template="config.cfm">
<cfset connector_dump=#cfc.connector.createStruct(Form,#site_uuid#,GetHttpRequestData().content)# >
<cfset xmlString = cfc.xmlrpc.CFML2XMLRPC(connector_dump)>
<cfhttp method="post" url=#ssm_host# result="myResult" > 
       <cfhttpparam type="xml" value="#xmlString#"> 
</cfhttp> 
<cfset CFMLRes = cfc.xmlrpc.XMLRPC2CFML(myResult.fileContent)> 
<cfset msg = cfc.connector.createResponse(CFMLRes)>
<cfoutput>#SerializeJSON(msg)#</cfoutput>
