<%@ WebHandler Language="C#" Class="LDPForm" %>
using System;
using System.Configuration;
using System.Net;
using System.Collections.Specialized;
using System.Text;
using System.Web;
using CookComputing.XmlRpc;
using Jayrock.Json;
using Jayrock.Json.Conversion;

public class LDPForm : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        /* CONFIGURATION */             
        string captchaSecret = ""; // Set to Google reCAPTCHA secret. CAPTCHA validation is bypassed if this is left empty.
        /*****************/ 
        
        bool formValidated = true;
        
        if(context.Request["form_grc"] != null && captchaSecret != ""){ // obfuscated form field that indictates google reCAPTCHA validation is required.
            formValidated = validateCaptcha(context, captchaSecret);
        }
        
        if(formValidated){
            string myPath = context.Server.MapPath(".");
            context.Response.ContentType = "text/plain";
            JsonObject ouResponse = Modern Campus.LDP.Form.Send(null, context.Request,myPath);
            context.Response.Write(ouResponse);
        }else{
            context.Response.Write("{\"active\":false,\"message\":\"Form did not pass CAPTCHA validation!\",\"data\":\"\"}");
        }
    }
    
    public bool validateCaptcha(HttpContext context, string captchaSecret) {
        string endPoint = "https://www.google.com/recaptcha/api/siteverify";
        string captchaResponse = context.Request["g-recaptcha-response"];
        string remoteIP = context.Request.ServerVariables["REMOTE_ADDR"];

        if(String.IsNullOrEmpty(captchaResponse)){
            return false;
        }

        using (var client = new WebClient()){
            var values = new NameValueCollection();
            values["secret"] = captchaSecret;
            values["response"] = captchaResponse;
            values["remoteip"] = remoteIP;

            var response = client.UploadValues(endPoint, values);
            var responseString = Encoding.Default.GetString(response);
            dynamic responseObject = JsonConvert.Import(responseString);

            if(responseObject["success"] != true){
                return false;
            }
        }
        
        return true;
    }
    
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}
namespace Modern Campus
{
    namespace LDP
    {
        public class Form
        {
            public static ISSM OUFormProxy = XmlRpcProxyGen.Create<ISSM>();

            public static JsonObject MakeError(String err, String msg)
            {
                JsonObject json = new JsonObject();

                json.Add("active", false);
                json.Add("message", err);
                json.Add("data", msg);

                return json;
            }

            public static JsonObject GetConfig(string myPath)
            {
                JsonObject json = new JsonObject();
                string file = myPath+"/sites.json";
                //deserialize JSON from file  

                json.Add("data",Jayrock.Json.Conversion.JsonConvert.Import(System.IO.File.ReadAllText(file)));
                return json;
            }

            public static string GetUUID(string siteName, string myPath)
            {
                JsonObject ouResponse2;
                string site_uuid = "";

                ouResponse2 = Modern Campus.LDP.Form.GetConfig(myPath);
                dynamic dynJson = ouResponse2;
                foreach (var item in dynJson["data"])
                { foreach (var item2 in item["sites"])
                    {
                        if (siteName == item2["name"])
                        {
                            site_uuid = item2["uuid"];
                        }
                    }
                }

                return site_uuid;

            }

            public static JsonObject Send(String method, HttpRequest options, String myPath)
            {
                JsonObject result;
                XmlRpcStruct formParams = new XmlRpcStruct(),
                    ouSettings = new XmlRpcStruct(),
                    response;
                String siteUUID, formUUID, siteName;

                if (!options.Form.HasKeys())
                {
                    result = MakeError("Form Exception", "Form data not provided.");
                }
                else
                {
                    try
                    {
                        result = new JsonObject();
                        ouSettings.Add("OXLDP_FORM_REMOTE_IP", options.ServerVariables.Get("REMOTE_ADDR"));
                        formUUID = options.Form.Get("form_uuid");
                        siteName = options.Form.Get("site_name");
                        siteUUID = GetUUID(siteName, myPath);
                        if (formUUID == null || formUUID.Equals(""))
                            throw new Exception("Incomplete form data: UUID");

                        foreach (string key in options.Form)
                        {
                            if (key.Equals("form_uuid"))
                            {
                                continue;
                            }

                            formParams.Add(key, options.Form.Get(key));
                        }

                        response = OUFormProxy.Submit(siteUUID, formUUID, formParams, ouSettings);

                        if (response.Contains("faultCode"))
                        {
                            result["message"] = "FaultCode: " + response["faultCode"];
                            result["data"] = response["faultString"];
                        }
                        else if (response.Contains("success"))
                        {
                            bool active = (bool)response["success"];
                            result["active"] = active;
                            result["message"] = response["message"];

                            if (!active)
                                result["data"] = response["errors"];
                        }
                      
                        else if (response.Contains("errors"))
                        {
                            result["active"] = true;
                            result["message"] = "FaultCode: " + response["faultCode"];
                            result["data"] = response["faultString"];
                        }
                        else
                        {
                            result["message"] = "FaultCode: unknown";
                            result["data"] = "An unknown error when contacting the server. Please Check the logs or confirm if port 7218 is open.";
                        }
                    }
                    catch (JsonException e)
                    {
                        result = MakeError("JSON Exception", "Could not encode response as JSON.");
                    }
                    catch (XmlRpcException e)
                    {
                        result = MakeError("XML-RPC Exception", "Could not connect to server. Please check configuration.");
                    }
                    catch (Exception e)
                    {
                        result = MakeError("Generic Exception", "Something fundamentlly bad happened. " + e.ToString());
                    }
                }
                return result;
            }
        }

        [XmlRpcUrl("http://localhost:7518")]
        public interface ISSM : IXmlRpcProxy
        {
            [XmlRpcMethod("ldp.form.enabled")]
            XmlRpcStruct IsEnabled(String suuid, String fuuid);

            [XmlRpcMethod("ldp.form.submit")]
            XmlRpcStruct Submit(String suuid, String fuuid, XmlRpcStruct submitted, XmlRpcStruct data);
        }
    }
}