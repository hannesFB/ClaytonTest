({
	doInit : function(component, event, helper) {
		var subData = [
			{ cellType: 'header', label: 'Type', value: '', currentSort: 'asc', modified: '' },
			{ cellType: 'header', label: 'Points', value: '', currentSort: 'asc', modified: '' },
			{ cellType: 'header', label: 'Date', value: '', currentSort: 'asc', modified: '' },
			{ cellType: 'data', label: 'data1', value: {Type: 'Phone Call', Points: '10', Date: 'Jan 12'}, currentSort: 'asc', modified: '', expand: false, subValue: '' },
			{ cellType: 'data', label: 'data1', value: {Type: 'Email', Points: '12', Date: 'Dec 10'}, currentSort: 'asc', modified: '', expand: false, subValue: '' }
		];

		var subData2 = [
			{ cellType: 'header', label: 'Type', value: '', currentSort: 'asc', modified: '' },
			{ cellType: 'header', label: 'Points', value: '', currentSort: 'asc', modified: '' },
			{ cellType: 'header', label: 'Date', value: '', currentSort: 'asc', modified: '' },
			{ cellType: 'data', label: 'data1', value: {Type: 'Email', Points: '50', Date: 'Jan 18'}, currentSort: 'asc', modified: '', expand: false, subValue: '' },
			{ cellType: 'data', label: 'data1', value: {Type: 'Email', Points: '79', Date: 'Dec 12'}, currentSort: 'asc', modified: '', expand: false, subValue: '' }
		];

		var cells = [
			{ cellType: 'header', label: 'Name', value: '', currentSort: 'asc', modified: '' },
			{ cellType: 'header', label: 'Relationship', value: '', currentSort: 'asc', modified: '' },
			{ cellType: 'header', label: 'Actions', value: '', currentSort: 'asc', modified: '' },
			{ cellType: 'data', label: 'data1', value: {Name: 'Jane Doe', Relationship: '86', Actions: 'Request Intro'}, currentSort: 'asc', modified: '', expand: false, subValue: subData },
			{ cellType: 'data', label: 'data1', value: {Name: 'Jane Doe', Relationship: '86', Actions: 'Request Intro'}, currentSort: 'asc', modified: '', expand: false, subValue: subData2 }
		];

		component.set("v.cells",cells);
	},
	clickHandler : function(component, event, helper) {
		var myLabel = event.getSource().get("v.value");
        event.getSource().set("v.value", !myLabel);
	}
})