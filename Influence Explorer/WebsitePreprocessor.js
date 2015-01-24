var WebsitePreprocessor = function() {};

WebsitePreprocessor.prototype = {
    run: function(arguments) {
        arguments.completionFunction({"baseURI" : document.baseURI});
    }
}

var ExtensionPreprocessingJS = new WebsitePreprocessor;