public with sharing class SelectListPicklist {
	
	@AuraEnabled
	public static List<String> getSelectOptions(String objObject, string fld) {
		system.debug('objObject --->' + objObject);
		system.debug('fld --->' + fld);
		List<String> allOpts = new list<String>();
		// Get the object type of the SObject.
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType objType = schemaMap.get(objObject);

		//Schema.sObjectType objType = objObject.getSObjectType();
		// Describe the SObject using its object type.
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		// Get a map of fields for the SObject
		Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
		// Get the list of picklist values for this field.
		List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
		// Add these values to the selectoption list.
		for(Schema.PicklistEntry a : values) {
			allOpts.add(a.getValue());
		}
		system.debug('allOpts ---->' + allOpts);
		return allOpts;
	}
}