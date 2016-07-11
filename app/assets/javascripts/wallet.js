var citrusWallet = (function() {
    var configObj;
    var requiredKeysArr;
    var allowedKeysArr;
    var iframeRef;
    //IE8 indexOf fix
    if (!Array.prototype.indexOf) {
        Array.prototype.indexOf = function(obj, start) {
            for (var i = (start || 0), j = this.length; i < j; i++) {
                if (this[i] === obj) { return i; }
            }
            return -1;
        }
    }

    var validationMap = {
        amount: {
            required: true,
            validator: function(val){
                return regexValidator(val, 'is not valid amount', /^\d+(\.\d+)?$/)
            }
        },
        currency: {
            required: true,
            validator: checkStr
        },
        email: {
            required: false,
            validator: function(val){
                return true;
            }
        },
        mobile: {
            required: false,
            validator: function(val){
                return true;
            }
        },
        returnUrl : {
            required: true,
            validator: function(val){
                return regexValidator(val, 'is not a valid url', /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/);
            }
        },
        notifyUrl : {
            required: true,
            validator: function(val){
                if(val !=""){
                    return regexValidator(val, 'is not a valid url', /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/);
                }else{
                    return true;
                }
            }
        },
        merchantTransactionId: {
            required: true,
            validator: checkStr
        },
        merchantAccessKey: {
            required: true,
            validator: checkStr
        },
        signature: {
            required: true,
            validator: checkStr
        }
    };


    function validate(confObj){

        if(typeof  confObj !== 'object') return 'argument should be an object';

        var errMsg = [];
        var newConfigObj = {};
        var allowedKeys = allowedKeysArr || findKeys(validationMap).allowedKeys;
        var requiredKeys = requiredKeysArr || findKeys(validationMap).requiredkKeys;

        for(var it=0, len = requiredKeys.length; it < len; it++){
            var el = requiredKeys[it];
            if(confObj[el] === undefined || confObj[el] === null){
                errMsg.push('"'+ el + '" is a required field');
            }
        }

        for(var key in confObj){
            if(confObj.hasOwnProperty(key)){
                var val = confObj[key];
                if(allowedKeys.indexOf(key) < 0){
                    //pass extra/custom params to server as it is.
                    //should not be array or object
                    newConfigObj[key] = val;
                    //errMsg.push( '"' + key + '" field should not be present');
                }else{
                    var validationObj = validationMap[key];

                    var validationResult = validationObj.validator(val);
                    if(validationResult.valid === false){
                        errMsg.push('"' +  key + '" ' + validationResult.msg);
                    }else {
                        newConfigObj[key]  =  validationResult.newVal ? validationResult.newVal : val;
                    }
                }

            }
        }

        return errMsg.length ? errMsg.join('. '): newConfigObj;

    };

    function findKeys(obj){
        var retObj ={
            allowedKeys: [],
            requiredKeys: []
        };

        for(var key in obj){
            if(obj.hasOwnProperty(key)){
                retObj.allowedKeys.push(key);
                if(obj[key].required === true) retObj.requiredKeys.push(key);
            }
        }

        requiredKeysArr = retObj.requiredKeys;
        allowedKeysArr = retObj.allowedKeys;
        return retObj;
    };

    function checkStr(val){
        var bool = isString(val) && val !== '';
        var retObj = {
            valid : bool
        };
        if(!bool) retObj.msg = "not a string";
        return retObj
    };

    function isString(val){
        return typeof val === 'string' || val instanceof String
    };

    function isNumeric(n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
    }
    function isBoolean(val) {
        return typeof val === 'boolean' || val instanceof Boolean
    }
    function regexValidator(val, msg, regEx){
        var valid = regEx.test(val);
        var retObj = {
            valid: valid
        };
        !valid ? retObj.msg = msg : '';
        return retObj;
    };




    function launchWallet(dataObj, confObj){

        confObj && (configObj = confObj);
        var url = confObj && confObj.walletUrl || "https://wallet.citruspay.com/wallet/showlogin";

        //validate returns either error string or config object as per server
        var walletConf = validate(dataObj);

        if(typeof walletConf === 'string'){
            throw new Error(walletConf);
        }

        var formTarget;

        if(screen.width < 751){ //mobile
            formTarget = '_parent';
        }else{ //desktop
            var citrusIframe = document.createElement("iframe");
            iframeRef = citrusIframe;
            //citrusIframe.id = 'walletIframeId';
            citrusIframe.name = 'walletIframeName';
            citrusIframe.setAttribute("style", "display:block;position:fixed;width:100%;height:100%;height:100vh;left:0;top:0;z-index:10000;overflow:hidden;");
            citrusIframe.setAttribute('allowtransparency', 'true');
            document.getElementsByTagName("body")[0].appendChild(citrusIframe);
            //document.getElementById('walletIframeId').src = URL;
            formTarget = 'walletIframeName';
        }

        var f = document.createElement("form");
        //f.setAttribute('name', 'ctrswalletForm');
        //f.setAttribute('id', 'ctrswalletFormId');
        f.setAttribute('method',"POST");
        f.setAttribute('action', url);
        f.setAttribute('target',formTarget);


        for(var key in walletConf){
            if(walletConf.hasOwnProperty(key)){

                var val = walletConf[key];

                if(typeof val === 'object'){

                    for(var keyName in val){
                        var name = key + '[' + keyName +']';
                        var i = document.createElement("input"); //input element, text
                        i.setAttribute('type',"hidden");
                        i.setAttribute('name', name);
                        i.setAttribute('value',val[keyName]);
                        f.appendChild(i);
                    }

                }else{
                    var i = document.createElement("input"); //input element, text
                    i.setAttribute('type',"hidden");
                    i.setAttribute('name', key);
                    i.setAttribute('value',val);
                    f.appendChild(i);
                }


            }
        };

        document.body.appendChild(f);
        f.submit();
    };


    var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
    var eventer = window[eventMethod];
    var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";

    // Listen to message from child window
    eventer(messageEvent, function(e) {
        var key = e.message ? "message" : "data";
        var data = e[key];
        //walletLaunchHandler is for backward compatibility of api
        var eventHandler =  configObj && (configObj.eventHandler || configObj.walletLaunchHandler);
        if (data == 'closeWallet') {
            //var close = document.getElementById("walletIframeId");
            iframeRef.parentNode.removeChild(iframeRef);
            eventHandler && eventHandler({
                message: 'Citrus wallet Closed',
                event: 'walletClosed'
            });
        } else if (data === 'citrusWalletLaunched') {
            eventHandler && eventHandler({
                message: 'Citrus wallet launched',
                event: 'walletLaunched'
            });
        }
        if (typeof data === 'object') {
            eventHandler && eventHandler({
                message: 'Citrus wallet Closed',
                event: data
            });
        }
    }, false);


    return {
        launchWallet: launchWallet,
        version: "1.6-31.3.16"
    };
})();