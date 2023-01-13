({
	doInit: function(component, event, helper) {
        helper.fetchPickListVal(component);
    },
    onPicklistChange: function(component, event, helper) {
        // get the value of select option
        component.set("v.selected", event.getSource().get("v.value"));
        console.log(component.get("v.selected"));
        var evt = $A.get("e.c:SelectListEvent");
        evt.setParams({"optionByEvent": component.get("v.selected")});
        evt.fire();
    }
})