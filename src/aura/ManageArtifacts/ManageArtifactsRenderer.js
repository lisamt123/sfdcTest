({
	afterRender : function(component, helper){
   		this.superAfterRender();
        var scroll = document.getElementById('outerDiv');
        var prevLeft = 0;
        scroll.onscroll = function(ev) {

            var currentLeft = scroll.scrollLeft;
            if(prevLeft != currentLeft) {
                prevLeft = currentLeft;
            }
            else {
                var total = scroll.scrollTop + scroll.clientHeight;
                if(Math.ceil(total) >= document.getElementById('innerDiv').clientHeight) {
                    helper.removeHide(component);
                    component.find("searchInText2").set("v.value",'');
                    var artifactsTypeVar = component.find("ArtifactsType");
                    component.set("v.selectedMetadata", artifactsTypeVar.get("v.value"));
                    var selconnectionsVar = component.find("Connections");
                    helper.refreshConnectHelper(component, selconnectionsVar.get("v.value"),helper);
                } 
            }
        }
        window.onresize = function(event) {
            if(document.getElementById('fixHeaderDiv') != null && typeof document.getElementById('fixHeaderDiv') != 'undefined')
                document.getElementById('fixHeaderDiv').style.width = document.getElementById('innerDiv').clientWidth+'px';
            if(document.getElementById('fixHeaderDiv2') != null && typeof document.getElementById('fixHeaderDiv2') != 'undefined')
                document.getElementById('fixHeaderDiv2').style.width = document.getElementById('selectedContainer').clientWidth+'px';
        }
    },
    rerender : function(component, helper) {
        this.superRerender();
        document.getElementById('fixHeaderDiv').style.width = document.getElementById('innerDiv').clientWidth+'px';
        document.getElementById('fixHeaderDiv2').style.width = document.getElementById('selectedContainer').clientWidth+'px';

        if(component.get('v.flag')) {
            var divHeight = (document.getElementById("modal-content-id-1").offsetHeight - 210) + 'px';
            document.getElementsByClassName("artifactsListContainer")[0].style.height = divHeight;
            document.getElementsByClassName("artifactsListContainer")[1].style.height = divHeight;
            component.set('v.flag',false);
        }
    }
})