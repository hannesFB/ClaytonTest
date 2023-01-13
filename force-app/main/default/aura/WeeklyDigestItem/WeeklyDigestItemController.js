({
	handleClick: function (component, event, helper) {
		alert("would normally link to article provided by dataset EX:" + component.get('v.LearnMore'));
		/*var urlEvent = $A.get("e.force:navigateToURL");
			urlEvent.setParams({
			  "url": Component.get('v.LearnMore')
			});
			urlEvent.fire();*/
	}
})