({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
	setLoading : function(component, event, helper) {
		component.set("v.Spinner", true);
		window.setTimeout(
			$A.getCallback(function() {
				component.set("v.Spinner", false);
			}), 2000
		);
	},
	toggleSection : function(component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
	handleClick : function(component, event, helper) {
		helper.getTableRows(component, event, helper);
	},
	onclicksave:function(component, event, helper){
		component.set("v.Spinner", true);
		window.setTimeout(
			$A.getCallback(function() {
				component.set("v.Spinner", false);
			}), 2000
		);
		var editedRecordList = component.find("editForm");
        for(var i = 0 ; i < editedRecordList.length ; i++){
            editedRecordList[i].submit();
        }
	},
	handleDeleteRecord: function(component, event, helper) {
		helper.deleteRecordHelper(component, event, helper);
    },
	handleEditRecord: function(component, event, helper) {
		var editRecordEvent = $A.get("e.force:editRecord");
		editRecordEvent.setParams({
			 "recordId": event.getSource().get("v.value")
	   });
		editRecordEvent.fire();
    },
	customActionEx : function(component, event, helper) {
		var action = component.get("c.triggerCustomAction");
        action.setParams({
            customActionName : event.getSource().get("v.value"),
			recordId: component.get("v.recordId"),
        });

        action.setCallback(this, function(response) {
            var returnVal = response.getReturnValue();
            component.find('notifLib').showToast({
				"message": returnVal,
				"mode": "pester"
			});
			if(returnVal.includes("Successfully")){
				helper.getTableRows(component, event, helper);
			}
        })
        $A.enqueueAction(action);
	},
    customFormActionEx : function(component, event, helper) {
		var action = component.get("c.triggerCustomFormAction");
        action.setParams({
            customActionName : event.getSource().get("v.value"),
			recordId: component.get("v.recordId"),
        });

        action.setCallback(this, function(response) {
            var returnVal = response.getReturnValue();
            component.find('notifLib').showToast({
				"message": returnVal,
				"mode": "pester"
			});
            component.set("v.customFormAction", returnVal);
            component.set("v.isOpen", true);
        })
        $A.enqueueAction(action);
	},
    handleOnSuccess : function(component, event, helper) {
        var record = event.getParam("response");
        component.find("notifLib").showToast({
            "title": "Saved",
            "message": "Record Saved!"
        });
    },
    handleOnError : function(component, event, helper) {
        var record = event.getParam("output");
		console.log(record);
        component.find("notifLib").showToast({
            "title": "Error",
            "message": "There was an error saving. {0} {1} " + record
        });
    },
    closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
   	},
    afterSub : function(component, event, helper) {
        helper.getTableRows(component, event, helper);
        component.set("v.isOpen", false);
    },
	nextPage : function(component, event, helper){
    	var currentPage = component.get("v.countVar");
        var currentCount = component.get("v.maxPage");
        var allRecords = component.get("v.resultValsMap");
        
        
        currentPage++;
        var nextPage = [];
        if(currentPage == currentCount){
            component.set("v.max", true);
            nextPage = allRecords[currentPage].slice();
        }
        else{
            nextPage = allRecords[currentPage].slice();
        }
        
        component.set("v.min", false);
        component.set("v.tableRecords", nextPage);
        component.set("v.countVar", currentPage);
	},
    backPage : function(component, event, helper){
    	var currentPage = component.get("v.countVar");
        var currentCount = component.get("v.maxPage");
        var allRecords = component.get("v.resultValsMap");
        
        currentPage--;
        var nextPage = [];
        if(currentPage == 0){
            component.set("v.min", true);
            nextPage = allRecords[currentPage].slice();
        }
        else{
            nextPage = allRecords[currentPage].slice();
        }
        
        component.set("v.max", false);
        component.set("v.tableRecords", nextPage);
        component.set("v.countVar", currentPage);
	}
})