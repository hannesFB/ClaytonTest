({
	fetchPickListVal: function(component) {
        var action = component.get("c.getSelectOptions");
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": component.get("v.fieldAPI")
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                console.log("got list");
                var allValues = response.getReturnValue();
                if(allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "",
                        value: ""
                    });
                }
                for(var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.set("v.options", opts);
            }
            else {
                console.log("failed get list");
            }
        });
        $A.enqueueAction(action);
    }
})