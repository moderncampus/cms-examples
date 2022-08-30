/*
    gadgetlib.js v1.0.7.1
    Copyright 2015 OmniUpdate, Inc.
    http://www.omniupdate.com/

    Changes in 1.0.7.1:
      - gadgetlib.min.js is now offered.

    Changes in 1.0.6.1:
      - Reintroduced the `Gadget` object, which was dropped in version 1.0.4, for backward
        compatibility with gadgets that were written against the old library.
    
    Changes in 1.0.6:
      - The `sendMessageToTop` function is again exposed as the `_sendMessageToTop` method of
        the `gadget` object. Version 1.0.4 had removed this public method, breaking functionality
        in gadgets that called it.
    
    Changes in 1.0.5.1:
      - No code changes. Edited change log to reflect that changes to API token access will
        occur in OU Campus v10.3, not v10.2.2.
    
    Changes in 1.0.5:
      - All gadget methods are bound to the gadget to better support use as callbacks.
    
    Changes in 1.0.4:
      - Starting with OU Campus v10.3, the API access token and certain environment details will
        no longer be embedded in the URLs of custom gadgets. Instead, gadgets must request this
        information from the OU Campus app. This version of gadgetlib does this automatically,
        but since the process is asynchronous, gadget scripts must wait for the token to become
        available before they can use it.
        
        To accommodate this change, you should wrap the main logic of your gadget in a function
        that is called by the new `gadget.ready()` method. This method accepts a single argument,
        which is a reference to the function to be called when the API token has been received.
        The method returns a jQuery Deferred object, so alternatively you can provide the callback
        function as an argument to the `.then()` method of the return object, as in
        `gadget.ready().then(myFunc)`.
        
        The `gadget.ready()` method already works with OU Campus v10.2.1.1. Although the new way
        of obtaining the API token will not be in place until 10.3, you should adapt your
        gadgets to the new method now in preparation for the change.
    
    Changes in 1.0.3:
      - sendMessageToTop function now JSON-stringifies message data for compatibility with IE9.
    
    Changes in 1.0.2:
      - Library now exports gadget object directly to window; no need to use Gadget constructor.
    
    Changes in 1.0.1:
      - Added oucGetCurrentFileInfo method.
*/

(function () {
    
    // private function 
    function getEnvironment() {
        /*
            This private function gets certain information by making a request to OU Campus,
            including key information you'll need to make an OU Campus API call. These data then
            become properties of the gadget object. The properties are as follows:
            
            Name        Example Value               Description
            ----------- --------------------------- ---------------------------------------------------
            apihost     http://a.cms.omniupdate.com The HTTP root address of the OU Campus
                                                    application server, which is also the API
                                                    server. All OU Campus  API endpoints begin
                                                    with this value.
            token       A3xthrVCELk8XIaOEQKrIF      The authorization token provided to your gadget
                                                    for the current login session. Must be
                                                    submitted with every API call, in the
                                                    authorization_token parameter.
            gid         ae206856-114c-4124-b0f1     A generated ID that uniquely identifies your
                                                    gadget. This is used internally by the `fetch`
                                                    and `save` methods.
            place       sidebar                     Lets you know where in the OU Campus user
                                                    interface  the current instance of your gadget
                                                    is. This can be either 'dashboard' or
                                                    'sidebar'.
            skin        testdrives                  The name of the current OU Campus skin.
            account     Gallena_University          The name of the OU Campus account to which the
                                                    user is logged in.
            site        School_of_Medicine          The name of the site that is currently active
                                                    in OU Campus.
            user        jdoe                        The username of the logged-in OU Campus user.
            hostbase    /10/#skin/account/site      The starting fragment of all paths of pages in
                                                    the current OU Campus session. Use this to help
                                                    construct URLs to OU Campus pages that your
                                                    gadget can link to or load in the top window.
            
            So, for example, to get the apihost and token values, you would use:
            
                var apihost = gadget.get('apihost');
                var token = gadget.get('token');
        */
        return sendMessageToTop('get-environment');
    }
    // private function 
    function getDataFromUrl() {
        var data = {};
        var split = location.href.split(/[\?&]/);
        var paramArray = split.splice(1);
        data.url = split[0];
        for (var pieces, left, right, i = 0; i < paramArray.length; i++) {
            pieces = paramArray[i].split('=');
            left = pieces[0];
            right = pieces[1];
            data[left] = right;
        }
        gadget.set(data);
    }
    // private function 
    function sendMessageToTop(name, payload) {
        var self = gadget;
        var deferred = null;
        var msgid = Math.random().toString().slice(2);
        var message = {
            name     : name, 
            gid      : self.gid,
            origin   : self.url,
            token    : self.token,
            place    : self.place,
            payload  : payload,
            callback : msgid
        };
        deferred = new $.Deferred();
        var _messageHandler = function (evt) {
            if (evt.origin != self.msghost) {
                return;
            }
            var message = evt.data;
            if (typeof message == 'string') {
                try {
                    message = JSON.parse(message);
                } catch (e) {
                    console.log('Cannot parse message from OU Campus app:', message);
                    return;
                }
            }
            console.log('Response from OU Campus:', message);
            if (message.callback == msgid) {
                window.removeEventListener('message', _messageHandler, false);
                deferred.resolve(message.payload);
            }
        };
        window.addEventListener('message', _messageHandler, false);
        window.top.postMessage(JSON.stringify(message), self.msghost);
        return deferred;
    }
    // private function 
    function messageHandler(evt) {
        var self = gadget;
        
        if (evt.origin != self.msghost) {
            return;
        }
        var message = evt.data;
        if (typeof message == 'string') {
            try {
                message = JSON.parse(message);
            } catch (e) {
                console.log('Cannot parse message from OU Campus app:', message);
                return;
            }
        }
        if (message.callback) {
            // the message listener in sendMessageToTop will handle this message
            return;
        }
        console.log('Message from OU Campus:', message);
        if (message.name == 'configuration') {
            self.setConfig(message.payload);
        }
        $(self).trigger(message.name, message.payload);
    }
    
    // the gadget object definition; contains the public methods available to use in your gadget
    // as methods of the `gadget` object
    var gadget = {
        ready: function (callback) {
            // Your code should call this asynchronous method (once) before doing anything that
            // requires an API token or any of the other data provided by the private
            // `getEnvironment` method. The main logic of the gadget should be wrapped in a
            // function that is called when the `ready` method has completed.
            // You can provide the callback function either as an argument to the `ready`
            // method itself, as in `gadget.ready(myFunc)`, or as an argument to the `then` method
            // of the jQuery Deferred object that this method returns, as in
            // `gadget.ready().then(myFunc)`.
            
            var deferred = new $.Deferred();
            if (this.isReady) {
                callback && callback();
                deferred.resolve();
            } else {
                $(this).one('ready', function () {
                    callback && callback();
                    deferred.resolve();
                });
            }
            return deferred;
        },
        get: function (propName) {
            // Get the value of a property of the gadget.
            if (typeof this[propName] == 'object') {
                return JSON.parse(JSON.stringify(this[propName]));
            } else {
                return this[propName];
            }
        },
        set: function (arg0, arg1) {
            // Set a property of the gadget. You can pass either a single property name and value
            // as two arguments, e.g.:
            //     gadget.set('favoriteColor', 'blue');
            // or several properties in a plain object, e.g.:
            //     gadget.set({ favoriteColor: 'blue', favoriteFlavor: 'vanilla' });
            if (typeof arg0 == 'string') {
                // assume arg0 is a property name and arg1 is the property value
                this[arg0] = arg1;
            } else {
                // assume arg0 is an object
                for (var key in arg0) {
                    if (arg0.hasOwnProperty(key)) {
                        this[key] = arg0[key];
                    }
                }
            }
        },
        getConfig: function (propName) {
            // Same as the `get` method, but returns a subproperty of the gadget's `config`
            // property, which is set by the `fetch` method.
            if (typeof this.config[propName] == 'object') {
                return JSON.parse(JSON.stringify(this.config[propName]));
            } else {
                return this.config[propName];
            }
        },
        setConfig: function (arg0, arg1) {
            // Same as the `set` method, but sets a subproperty of the gadget's `config` property.
            if (typeof arg0 == 'string') {
                // assume arg0 is a property name and arg1 is the property value
                this.config[arg0] = arg1;
            } else {
                // assume arg0 is an object
                for (var key in arg0) {
                    if (arg0.hasOwnProperty(key)) {
                        this.config[key] = arg0[key];
                    }
                }
            }
        },
        fetch: function () {
            // A convenience method to get the gadget's configuration as stored in the OU Campus
            // database by calling the /gadgets/view API. On a successful API call, the method
            // saves the config into the Gadget instance; you can then use `getConfig` to get
            // specific properties of the configuration.
            //
            // The method returns a jQuery Deferred object, so you can use methods like `then` to
            // do stuff once the API call has received a response.
            var self = this;
            var endpoint = self.apihost + '/gadgets/view';
            var params = {
                authorization_token: self.token,
                account: self.account,
                gadget: self.gid
            };
            return $.ajax({
                type    : 'GET',
                url     : endpoint, 
                data    : params, 
                success : function (data) {
                    // console.log('Fetched data:', data);
                    self.config = {};
                    for (var key in data.config) {
                        if (data.config.hasOwnProperty(key)) {
                            self.config[key] = data.config[key].value;
                        }
                    }
                },
                error : function (xhr, status, error) {
                    console.log('Fetch error:', status, error);
                }
            });
        },
        save: function (arg0, arg1) {
            // A convenience method to set one or more properties of the gadget's configuration
            // back to the OU Campus database by calling /gadgets/configure.
            //
            // The method returns a jQuery Deferred object, so you can use methods like `then`
            // to do stuff once the API call has received a response.
            if (arg0) {
                this.setConfig(arg0, arg1);
            }
            var self = this;
            var endpoint = self.apihost + '/gadgets/configure';
            var params = self.config;
            params.authorization_token = self.token;
            params.account = self.account;
            params.gadget = self.gid;
            return $.ajax({
                type    : 'POST',
                url     : endpoint, 
                data    : params, 
                success : function (data) {
                    // console.log('Saved:', data);
                },
                error : function (xhr, status, error) {
                    console.log('Save error:', status, error);
                }
            });
        },
        // for backward compatibility with pre-1.0.4 versions of gadgetlib.js
        _sendMessageToTop: sendMessageToTop,
        // Each of the "ouc" methods below is an asynchronous method that returns a jQuery Deferred
        // object, so you can use methods like `then` to do stuff once the operation is finished.
        oucGetCurrentFileInfo: function () {
            // Causes OU Campus to respond with information about the current file in OU Campus, if
            // the current view is file-specific.
            return sendMessageToTop('get-current-file-info');
        },
        oucInsertAtCursor: function (content) {
            // Causes OU Campus to insert the content at the cursor location in, and only in, a WYSIWYG
            // editor (such as JustEdit) and the source code editor.
            return sendMessageToTop('insert-at-cursor', content);
        },
        oucGetCurrentLocation: function () {
            // Causes OU Campus to respond with the app window's location info.
            return sendMessageToTop('get-location');
        },
        oucSetCurrentLocation: function (route) {
            /*
                Causes OU Campus to set the "route" of the OU Campus application. The route is the
                portion of the app's location that follows the sitename. For example, if the
                current app URL is
                
                "http://a.cms.omniupdate.com/10/#oucampus/gallena/art/browse/staging/about"
                
                then the route is "/browse/staging/about". Changing the route will effectively
                change the current OU Campus view, just as if the user had clicked a link within
                OU Campus.
                
                This method accepts a single string parameter, which is the new route. It should
                start with a slash. After the route has been changed, the method will respond with
                the new location.
            */
            return sendMessageToTop('set-location', route);
        },
        oucRefreshLocation: function () {
            return sendMessageToTop('refresh-location');
        },
        oucGetWYSIWYGSelection: function () {
            return sendMessageToTop('get-wysiwyg-selection');   
        },
        oucGetWYSIWYGContent: function () {
            return sendMessageToTop('get-wysiwyg-content'); 
        },
        oucGetSourceContent: function () {
            return sendMessageToTop('get-source-content'); 
        }
    };
    
    // bind all methods to the gadget object
    for (var method in gadget) {
        gadget[method] = gadget[method].bind(gadget);
    }

    var MetadataAPI = {
        /*
         * MetaData API
         *
         * @description :: API to interact with OU Campus gadget Metadata backend
         * @documentation :: https://docs
         *
         * @method Metadata
         * @param {object} params Argument 1
         * @param {String} params.action Metadata action name.
         * @param {string} params.link_type Required if 'link' or 'unlink' actions are called.
         * @return {promise} Ajax promise object.
         *
         */        
        gadget : gadget,
        //Param Validation
        paramValidation : function (params) {
            if(!params){ throw 'Missing parameters for Metadata API request.'; }
            if (!params.action) { throw 'Missing \'action\' property in options object'; }
            if ( ((params.action === 'update' || params.action === 'delete' || params.action === 'view') && !params.id) || 
                 (params.action === 'create' && (!params.mime_type || !params.metadata)) ||
                 (params.action === 'link' && (!params.item || !params.id) ) || 
                 (params.action === 'unlink' && !params.item) || 
                 (params.action === 'grouplink' && (!params.id || !params.groups)) || 
                 (params.action === 'groupunlink' && (!params.id || !params.groups)) || 
                 (params.action === 'list' && !params.mime_type)) { 
                    throw 'Missing required parameter for \'' + params.action + '\' Metadata API request'; 
            }
        },
        cleanProps : function (params, defaults) {
            for (var prop in params) {
                var metadataProp;
                switch (prop) {
                    case 'mime_type' : metadataProp = true; break;
                    case 'metadata' : metadataProp = true; break;
                    case 'metadatas' : metadataProp = true; break;
                    case 'scope' : metadataProp = true; break;
                    case 'groups' : metadataProp = true; break;
                    case 'item' : metadataProp = true; break;
                    case 'item_type' : metadataProp = true; break;
                    case 'id' : metadataProp = true; break;
                    case 'ids' : metadataProp = true; break;
                    case 'asset' : metadataProp = true; break;
                    case 'page' : metadataProp = true; break;
                    case 'directory' : metadataProp = true; break;
                    case 'site' : metadataProp = true; break;
                    case 'ou_site' : metadataProp = true; break;
                    default : metadataProp = false;
                }
                if (metadataProp) {
                    defaults.data[prop] = params[prop];
                    delete params[prop];
                }
            }
            return defaults;
        },
        create : function (params, options) {
            if (!params) { params = {}; }
            if (!options) { options = {}; }
            params.action = 'create';
            this.paramValidation(params);
            var ajaxParams = {
                type     : 'POST', 
                dataType : 'json',
                url : this.gadget.apihost + '/metadata/new',
                data     : { 
                    site : params.ou_site || this.gadget.site,
                    authorization_token : this.gadget.token
                } 
            };
            ajaxParams = this.cleanProps(params, ajaxParams);
            return $.ajax($.extend(ajaxParams, options));
        },
        update : function (params, options) {
            if (!params) { params = {}; }
            if (!options) { options = {}; }
            params.action = 'update';
            this.paramValidation(params);
            var ajaxParams = {
                type     : 'POST', 
                dataType : 'json',
                url : this.gadget.apihost + '/metadata/save',
                data     : { 
                    site : params.ou_site || this.gadget.site,
                    authorization_token : this.gadget.token
                } 
            };
            ajaxParams = this.cleanProps(params, ajaxParams);
            return $.ajax($.extend(ajaxParams, options));
        },
        delete : function (params, options) {
            if (!params) { params = {}; }
            if (!options) { options = {}; }
            params.action = 'delete';
            this.paramValidation(params);
            var ajaxParams = {
                type     : 'POST', 
                dataType : 'json',
                url : this.gadget.apihost + '/metadata/delete',
                data     : { 
                    site : params.ou_site || this.gadget.site,
                    authorization_token : this.gadget.token
                } 
            };
            ajaxParams = this.cleanProps(params, ajaxParams);
            return $.ajax($.extend(ajaxParams, options));
        },
        list : function (params, options) {
            if (!params) { params = {}; }
            if (!options) { options = {}; }
            params.action = 'list';
            this.paramValidation(params);
            var ajaxParams = {
                type     : 'GET', 
                dataType : 'json',
                url : this.gadget.apihost + '/metadata/list',
                data     : { 
                    site : params.ou_site || this.gadget.site,
                    authorization_token : this.gadget.token
                } 
            };
            ajaxParams = this.cleanProps(params, ajaxParams);
            return $.ajax($.extend(ajaxParams, options));
        },
        view : function (params, options) {
            if (!params) { params = {}; }
            if (!options) { options = {}; }
            params.action = 'view';
            this.paramValidation(params);
            var ajaxParams = {
                type     : 'GET', 
                dataType : 'json',
                url : this.gadget.apihost + '/metadata/view',
                data     : { 
                    site : params.ou_site || this.gadget.site,
                    authorization_token : this.gadget.token
                } 
            };
            ajaxParams = this.cleanProps(params, ajaxParams);
            return $.ajax($.extend(ajaxParams, options));
        },
        link : function (params, options) {
            if (!params) { params = {}; }
            if (!options) { options = {}; }
            params.action = 'link';
            this.paramValidation(params);
            var ajaxParams = {
                type     : 'POST', 
                dataType : 'json',
                url : this.gadget.apihost + '/metadata/'+ params.link_type + 'link',
                data     : { 
                    site : params.ou_site || this.gadget.site,
                    authorization_token : this.gadget.token
                } 
            };
            ajaxParams = this.cleanProps(params, ajaxParams);
            return $.ajax($.extend(ajaxParams, options));
        },
        unlink : function (params, options) {
            if (!params) { params = {}; }
            if (!options) { options = {}; }
            params.action = 'unlink';
            this.paramValidation(params);
            var ajaxParams = {
                type     : 'POST', 
                dataType : 'json',
                url : this.gadget.apihost + '/metadata/'+ params.link_type + 'unlink',
                data     : { 
                    site : params.ou_site || this.gadget.site,
                    authorization_token : this.gadget.token
                } 
            };
            ajaxParams = this.cleanProps(params, ajaxParams);
            return $.ajax($.extend(ajaxParams, options));
        },
        groupLink : function (params, options) {
            if (!params) { params = {}; }
            if (!options) { options = {}; }
            params.action = 'grouplink';
            this.paramValidation(params);
            var ajaxParams = {
                type     : 'POST', 
                dataType : 'json',
                url : this.gadget.apihost + '/metadata/grouplink',
                data     : { 
                    site : params.ou_site || this.gadget.site,
                    authorization_token : this.gadget.token
                } 
            };
            ajaxParams = this.cleanProps(params, ajaxParams);
            return $.ajax($.extend(ajaxParams, options));
        },
        groupUnlink : function (params, options) {
            if (!params) { params = {}; }
            if (!options) { options = {}; }
            params.action = 'groupunlink';
            this.paramValidation(params);
            var ajaxParams = {
                type     : 'POST', 
                dataType : 'json',
                url : this.gadget.apihost + '/metadata/groupunlink',
                data     : { 
                    site : params.ou_site || this.gadget.site,
                    authorization_token : this.gadget.token
                } 
            };
            ajaxParams = this.cleanProps(params, ajaxParams);
            return $.ajax($.extend(ajaxParams, options));
        }
    };

    gadget.Metadata = MetadataAPI;
    
    gadget.set(getDataFromUrl());
    getEnvironment().then(function (response) {
        if (response != 'Unrecognized message.') {
            gadget.set(response);
        }
        gadget.isReady = true;
        $(gadget).trigger('ready');
    });
    
    window.addEventListener('message', messageHandler, false);
    
    // make the gadget object available as a global variable
    window.gadget = gadget;
    
    // for backward compatibility with pre-1.0.4 versions of gadgetlib.js
    window.Gadget = function () {};
    window.Gadget.prototype = gadget;
})();

