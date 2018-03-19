({
    updateDivHeight : function(component) {
        var divHeight = (document.getElementById("modal-content-id-1").offsetHeight - 40);
        if( divHeight > 350)
            component.set('v.divHeight',divHeight);
        component.set('v.divWidth',document.getElementById('artifactsListContainer2').clientWidth);
    }
})