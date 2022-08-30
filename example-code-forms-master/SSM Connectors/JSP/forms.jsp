<%@page import="java.util.Arrays"%>
<%@page import="com.google.gson.JsonArray"%>
<%@page import="com.google.gson.GsonBuilder"%>
<%@page import="com.google.gson.JsonObject"%>
<%@page import="com.google.gson.JsonParser"%>
<%@page import="com.google.gson.JsonElement"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.net.URL"%>
<%@page import="org.apache.xmlrpc.client.*"%>
<%@page import="org.apache.xmlrpc.client.XmlRpcClientConfigImpl"%>
<%@page import="org.apache.xmlrpc.client.XmlRpcLocalClientConfig"%>


<%
    String ssm_host = "http://127.0.0.1";
    String ssm_port = "7518";
    String site_uuid = "e956fda9-61bf-4b0c-856c-54749481acec";

    /* DO NOT CHANGE ANYTHING BELOW THIS LINE*/
    String server = ssm_host + ":" + ssm_port;
    Map<String, String[]> paramNames = new HashMap();
    paramNames = request.getParameterMap();
    String form_uuid = request.getParameter("form_uuid");

    String json_out = "";
    Map output = new HashMap();

    try {
        XmlRpcClientConfigImpl my_config = new XmlRpcClientConfigImpl();
        my_config.setServerURL(new URL(server));
        XmlRpcClient client = new XmlRpcClient();
        client.setConfig(my_config);

        Map formParams = new HashMap();

        if (request.getParameter("form_uuid") != null) {

            for (Object key : paramNames.keySet()) {
                String keyStr = (String) key;
                if (keyStr.contains("[]")) {
                    String[] value = (String[]) paramNames.get(keyStr);
                    String newKey = keyStr.split("\\[")[0];
                    formParams.put(newKey, value);

                } else {
                    String value = request.getParameter(keyStr);
                    formParams.put((String) key, value);

                }

            }

            Map map = new HashMap();
            map.put("OXLDP_FORM_SERVER_NAME", request.getServerName());
            map.put("OXLDP_FORM_SERVER_IP", request.getLocalAddr());
            map.put("OXLDP_FORM_REQUEST_TIME", "");
            map.put("OXLDP_FORM_HTTP_HOST", "");
            map.put("OXLDP_FORM_HTTP_REFERER", "");
            map.put("OXLDP_FORM_HTTP_USER_AGENT", "");
            map.put("OXLDP_FORM_REMOTE_IP", request.getRemoteAddr());
            map.put("OXLDP_FORM_SCRIPT_NAME", "");
            map.put("OXLDP_FORM_REMOTE_PORT", "");

            Object[] params = new Object[]{site_uuid, form_uuid, formParams, map};
            Object result = (Object) client.execute("ldp.form.submit", params);

            String json = new Gson().toJson(result);
            JsonElement jelement = new JsonParser().parse(json);
            JsonObject jobject = jelement.getAsJsonObject();

            if (jobject.get("faultCode") != null) {
                output.put("message", "Faultcode : " + jobject.get("faultCode").toString());
                output.put("data", jobject.get("faultString").toString());
            } else if (jobject.get("success") != null) {

                if (jobject.get("success").getAsBoolean() == true) {
                    output.put("active", jobject.get("success").getAsBoolean());
                    output.put("message", jobject.get("message").getAsString());

                } else {
                    output.put("active", jobject.get("success").getAsBoolean());
                    output.put("message", jobject.get("message").getAsString());
                    JsonArray jarray = jobject.getAsJsonArray("errors");
                    jobject = jarray.get(0).getAsJsonObject();
                    output.put("data", jarray);
                }
            } else if (jobject.get("active") != null) {

                if (jobject.get("active").getAsBoolean() == true) {
                    output.put("active", true);
                    output.put("message", "Form ID");
                    output.put("data", form_uuid);

                } else {
                    output.put("message", jobject.get("message").getAsString());

                }

            } else if (jobject.get("errors") != null) {

                output.put("active", true);
                output.put("message", "errors");
                JsonArray jarray = jobject.getAsJsonArray("errors");
                jobject = jarray.get(0).getAsJsonObject();
                output.put("data", jobject);
            } else {
                output.put("message", "Faultcode : unknown");
                output.put("data", "An unknown error when contacting the server. Please Check the logs.");
            }
        } else {

            System.out.println("else");
            Object[] params = new Object[]{site_uuid, form_uuid};
            Object result = (Object) client.execute("ldp.form.enabled", params);

            String json = new Gson().toJson(result);
            JsonElement jelement = new JsonParser().parse(json);
            JsonObject jobject = jelement.getAsJsonObject();

            if (jobject.get("faultCode") != null) {
                output.put("message", "Faultcode : " + jobject.get("faultCode").toString());
                output.put("data", jobject.get("faultString").toString());
            } else if (jobject.get("success") != null) {

                if (jobject.get("success").getAsBoolean() == true) {
                    output.put("active", jobject.get("success").getAsBoolean());
                    output.put("message", jobject.get("message").getAsString());

                } else {
                    output.put("active", jobject.get("success").getAsBoolean());
                    output.put("message", jobject.get("message").getAsString());
                    JsonArray jarray = jobject.getAsJsonArray("errors");
                    jobject = jarray.get(0).getAsJsonObject();
                    output.put("data", jobject);
                }
            } else if (jobject.get("active") != null) {

                if (jobject.get("active").getAsBoolean() == true) {
                    output.put("active", true);
                    output.put("message", "Form ID");
                    output.put("data", form_uuid);

                } else {
                    output.put("message", jobject.get("message").getAsString());

                }

            } else if (jobject.get("errors") != null) {

                output.put("active", true);
                output.put("message", "errors");
                JsonArray jarray = jobject.getAsJsonArray("errors");
                jobject = jarray.get(0).getAsJsonObject();
                output.put("data", jobject);
            } else {
                output.put("message", "Faultcode : unknown");
                output.put("data", "An unknown error when contacting the server. Please Check the logs.");
            }

        }

        /* WRITE OUTPUT*/
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");

        Gson gson = new GsonBuilder().create();

        json_out = gson.toJson(output);
        response.getWriter().print(json_out);

    } catch (Exception e) {
        response.getWriter().write("Exception: " + e.getMessage());
    }
%>
