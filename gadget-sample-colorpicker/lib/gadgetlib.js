/*
    gadgetlib.js v1.0.7
    Copyright 2015 Modern Campus, Inc.
    http://www.omniupdate.com/
    
    Changes in 1.0.7:
      - Added oucGetWYSIWYGSelection method which returns the current WYSIWYG selection.
        (supported in both the JustEdit Editor and the WYSIWYG Editor, requires Modern Campus CMS 10.3.2 or above)

      - Added oucGetWYSIWYGContent method which returns the entire WYSIWYG contents.
        (supported in both the JustEdit Editor and the WYSIWYG Editor, requires Modern Campus CMS 10.3.2 or above)

    Changes in 1.0.6.1:
      - Reintroduced the `Gadget` object, which was dropped in version 1.0.4, for backward
        compatibility with gadgets that were written against the old library.
    
    Changes in 1.0.6:
      - The `sendMessageToTop` function is again exposed as the `_sendMessageToTop` method of
        the `gadget` object. Version 1.0.4 had removed this public method, breaking functionality
        in gadgets that called it.
    
    Changes in 1.0.5.1:
      - No code changes. Edited change log to reflect that changes to API token access will
        occur in Modern Campus CMS v10.3, not v10.2.2.
    
    Changes in 1.0.5:
      - All gadget methods are bound to the gadget to better support use as callbacks.
    
    Changes in 1.0.4:
      - Starting with Modern Campus CMS v10.3, the API access token and certain environment details will
        no longer be embedded in the URLs of custom gadgets. Instead, gadgets must request this
        information from the Modern Campus CMS app. This version of gadgetlib does this automatically,
        but since the process is asynchronous, gadget scripts must wait for the token to become
        available before they can use it.
        
        To accommodate this change, you should wrap the main logic of your gadget in a function
        that is called by the new `gadget.ready()` method. This method accepts a single argument,
        which is a reference to the function to be called when the API token has been received.
        The method returns a jQuery Deferred object, so alternatively you can provide the callback
        function as an argument to the `.then()` method of the return object, as in
        `gadget.ready().then(myFunc)`.
        
        The `gadget.ready()` method already works with Modern Campus CMS v10.2.1.1. Although the new way
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
            This private function gets certain information by making a request to Modern Campus CMS,
            including key information you'll need to make an Modern Campus CMS API call. These data then
            become properties of the gadget object. The properties are as follows:
            
            Name        Example Value               Description
            ----------- --------------------------- ---------------------------------------------------
            apihost     http://a.cms.omniupdate.com The HTTP root address of the Modern Campus CMS
                                                    application server, which is also the API
                                                    server. All Modern Campus CMS  API endpoints begin
                                                    with this value.
            token       A3xthrVCELk8XIaOEQKrIF      The authorization token provided to your gadget
                                                    for the current login session. Must be
                                                    submitted with every API call, in the
                                                    authorization_token parameter.
            gid         ae206856-114c-4124-b0f1     A generated ID that uniquely identifies your
                                                    gadget. This is used internally by the `fetch`
                                                    and `save` methods.
            place       sidebar                     Lets you know where in the Modern Campus CMS user
                                                    interface  the current instance of your gadget
                                                    is. This can be either 'dashboard' or
                                                    'sidebar'.
            skin        testdrives                  The name of the current Modern Campus CMS skin.
            account     Gallena_University          The name of the Modern Campus CMS account to which the
                                                    user is logged in.
            site        School_of_Medicine          The name of the site that is currently active
                                                    in Modern Campus CMS.
            user        jdoe                        The username of the logged-in Modern Campus CMS user.
            hostbase    /10/#skin/account/site      The starting fragment of all paths of pages in
                                                    the current Modern Campus CMS session. Use this to help
                                                    construct URLs to Modern Campus CMS pages that your
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
        };
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
                    console.log('Cannot parse message from Modern Campus CMS app:', message);
                    return;
                }
            }
            console.log('Response from Modern Campus CMS:', message);
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
                console.log('Cannot parse message from Modern Campus CMS app:', message);
                return;
            }
        }
        if (message.callback) {
            // the message listener in sendMessageToTop will handle this message
            return;
        }
        console.log('Message from Modern Campus CMS:', message);
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
            // A convenience method to get the gadget's configuration as stored in the Modern Campus CMS
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
            // back to the Modern Campus CMS database by calling /gadgets/configure.
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
            // Causes Modern Campus CMS to respond with information about the current file in Modern Campus CMS, if
            // the current view is file-specific.
            return sendMessageToTop('get-current-file-info');
        },
        oucInsertAtCursor: function (content) {
            // Causes Modern Campus CMS to insert the content at the cursor location in, and only in, a WYSIWYG
            // editor (such as JustEdit) and the source code editor.
            return sendMessageToTop('insert-at-cursor', content);
        },
        oucGetCurrentLocation: function () {
            // Causes Modern Campus CMS to respond with the app window's location info.
            return sendMessageToTop('get-location');
        },
        oucSetCurrentLocation: function (route) {
            /*
                Causes Modern Campus CMS to set the "route" of the Modern Campus CMS application. The route is the
                portion of the app's location that follows the sitename. For example, if the
                current app URL is
                
                "http://a.cms.omniupdate.com/10/#oucampus/gallena/art/browse/staging/about"
                
                then the route is "/browse/staging/about". Changing the route will effectively
                change the current Modern Campus CMS view, just as if the user had clicked a link within
                Modern Campus CMS.
                
                This method accepts a single string parameter, which is the new route. It should
                start with a slash. After the route has been changed, the method will respond with
                the new location.
            */
            return sendMessageToTop('set-location', route);
        },
        oucGetWYSIWYGSelection: function () {
            return sendMessageToTop('get-wysiwyg-selection');   
        },
        oucGetWYSIWYGContent: function () {
            return sendMessageToTop('get-wysiwyg-content'); 
        }
    };
    
    // bind all methods to the gadget object
    for (var method in gadget) {
        gadget[method] = gadget[method].bind(gadget);
    }
    
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
