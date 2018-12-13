var openTabs; //open tabs

$dtar = jQuery.noConflict();

$dtar(document).ready(function () {
    //set up openTabs
    openTabs = [];
    sforce.console.getSubtabIds(null, initTabs);
});

checkTabs = function() {
    //if this isn't new, check for closed tabs
    sforce.console.getSubtabIds(null, checkClosedTab);
}

//initial load of tabs
initTabs = function(result) {
    for(var i = 0; i < result.ids.length; i++) {
        openTabs.push(result.ids[i]);
    }
    setTimeout(checkTabs, 1000);
}

//check for any closed tabs
checkClosedTab = function(result) {
    //for each open tab
    for(var i = 0; i < openTabs.length; i++) {
        var found = false;
        //see if it's in the current tabs
        for(var j = 0; j < result.ids.length; j++) {
            if (openTabs[i] == result.ids[j]) {
                found = true;
                break;
            }
        }
        //if we didn't find it, it must have closed
        if (!found) {
            //refresh the main detail tab - tab 0
            sforce.console.refreshSubtabById(result.ids[0], false);
            break;
        }
    }

    //reinit open tabs
    openTabs = [];
    initTabs(result);
}