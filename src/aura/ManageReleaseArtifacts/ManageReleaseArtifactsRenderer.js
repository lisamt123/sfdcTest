({
    afterRender : function(component,helper){
        this.superAfterRender();
        window.onresize = function(event)  {
            helper.fixHeaderWidth();
        }
    },
    rerender : function(component, helper) {
        this.superRerender();
        setTimeout(function(){ 
            if(component.get("v.cssString").trim() == '') {
                var compHeight      = document.getElementById("slds-modal__container").offsetHeight;
                var reducedHeight   = component.get('v.addMetadata') ? compHeight - 540 : compHeight - 467 ;
                if(reducedHeight > 250)
                    component.set("v.cssString",'height: ' + reducedHeight + 'px !important;');
                else
                    component.set("v.cssString",'height: 250px !important;');
            }
            helper.fixHeaderWidth();
            var cols = document.getElementsByClassName('artifactsListContainer');
            for(count = 0; count < cols.length; count++) {
                cols[count].style.cssText = component.get("v.cssString") ;
            }
        }, 100);
    }
})