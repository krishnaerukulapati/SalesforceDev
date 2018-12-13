/****************************************************************
* this handles loading of pages of data using remote actions
* requires a remote action with a signature like:
* ConstituentId, Start Record Count, End Record Count
****************************************************************/
var C360PageLoader = function (options) {
    var totRes = 0;
    var retrieved = 0;
    var bufferSize = 100;
    var consId = options.constituentId;
    var remoteAction = options.remoteAction;
    var objectName = options.objectName;
    var pags = new Array();

    if (objectName === undefined) objectName = "Interactions";

    //callbacks
    var completeFunction = options.onComplete;
    var pageFunction = options.onPageComplete;
    var errorFunction = options.onError;

    //private methods - can't apparently access publicish properties
    function getPage() {
        try {
            Visualforce.remoting.Manager.invokeAction(
                remoteAction, //method
                consId, retrieved + 1, retrieved + bufferSize, //parms
                processPage);
        }
        catch (err) {
            if (errorFunction !== undefined) errorFunction(err);
        }
    }

    function processPage(result, event) {
        if (result != null && result[objectName] != null) {
            if (totRes == 0) totRes = result.TotalResults;
            for(var i = 0; i < result[objectName].length; i++) {
            	pags.push(result[objectName][i]);
            }
            retrieved += bufferSize;
            if (totRes > retrieved) {
            	if (pageFunction !== undefined)
	            	pageFunction(retrieved, totRes, result);
                getPage();
            }
            else {
            	if (completeFunction !== undefined)
            		completeFunction(retrieved, totRes, pags);
            }
        }
        else {
            if (completeFunction !== undefined)
                completeFunction(retrieved, totRes, pags);
        }
    }

    //public or privelaged methods?
    this.pages = function () {return pags};
    this.constituentId = function () {return consId};
	this.getPages = function() {
	    getPage();
	};
};

var c360PageLoaders = {};