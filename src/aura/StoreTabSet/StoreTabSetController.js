({
    handleStore: function (cmp, event, helper) {
    	var storeTab       = cmp.find('storeTab');
        var historyTab     = cmp.find('historyTab');
    	var pointsTab      = cmp.find('pointsTab');
    	var storePanel     = cmp.find('storePanel');
        var historyPanel   = cmp.find('historyPanel');
    	var pointsPanel    = cmp.find('pointsPanel');
        $A.util.removeClass(historyTab,'slds-active');
    	$A.util.removeClass(pointsTab,'slds-active');
    	$A.util.addClass(storeTab,'slds-active');
    	$A.util.removeClass(historyPanel, 'slds-show');
    	$A.util.addClass(historyPanel, 'slds-hide');
        $A.util.removeClass(pointsPanel, 'slds-show');
        $A.util.addClass(pointsPanel, 'slds-hide');
    	$A.util.removeClass(storePanel, 'slds-hide');
    	$A.util.addClass(storePanel, 'slds-show');
    	var tab = 'store';
        helper.lazyLoadTabs(cmp, event, tab);
    },

    handleHistory: function (cmp, event, helper) {
    	var storeTab       = cmp.find('storeTab');
        var historyTab     = cmp.find('historyTab');
        var pointsTab      = cmp.find('pointsTab');
        var storePanel     = cmp.find('storePanel');
        var historyPanel   = cmp.find('historyPanel');
        var pointsPanel    = cmp.find('pointsPanel');
    	$A.util.removeClass(storeTab,'slds-active');
        $A.util.removeClass(pointsTab,'slds-active');
    	$A.util.addClass(historyTab,'slds-active');
    	$A.util.removeClass(storePanel, 'slds-show');
    	$A.util.addClass(storePanel, 'slds-hide');
        $A.util.removeClass(pointsPanel, 'slds-show');
        $A.util.addClass(pointsPanel, 'slds-hide');
    	$A.util.removeClass(historyPanel, 'slds-hide');
    	$A.util.addClass(historyPanel, 'slds-show');
    	var tab = 'history';
    	helper.lazyLoadTabs(cmp, event, tab);
    },

    handlePoints: function (cmp, event, helper) {
        var storeTab       = cmp.find('storeTab');
        var historyTab     = cmp.find('historyTab');
        var pointsTab      = cmp.find('pointsTab');
        var storePanel     = cmp.find('storePanel');
        var historyPanel   = cmp.find('historyPanel');
        var pointsPanel    = cmp.find('pointsPanel');
        $A.util.removeClass(storeTab,'slds-active');
        $A.util.removeClass(historyTab,'slds-active');
        $A.util.addClass(pointsTab,'slds-active');
        $A.util.removeClass(storePanel, 'slds-show');
        $A.util.addClass(storePanel, 'slds-hide');
        $A.util.removeClass(historyPanel, 'slds-show');
        $A.util.addClass(historyPanel, 'slds-hide');
        $A.util.removeClass(pointsPanel, 'slds-hide');
        $A.util.addClass(pointsPanel, 'slds-show');
        var tab = 'points';
        helper.lazyLoadTabs(cmp, event, tab);
    },
})