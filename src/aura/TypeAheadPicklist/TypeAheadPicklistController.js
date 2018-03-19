({
	typeAhead : function(component, event, helper)
   {
        var list = event.target.nextElementSibling.children;
        var text = event.target.value;
        for(var i = 0; i < list.length; i++)
        {
            if(event.target.value.length > 0)
            {
                console.log(event.target.value);
                var optionText = list[i].getAttribute('data-name');
                var lowerOptionText = optionText.toLowerCase();
                var lowerText = text.toLowerCase();
                var regex = new RegExp("^" + text, "i");
                var match = optionText.match(regex);
                var contains = lowerOptionText.indexOf(lowerText) != -1;
                if (match || contains) 
                { 
                    list[i].classList.remove('is-selected');
                    list[i].classList.remove('is-hidden');
                }
                else
                {
                    list[i].classList.add('is-hidden');
                    list[i].classList.remove('is-selected'); 
                }
            }
            else
            {
                list[i].classList.remove('is-selected');
                list[i].classList.remove('is-hidden');
                console.log("Length Zero");
            }
        }
        var filteredList = event.target.nextElementSibling.querySelectorAll('li.typeaheadlist:not(.is-hidden)');
        if(filteredList.length > 0 && event.target.value.length != 0)
            filteredList[0].classList.add('is-selected');
   },
   toggleSelectList : function(component, event, helper)
   {
        event.target.parentElement.parentElement.classList.toggle('slds-is-open');
        event.target.parentElement.nextElementSibling.firstChild.classList.toggle('slds-hide');
   },
   selectTask : function(component, event, helper)
   {
        event.target.parentElement.parentElement.parentElement.firstChild.firstChild.setAttribute("value",event.target.getAttribute("data-name"));
        event.target.parentElement.parentElement.parentElement.firstChild.firstChild.setAttribute("data-val",event.target.getAttribute("data-val"));
        event.target.parentElement.parentElement.parentElement.classList.remove('slds-is-open');
        event.target.parentElement.parentElement.firstChild.classList.add('slds-hide');
        //var selectedStory = event.target.getAttribute("data-val");
        //helper.onStorySelectChange(component, event, selectedStory);
   },
   fetchRecords : function(component, event, helper)
   {
   		var index = component.get("v.index");
   		var selectedStory = component.get("v.selectedStoryId");
        //var inputTextElem = document.getElementById("dropdownId"+index);
        //var taskListElem = document.getElementById("listId"+index);
        //inputTextElem.setAttribute("value", "");
        //inputTextElem.setAttribute("disabled", true);
        //taskListElem.innerHTML = "";

   		var action2 = component.get("c.getStoryTasks");
        action2.setParams({"storyId": selectedStory});
            action2.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state ==="SUCCESS"){
                if(response.getReturnValue().length > 0)
                {
                    component.set("v.storyTaskMap", response.getReturnValue());
                    //inputTextElem.removeAttribute("disabled");
                    //inputTextElem.setAttribute("readOnly", "readOnly");
                }
            }
        });
        $A.enqueueAction(action2);
   }
})