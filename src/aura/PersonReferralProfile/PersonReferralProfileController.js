({
	doInit : function (component, event, helper) { 
        console.log("Referral List doInit");
        var recID = window.location.pathname.split('/profile/')[1];
        helper.getReferralRecords (component,recID);
        helper.validateCurrentUser(component, event);
    },
    simulateTweetClick : function (component, event, helper){
    	var tweetRefURL = component.get("v.refwrap");
    	var refCode = (tweetRefURL.refUrl).substr((tweetRefURL.refUrl).length - 6);
        var tweetMessage = encodeURIComponent(tweetRefURL.tweetMsg);
        var tweetURL = encodeURIComponent(tweetRefURL.tweetURL);
    	window.open('https://twitter.com/intent/tweet?text='+tweetMessage+' '+tweetURL+refCode);
    },
    simulateFacebookClick : function (component, event, helper){
    	var faceRefURL = component.get("v.refwrap");
    	var refCode = (faceRefURL.refUrl).substr((faceRefURL.refUrl).length - 6);
        var facebookURL = encodeURIComponent(faceRefURL.facebookURL);
    	window.open('https://www.facebook.com/dialog/share?app_id=896818917135138&href='+facebookURL+refCode+'&display=popup&redirect_uri=http%3A%2F%2Fwww.facebook.com%2F');
    },
    simulateLinkedInClick : function (component, event, helper){
    	var linkRefURL = component.get("v.refwrap");
    	var refCode = (linkRefURL.refUrl).substr((linkRefURL.refUrl).length - 6);
        var linkMessage = encodeURIComponent(linkRefURL.linkedInMsg);
        var linkedInURL = encodeURIComponent(linkRefURL.linkedInURL);
    	window.open('https://www.linkedin.com/shareArticle?url='+linkedInURL+refCode+'&text='+linkMessage+' '+linkedInURL+refCode+'&mention=1&title=10K%20Community');
    },
})