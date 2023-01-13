@isTest 
private class EditableListControllerTest {

	@isTest
	private static void testName() {
		Account a = new Account(Name = 'Test Account');
		insert a;

		Opportunity o = new Opportunity(Name = 'Test Opp', StageName = 'Prospect', CloseDate = System.today(), AccountId = a.Id);
		insert o;

		String fieldNameJson = EditableListController.getFieldSet('Opportunity', 'Name,StageName', 'Description');
		String fielNameString = '["Name","StageName","Description","CloseDate","Type","IsPrivate"]';
		String filterField = EditableListController.getFilterFieldSet('Opportunity', 'Name,StageName,CloseDate,IsPrivate');

		List<sObject> tableRows = EditableListController.getTableRowValues(a.Id, 'AccountId', 'Account', 'Opportunity', fielNameString, filterField, '60', '', '', '','');

		System.assertEquals(1, tableRows.size());
	}

	@isTest
	private static void testWithFilters() {
        
        CustomActionModel.Fields cam = new CustomActionModel.Fields();
        cam.name = 'test';
        cam.value = 'test';
        
		Account a = new Account(Name = 'Test Account');
		insert a;

		Opportunity o = new Opportunity(Name = 'Test Opp', StageName = 'Prospect', CloseDate = System.today(), AccountId = a.Id);
		insert o;

		EditableTableModel etm = new EditableTableModel();
		etm.api = 'Name';
		etm.editable = 'true';
		etm.label = 'Name';
		etm.name = 'Name';
		etm.type = 'STRING';
		etm.value = 'Test Opp';

		Custom_Action__mdt customAction = new Custom_Action__mdt();
		customAction.DeveloperName = 'Test_1';
		customAction.Field_Values__c = '{"fields":[{"name" : "Name","value":"Test 1"},{"name" : "StageName","value":"Prospect"},{"name" : "CloseDate","value":"5"},{"name" : "AccountId","value":"RecordId"}';
		customAction.sObject_Api__c = 'Opportunity';
		customAction.Type__c = 'Create';
		customAction.MasterLabel = 'Test_1';
		//insert customAction;


		String fieldNameJson = EditableListController.getFieldSet('Opportunity', 'Name,StageName', 'Description');
		String fielNameString = '["Name","StageName","Description","CloseDate","Type","IsPrivate"]';
		String filterField = EditableListController.getFilterFieldSet('Opportunity', 'Name,StageName');
		String withFilters = '[{"label":"Name","editable":"false","type":"STRING","api":"Name","value":"Test Opp","name":"Name"},{"label":"Stage","editable":"false","type":"PICKLIST","api":"StageName","value":"Prospect","name":"StageName"}]';

		List<sObject> tableRows = EditableListController.getTableRowValues(a.Id, 'AccountId', 'Account', 'Opportunity', fielNameString, withFilters, '60', 'Name', 'StageName', 'ASC','Name = \'Test Opp\'');

		EditableListController.getCustomActions('Test');
		EditableListController.triggerCustomAction('Test_1', a.Id);
        EditableListController.triggerCustomFormAction('Test_1', a.Id);
		EditableListController.replaceRecordId(customAction.Field_Values__c, a.Id);
		EditableListController.replaceRecordTypeId(customAction.Field_Values__c, 'Test', 'Opportunity');
		System.assertEquals(1, tableRows.size());

		EditableListController.deleteServerAction(o.Id, 'Opportunity');
	}
}