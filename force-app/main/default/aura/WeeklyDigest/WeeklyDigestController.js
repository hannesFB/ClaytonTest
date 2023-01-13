({
	myAction: function (component, event, helper) {

	},
	doInit: function(component, event, helper) {
		var gpAr = [
			{
				Name : 'Accounting',
				Id : '',
				selected:true
			},
			{
				Name : 'Alumns',
				Id : '',
				selected:true
			},
			{
				Name : 'Deans Office',
				Id : '',
				selected:false,
			},
			{
				Name : 'Students',
				Id : '',
				selected:false
			}
		];

		var gpAr2 = [
			{
				Name : 'Accounting',
				Id : '',
				selected:false
			},
			{
				Name : 'Alumns',
				Id : '',
				selected:false
			},
			{
				Name : 'Deans Office',
				Id : '',
				selected:true,
			},
			{
				Name : 'Students',
				Id : '',
				selected:true
			}
		];

		var catDE = {
				enabled : true,
				disabled : false
			};

		var catDE2 = {
				enabled : false,
				disabled : true
			};

		var listA = [
			{
				title : 'Announcement Here 1',
				bodyStr : 'Summary Here or a truncated chunk of the body. Some more stuff to fill space.',
				link : '/some/link',
				time : '',
				remove : false,
				groups : JSON.stringify(gpAr),
				enable : JSON.stringify(catDE),
				disableArticle : false
			},
			{
				title : 'Announcement Here 2',
				bodyStr : 'Summary Here or a truncated chunk of the body. Some more stuff to fill space.',
				link : '/some/link',
				time : '',
				remove : true,
				groups : JSON.stringify(gpAr2),
				enable : JSON.stringify(catDE2),
				disableArticle : true
			}
		];

		var listD = [
			{
				title : 'Deadline to Submit Application',
				bodyStr : 'Summary Here or a truncated chunk of the body. Some more stuff to fill space.',
				link : '/some/link',
				time : 'Mon, Mar 24, 11:30 AM',
				remove : false,
				groups : JSON.stringify(gpAr2),
				enable : JSON.stringify(catDE),
				disableArticle : false
			}
		];

		var listE = [
			{
				title : 'Event Name Here',
				bodyStr : 'Summary Here or a truncated chunk of the body. Some more stuff to fill space.',
				link : '/some/link',
				time : 'Mon, Mar 24, 11:30 AM',
				remove : false,
				groups : JSON.stringify(gpAr),
				enable : JSON.stringify(catDE),
				disableArticle : false
			}
		];

		var listAr = [
			{
				title : 'Article Name Here',
				bodyStr : 'Summary Here or a truncated chunk of the body. Some more stuff to fill space.',
				link : '/some/link',
				time : 'Mon, Mar 24, 11:30 AM',
				remove : false,
				groups : JSON.stringify(gpAr2),
				enable : JSON.stringify(catDE),
				disableArticle : false
			}
		];

		/*var gpAr = [
			{
				Name : 'Accounting',
				Id : '',
				selected:false
			},
			{
				Name : 'Alumns',
				Id : '',
				selected:false
			},
			{
				Name : 'Deans Office',
				Id : '',
				selected:false,
			},
			{
				Name : 'Students',
				Id : '',
				selected:false
			}
		];

		component.set("v.GroupList", gpAr);*/
        component.set("v.AnnouncmentsItems", listA);
		component.set("v.DeadlinesItems", listD);
		component.set("v.UpcomingEventsItems", listE);
		component.set("v.ArticlesItems", listAr);
    },
    dragstart: function(component, event, helper) {
        component.set("v.dragid", event.target.dataset.dragId);
    },
    drop: function(component, event, helper) {
        var dragId = component.get("v.dragid"),
            values = component.get("v.values"),
            temp;
        temp = values[dragId];
        values[dragId] = values[event.target.dataset.dragId];
        values[event.target.dataset.dragId] = temp;
        component.set("v.values", values);
        event.preventDefault();
    },
    cancel: function(component, event, helper) {
        event.preventDefault();
    },
	setVal: function(component, event, helper) {
		var grpValue = JSON.parse(event.currentTarget.dataset.items);
		var grpdisableArticle = event.currentTarget.dataset.items2;
		var grpdisEne = JSON.parse(event.currentTarget.dataset.items3);

		component.set('v.GroupList', grpValue);
		component.set('v.DisableArticle', grpdisableArticle);
		component.set('v.DisableEnableCat', grpdisEne.enabled);
		component.set('v.DisableDisableCat', grpdisEne.disabled);
		component.set('v.ShowArticleInfo', true);
	}
})