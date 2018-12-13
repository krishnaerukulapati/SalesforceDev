var url; //url to open in subtab
var title; //title of subtab
var label; //label of subtab?
var focusTabId;
var refreshFocusTabId;

/**********************************************
 * Opens a subtab
 * *******************************************/
//Opens a subtab in the console
function openSubtabC360(pUrl, pTitle, pLabel) {
    url = pUrl;
    title = pTitle;
    label = pLabel;
    //First find the ID of the primary tab to put the new subtab in
    sforce.console.getEnclosingPrimaryTabId(openSubtab);
}

//openSubTab async callback
var openSubtab = function openSubtab(result) {
    //Now that we have the primary tab ID, we can open a new subtab in it
    var primaryTabId = result.id;
    sforce.console.openSubtab(primaryTabId , url, true,
                              title, null, null, label);
};

/**********************************************
 * Refresh a primary tab
 * *******************************************/
//refreshes the highlights panel and subtabs
var refreshPage = function refreshPage(results) {
    sforce.console.closeTab(results.message); //, reLoadPage);
    refreshPrimaryTab();
}

function refreshPrimaryTab() {
    //First find the ID of the current primary tab to close it
    sforce.console.getEnclosingPrimaryTabId(RefreshPrimaryTabById);
}

function RefreshPrimaryTabById(result) {
    //Get the value for 'scc-pt-0' from the openPrimaryTab method
    //This value is for example purposes only
    sforce.console.refreshPrimaryTabById(result.id, true);
}

/********************************************
 * Open a new primary tab
 *******************************************/

var openPrimaryTab = function openPrimaryTab(url) {
    sforce.console.openPrimaryTab(null, url, true);
}

/****************************************
 * refresh tab in focus
 * *************************************/
function refreshFocusTab() {
    sforce.console.getFocusedPrimaryTabId(refreshGetFocusTab);
}

function refreshGetFocusTab(result) {
    refreshocusTabId = result.id;
    sforce.console.getEnclosingPrimaryTabId(refreshPrimaryTabFocus);
}

function refreshPrimaryTabFocus(result) {
    if (result.id == refreshocusTabId) {
       /* if (typeof reLoadPage === 'function') {
            reLoadPage();
        }
        else {
            location.assign(location.href + "&reload=true");
        } */

        location.assign(location.href + "&reload=true");
        //sforce.console.getSubtabIds(result.id, subTabRefresh);
    }
}

function subTabRefresh(result) {
    sforce.console.refreshSubtabById(result.ids[0], false, subTabRefreshed);
    //location.reload();
}

function subTabRefreshed(result) {
    //alert(result.ids);
    //href
    location.assign(location.href + "&reload=true");
    //location.reload();
}

/*******************************************
 * event listeners
 * ****************************************/
//constituent selected
var addConstApplListen = function addEventListener() {
    sforce.console.addEventListener("ConstituentApplied", refreshPage);
}

//if profile is edited
var addConstEditListen = function addEventListener() {
    sforce.console.addEventListener( "ProfileEdited", refreshFocusTab );
}

//if bbc is opened?
var addBBECListen = function addEventListener() {
    sforce.console.addEventListener( "OpenBBEC", OpenBBEC );
}

//apply the listeners
var prevOnLoad = window.onload;
window.onload = function() {
    if (prevOnLoad) {
        prevOnLoad();
    }
    addConstApplListen();
    addConstEditListen();
    addBBECListen();
}

/************************************************
 * open bbec
 * *********************************************/
//Opens BBEC in new window - requires a field called hdnBbecId
var bbecTabId = null;

function OpenBBEC(tabId)
{
    if (tabId !== null) {
        bbecTabId = tabId;
    }
    sforce.console.getFocusedPrimaryTabId(OpenBBECFocusTab);
}

function OpenBBECFocusTab(result) {
    focusTabId = result.id;
    sforce.console.getEnclosingPrimaryTabId(OpenBBECPrimTab);
}

function OpenBBECPrimTab(result) {
    if (result.id == focusTabId) {
        var bbecId = document.getElementById("hdnBbecId").value;
        if (bbecId != "") {
            var url = bbecUrl + bbecId;
            if (bbecTabId !== null) {
                url += "&tabId=" + bbecTabId;
            }
            var win=window.open(url, '_blank');
            win.focus();
        }
        else alert('No DMS Constituent Found');
    }
}