({
	// Your renderer method overrides go here
	afterRender : function(component, helper) {
   		this.superAfterRender();
        var scroll = document.getElementById('artifactsListContainer2');
        var prevLeft = 0;
        scroll.onscroll = function(ev) {

            var currentLeft = scroll.scrollLeft;
            if(prevLeft != currentLeft) {
                prevLeft = currentLeft;
            }
            else {
                var total = scroll.scrollTop + scroll.clientHeight;
                if(Math.ceil(total) >= document.getElementById('innerDiv').clientHeight) {
                    helper.retriveScanLogIssues(component,helper);
                } 
            }
        }
        setTimeout(function() {
            document.getElementById("artifactsListContainer2").style.height = (document.getElementById("modal-content-id-2").offsetHeight - 40) + 'px';
            document.getElementById('fixHeaderDiv2').style.width            = document.getElementById('artifactsListContainer2').clientWidth+'px';
        },100);
        window.onresize = function(event) {
            if(document.getElementById('artifactsListContainer2') != null && typeof document.getElementById('artifactsListContainer2') != 'undefined')
                document.getElementById("artifactsListContainer2").style.height = (document.getElementById("modal-content-id-2").offsetHeight - 40) + 'px';
        	if(document.getElementById('fixHeaderDiv2') != null && typeof document.getElementById('fixHeaderDiv2') != 'undefined')
               document.getElementById('fixHeaderDiv2').style.width = document.getElementById('artifactsListContainer2').clientWidth+'px';
        }
    },
})