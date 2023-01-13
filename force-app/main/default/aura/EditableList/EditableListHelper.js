({
	doInit : function(component, event, helper) {
		helper.getTableFieldInfo(component, event, helper);
		helper.getCustomActions(component, event, helper);
	},
	getTableFieldInfo : function(component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setParams({
            childSobjectApi: component.get("v.childSobjectApi"),
            childSobjectNonEditFieldApis: component.get("v.childSobjectNonEditFieldApis"),
			childSobjectEditFieldApis: component.get("v.childSobjectEditFieldApis")
        });

        action.setCallback(this, function(response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            //Call helper method to fetch the records
            helper.getTableFilterFields(component, event, helper);
        })
        $A.enqueueAction(action);
    },
	getTableFilterFields : function(component, event, helper) {
        var action = component.get("c.getFilterFieldSet");
        action.setParams({
            childSobjectApi: component.get("v.childSobjectApi"),
            filterFieldApis: component.get("v.filterFieldApis")
        });

        action.setCallback(this, function(response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.filterFields", fieldSetObj);
            //Call helper method to fetch the records
            helper.getTableRows(component, event, helper);
        })
        $A.enqueueAction(action);
    },
	getTableRows : function(component, event, helper){
        var action = component.get("c.getTableRowValues");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();
		if(fieldSetValues != null){
			for(var c=0, clang=fieldSetValues.length; c<clang; c++){             
				if(!setfieldNames.has(fieldSetValues[c].name)) {                 
					setfieldNames.add(fieldSetValues[c].name);                   
					if(fieldSetValues[c].type == 'REFERENCE') {                     
						if(fieldSetValues[c].name.indexOf('__c') == -1) {                     	
							setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('Id')) + '.Name');                          
						}                     
						else {                     	
							setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.Name');                              
						}                 
					}             
				}         
			}         
		}
		var arrfieldNames = [];         
		setfieldNames.forEach(v => arrfieldNames.push(v));

        console.log(arrfieldNames);
        action.setParams({
            recordId: component.get("v.recordId"),
            relationshipFieldApi: component.get("v.relationshipFieldApi"),
			parentSobjectApi: component.get("v.parentSobjectApi"),
			childSobjectApi: component.get("v.childSobjectApi"),
            fieldNameJson: JSON.stringify(arrfieldNames),
			fieldFilters: JSON.stringify(component.get("v.filterFields")),
            limitVal: component.get("v.limit"),
			sortByFirst: component.get("v.sortByFirst"),
			sortBySecond: component.get("v.sortBySecond"),
			sortOrderVal: component.get("v.sortOrder"),
			extraFilters: component.get("v.extraFilters")
        });
        action.setCallback(this, function(response) {
			var returnVals = response.getReturnValue();
			if(returnVals != null && returnVals.length != 0){
                var count = 0;
                var aMap = {};
                var i,j,chunk = component.get("v.pageSize");
                for (i=0,j=returnVals.length; i<j; i+=chunk) {
                    var temparray = returnVals.slice(i,i+chunk);
                    aMap[count] = aMap[count] || [];
                    aMap[count] = temparray.slice();
                    count++;
                }
                
                console.log(count);
				var firstPage = [];
                firstPage = aMap['0'].slice();
                component.set("v.resultValsMap", aMap);
                component.set("v.tableRecords", firstPage);
                component.set("v.tableRecordsAll", returnVals);
                component.set("v.countVar", 0);
                component.set("v.getResults", false);
                if(count>1){
                	component.set("v.maxPage", count-1);
                    component.set("v.min", true);
                }
                else{
                    component.set("v.maxPage", count-1);
                    component.set("v.min", true);
                    component.set("v.max", true);
                }
                
                component.set("v.totalCount", returnVals.length);
                    
                component.find('notifLib').showToast({
                    "title": "",
                    "type": "success",
                    "message": "Loading Complete"
                });
                
            }
            else{
                var count = 0;
                var aMap = {};
                component.set("v.resultValsMap", aMap);
                component.set("v.tableRecords", []);
                component.set("v.tableRecordsAll", []);
                component.set("v.countVar", 0);
                component.set("v.getResults", false);
                if(count>1){
                	component.set("v.maxPage", 0);
                    component.set("v.min", true);
                }
                else{
                    component.set("v.maxPage", 0);
                    component.set("v.min", true);
                    component.set("v.max", true);
                }
                
                component.set("v.totalCount", 0);
                    
                component.find('notifLib').showToast({
                    "title": "",
                    "type": "success",
                    "message": "Loading Complete"
                });
            }
            //component.set("v.tableRecords", response.getReturnValue());
        })
        $A.enqueueAction(action);
    },
	deleteRecordHelper: function(component, event, helper) {
		var action = component.get("c.deleteServerAction");
        action.setParams({
            recordId : event.getSource().get("v.value"),
			childSobjectApi: component.get("v.childSobjectApi")
        });

        action.setCallback(this, function(response) {
            var returnVal = response.getReturnValue();
            component.find('notifLib').showToast({
				"message": returnVal,
				"mode": "pester"
			});
			if(!returnVal.includes("ERROR:")){
				helper.getTableFieldInfo(component, event, helper);
			}
        })
        $A.enqueueAction(action);
    },
	getCustomActions : function(component, event, helper) {
        var action = component.get("c.getCustomActions");
        action.setParams({
            customActionNames: component.get("v.includedCustomActions")
        });

        action.setCallback(this, function(response) {
            var fieldReturnObj = response.getReturnValue();
            component.set("v.customActions", fieldReturnObj);
        })
        $A.enqueueAction(action);
    }
})