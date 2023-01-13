public class EditableListController {
	@AuraEnabled
	public static List<sObject> getTableRowValues(String recordId, String relationshipFieldApi, String parentSobjectApi, 
													String childSobjectApi, String fieldNameJson, String fieldFilters, String limitVal,
													String sortByFirst, String sortBySecond, String sortOrderVal, String extraFilters){
		List<sObject> allObjects = new List<sObject>();
		String result = '';
		System.debug(fieldNameJson);

		List<EditableTableModel> fieldFilterVals = (List<EditableTableModel>) JSON.deserialize(fieldFilters, List<EditableTableModel>.class);

		try{
			Boolean hasRecordId = false;
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();
            String query = 'SELECT Id, ' + String.join(fieldNames, ',') + ' FROM ' + childSobjectApi;
            if(recordId != '' && relationshipFieldApi != '' && recordId != null && relationshipFieldApi != null){
                query += ' WHERE '+ relationshipFieldApi +' = \'' + recordId + '\'';
				hasRecordId = true;
            }
			Integer count = 0;
			if(fieldFilterVals != null){
				for(EditableTableModel filt : fieldFilterVals){
					System.debug(filt);
					if(filt.value != '' && filt.value != null){
						System.debug(filt.type);
						if(filt.type == 'PICKLIST'){
							if(count == 0 && !hasRecordId){
								query += ' WHERE '+ filt.api +' = \'' + filt.value + '\'';
							}
							else{
								query += ' AND '+ filt.api +' = \'' + filt.value + '\'';
							}
						}
						if(filt.type == 'STRING'){
							if(count == 0 && !hasRecordId){
								query += ' WHERE '+ filt.api +' LIKE \'%' + filt.value + '%\'';
							}
							else{
								query += ' AND '+ filt.api +' LIKE \'%' + filt.value + '%\'';
							}
						}
						if(filt.type == 'DATE' || filt.type == 'DATETIME'){
							if(count == 0 && !hasRecordId){
								query += ' WHERE '+ filt.api + (filt.cond == 'less' ? ' < ' : filt.cond == 'lessEqe' ? ' <= ' : filt.cond == '' ? ' = ' : filt.cond) + filt.value;
							}
							else{
								query += ' AND '+ filt.api + (filt.cond == 'less' ? ' < ' : filt.cond == 'lessEqe' ? ' <= ' : filt.cond == '' ? ' = ' : filt.cond) + filt.value;
							}
						}
						if(filt.type == 'BOOLEAN'){
							if(count == 0 && !hasRecordId){
								query += ' WHERE '+ filt.api +' = ' + filt.value;
							}
							else{
								query += ' AND '+ filt.api +' = ' + filt.value;
							}
						}
						if(filt.type == 'INTEGER' || filt.type == 'DOUBLE' || filt.type == 'CURRENCY'){
							if(count == 0 && !hasRecordId){
								query += ' WHERE '+ filt.api +' = ' + filt.value;
							}
							else{
								query += ' AND '+ filt.api +' = ' + filt.value;
							}
						}
						count++;
					}
				}
			}
			if(extraFilters != '' && extraFilters != null){
				if(count == 0 && !hasRecordId){
					query += ' WHERE '+ extraFilters;
				}
				else{
					query += ' AND '+ extraFilters;
				}
			}
            if(sortByFirst != '' && sortByFirst != null){
                query += ' ORDER BY ' + sortByFirst;

				if(sortBySecond != '' && sortBySecond != null){
					query += ', ' + sortBySecond;
				}

				if(sortOrderVal != '' && sortOrderVal != null){
					query += ' ' + sortOrderVal;
				}
            }
			if(limitVal != '' && limitVal != null){
                if(limitVal.isNumeric()){
                	query += ' Limit ' + limitVal;
                }
            }
			System.debug(query);

			SObjectType r = ((SObject)(Type.forName('Schema.'+childSobjectApi).newInstance())).getSObjectType();
			DescribeSObjectResult d = r.getDescribe();
            List<sObject> sobs = Database.query(query);
			if(sobs != null){
                for(sObject s : Database.query(query)){
                    for(String fn : fieldNames){
                        System.debug(fn.trim());
                        if(!fn.trim().contains('.')){
                            Schema.DisplayType typeVal = d.fields.getMap().get(fn.trim()).getDescribe().getType();
                            Boolean isEdit = d.fields.getMap().get(fn.trim()).getDescribe().isUpdateable();
                            System.debug(typeVal);
    
                            if(String.valueOf(typeVal) == 'STRING' && isEdit){
                                if(s.get(fn.trim()) == null){
                                    s.put(fn.trim(),'');
                                }
                            }
                            else if(String.valueOf(typeVal) == 'STRING' && !isEdit){
                                //do nothing.
                            }
                            else{
                                if(s.get(fn.trim()) == null){
                                    s.put(fn.trim(),null);
                                }
                            }
                        }
                    }
                    System.debug(s);
                    allObjects.add(s);
                }
            }
            else{
				allObjects = new List<sObject>();
			}
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
			System.debug(result);
			throw new AuraHandledException('Error: ' + result);   
        }
		System.debug(allObjects);
		return allObjects;
	}

	@AuraEnabled
	public static String getFieldSet(String childSobjectApi, String childSobjectNonEditFieldApis, String childSobjectEditFieldApis) {
		List<String> nonEditFields = new List<String>();
		List<String> editFields = new List<String>();
		if(childSobjectNonEditFieldApis != null && childSobjectNonEditFieldApis != null){
			nonEditFields = childSobjectNonEditFieldApis.trim().split(',');
		}
		if(childSobjectEditFieldApis != null && childSobjectEditFieldApis != null){
			editFields = childSobjectEditFieldApis.trim().split(',');
		}

        String result = '';
        try{
			Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
			Schema.SObjectType sObSchema = schemaMap.get(childSobjectApi);
			Map<String, Schema.SObjectField> fieldMap = sObSchema.getDescribe().fields.getMap();
            system.debug('>>>>>>> fieldMap >>> ' + fieldMap);
			system.debug('>>>>>>> childSobjectApi >>> ' + childSobjectApi);
			for (Schema.SObjectField fieldName: fieldMap.values()){  
			  system.debug('>>>>>>> fieldName >>> ' + fieldName);
			  system.debug('>>>>>>> fieldName >>> ' + fieldName.getDescribe().getType());
			}

            for(String f : nonEditFields) {
				system.debug('>>>>>>> f >>> ' + f);
                if(result != ''){
                    result += ',';
                }
				system.debug('>>>>>>> fieldMap.get(f) >>> ' + fieldMap.get(f.trim().toLowerCase()));
				system.debug('>>>>>>> fieldMap.get(f) >>> ' + fieldMap.get(f.trim().toLowerCase()).getDescribe().getType());
                String jsonPart = '{';
                jsonPart += '"label":"' + fieldMap.get(f.trim().toLowerCase()).getDescribe().getLabel() + '",';
				jsonPart += '"editable":"' + 'false' + '",';
                jsonPart += '"type":"' + (fieldMap.get(f.trim().toLowerCase()).getDescribe().getType()) + '",';
				jsonPart += '"api":"' + fieldMap.get(f.trim().toLowerCase()) + '",';
				jsonPart += '"name":"' + f + '"';
                jsonPart += '}';
                result += jsonPart;
            }

			for(String f : editFields) {
                if(result != ''){
                    result += ',';
                }
                String jsonPart = '{';
                jsonPart += '"label":"' + fieldMap.get(f.trim().toLowerCase()).getDescribe().getLabel() + '",';
				jsonPart += '"editable":"' + 'true' + '",';
                jsonPart += '"type":"' + (fieldMap.get(f.trim().toLowerCase()).getDescribe().getType()) + '",';
				jsonPart += '"api":"' + fieldMap.get(f.trim().toLowerCase()) + '",';
				jsonPart += '"name":"' + f + '"';
                jsonPart += '}';
                result += jsonPart;
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
			system.debug('>>>>>>> result >>> ' + result);
			throw new AuraHandledException('Error: ' + result);   
        }

		system.debug('>>>>>>> result >>> ' + result);
        return '['+result+']';
    }

	@AuraEnabled
	public static String getFilterFieldSet(String childSobjectApi, String filterFieldApis) {
		List<String> filterFields = new List<String>();
		if(filterFieldApis != null && filterFieldApis != null){
			filterFields = filterFieldApis.trim().split(',');
		}

        String result = '';
        try{
			Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
			Schema.SObjectType sObSchema = schemaMap.get(childSobjectApi);
			Map<String, Schema.SObjectField> fieldMap = sObSchema.getDescribe().fields.getMap();
            system.debug('>>>>>>> fieldMap >>> ' + fieldMap);
			system.debug('>>>>>>> childSobjectApi >>> ' + childSobjectApi);
			for (Schema.SObjectField fieldName: fieldMap.values()){  
			  system.debug('>>>>>>> fieldName >>> ' + fieldName);

			}

            for(String f : filterFields) {
				system.debug('>>>>>>> f >>> ' + f);
                if(result != ''){
                    result += ',';
                }
				system.debug('>>>>>>> fieldMap.get(f) >>> ' + fieldMap.get(f.trim().toLowerCase()));
				system.debug('>>>>>>> fieldMap.get(f) >>> ' + fieldMap.get(f.trim().toLowerCase()).getDescribe().getType());
                String jsonPart = '{';
                jsonPart += '"label":"' + fieldMap.get(f.trim().toLowerCase()).getDescribe().getLabel() + '",';
				jsonPart += '"editable":"' + 'false' + '",';
                jsonPart += '"type":"' + (fieldMap.get(f.trim().toLowerCase()).getDescribe().getType()) + '",';
				jsonPart += '"api":"' + fieldMap.get(f.trim().toLowerCase()) + '",';
				jsonPart += '"value":"' + '' + '",';
				jsonPart += '"name":"' + f + '"';
                jsonPart += '}';
                result += jsonPart;
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
			system.debug('>>>>>>> result >>> ' + result);
			throw new AuraHandledException('Error: ' + result);   
        }

		system.debug('>>>>>>> result >>> ' + result);
        return '['+result+']';
    }

	@AuraEnabled
	public static String deleteServerAction(String recordId, String childSobjectApi){
		String isSuccess = '';
		if(recordId != ''){
			String query = 'SELECT Id FROM ' + childSobjectApi + ' WHERE id = \'' + recordId + '\'';
			List<sObject> deletesRecs = Database.query(query);

			Database.DeleteResult[] drList = Database.delete(deletesRecs, false);
			for(Database.DeleteResult dr : drList) {
				if (dr.isSuccess()) {
					isSuccess = 'Successfully deleted Record';
				}
				else {
					// Operation failed, so get all errors                
					for(Database.Error err : dr.getErrors()) {
						isSuccess = 'ERROR: ' + err.getMessage();
					}
				}
			}
		}

		return isSuccess;
	}

	@AuraEnabled
	public static List<Custom_Action__mdt> getCustomActions(String customActionNames){
		List<Custom_Action__mdt> customActions = new List<Custom_Action__mdt>();
		List<String> allActionNames = new List<String>();

		if(customActionNames != '' && customActionNames != null){
			allActionNames = customActionNames.split(',');
		}

		if(allActionNames != null && !allActionNames.isEmpty()){
			customActions = [SELECT Id, MasterLabel, DeveloperName, Record_Type_Name__c, Field_Values__c, sObject_Api__c, Type__c FROM Custom_Action__mdt WHERE DeveloperName IN: allActionNames];
		}

		System.debug(customActions);

		return customActions;
	}

	@AuraEnabled
	public static string triggerCustomAction(String customActionName, String recordId){
		String result = '';
		System.debug(recordId);
		System.debug(customActionName);
		try{
			Custom_Action__mdt customAction = new Custom_Action__mdt();
            
            if(Test.isRunningTest()){
                customAction.DeveloperName = 'Test_1';
                customAction.Field_Values__c = '{"fields":[{"name" : "Name","value":"Test 1"},{"name" : "StageName","value":"Prospect"},{"name" : "CloseDate","value":"5"},{"name" : "AccountId","value":"RecordId"}]}';
                customAction.sObject_Api__c = 'Opportunity';
                customAction.Type__c = 'Create';
                customAction.MasterLabel = 'Test_1';
            }
            else{
				customAction = [SELECT Id, Record_Type_Name__c, MasterLabel, DeveloperName, Field_Values__c, sObject_Api__c, Type__c FROM Custom_Action__mdt WHERE Id =: customActionName limit 1];
            }
            
			if(customAction != null){
				if(customAction.Type__c == 'Create'){
					String fieldValues = replaceRecordId(customAction.Field_Values__c, recordId);
					fieldValues = replaceRecordTypeId(fieldValues, customAction.Record_Type_Name__c, customAction.sObject_Api__c);
					CustomActionModel cam = (CustomActionModel)JSON.deserialize(fieldValues,CustomActionModel.class);
					sObject sObj = Schema.getGlobalDescribe().get(customAction.sObject_Api__c).newSObject();

					System.debug(fieldValues);

					SObjectType r = ((SObject)(Type.forName('Schema.'+customAction.sObject_Api__c).newInstance())).getSObjectType();
					DescribeSObjectResult d = r.getDescribe();

					for(CustomActionModel.Fields flds : cam.fields){
						Schema.DisplayType typeVal = d.fields.getMap().get(flds.name).getDescribe().getType();
						System.debug(typeVal);
						if(String.valueOf(typeVal) == 'DATE' || String.valueOf(typeVal) == 'DATETIME'){
							sObj.put(flds.name,System.today().addDays(Integer.valueOf(flds.value)));
						}
						else{
							sObj.put(flds.name,flds.value);
						}
					}

					System.debug(sObj);
					insert sObj;
					result = 'Inserted Successfully';
				}
			}
		}catch(Exception e){
			result = e.getMessage() + ' : On Line ' + e.getLineNumber();
		}
		return result;
	}

	@AuraEnabled
	public static string replaceRecordId(String fields, String recordId){
		String result = '';
		if(fields.contains('$RecordId')){
			result = fields.replace('$RecordId', recordId);
		}
		else{
			result = fields;
		}
		return result;
	}

	@AuraEnabled
	public static string replaceRecordTypeId(String fields, String recordTypeName, String sobjectName){
		String result = '';
		String gsRecordTypeID = '';
		if(Schema.getGlobalDescribe().get(sobjectName) != null && Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName) != null){
			gsRecordTypeID = Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		}

		if(fields.contains('$RecordType')){
			result = fields.replace('$RecordType', gsRecordTypeID);
		}
		else{
			result = fields;
		}
		return result;
	}
    
    @AuraEnabled
	public static List<EditTableFormCustomActionModel> triggerCustomFormAction(String customActionName, String recordId){
        List<EditTableFormCustomActionModel> etFormActions = new List<EditTableFormCustomActionModel>();
		String result = '';
		System.debug(recordId);
		System.debug(customActionName);
		try{
			Custom_Action__mdt customAction = new Custom_Action__mdt();
            
            if(Test.isRunningTest()){
                customAction.DeveloperName = 'Test_1';
                customAction.Field_Values__c = '{"fields":[{"name" : "Name","value":"Test 1"},{"name" : "StageName","value":"Prospect"},{"name" : "CloseDate","value":"5"},{"name" : "AccountId","value":"RecordId"}]}';
                customAction.sObject_Api__c = 'Opportunity';
                customAction.Type__c = 'Form';
                customAction.MasterLabel = 'Test_1';
            }
            else{
				customAction = [SELECT Id, Record_Type_Name__c, MasterLabel, DeveloperName, Field_Values__c, sObject_Api__c, Type__c FROM Custom_Action__mdt WHERE Id =: customActionName limit 1];
            }
            System.debug(customAction);
			if(customAction != null){
				if(customAction.Type__c == 'Form'){
					String fieldValues = replaceRecordId(customAction.Field_Values__c, recordId);
					fieldValues = replaceRecordTypeId(fieldValues, customAction.Record_Type_Name__c, customAction.sObject_Api__c);
					CustomActionModel cam = (CustomActionModel)JSON.deserialize(fieldValues,CustomActionModel.class);
					sObject sObj = Schema.getGlobalDescribe().get(customAction.sObject_Api__c).newSObject();

					System.debug(fieldValues);

					SObjectType r = ((SObject)(Type.forName('Schema.'+customAction.sObject_Api__c).newInstance())).getSObjectType();
					DescribeSObjectResult d = r.getDescribe();

					for(CustomActionModel.Fields flds : cam.fields){
                        EditTableFormCustomActionModel formCa = new EditTableFormCustomActionModel();
						Schema.DisplayType typeVal = d.fields.getMap().get(flds.name).getDescribe().getType();
						System.debug(typeVal);
                        formCa.objectApi = customAction.sObject_Api__c;
						if(String.valueOf(typeVal) == 'DATE' || String.valueOf(typeVal) == 'DATETIME'){
							//sObj.put(flds.name,System.today().addDays(Integer.valueOf(flds.value)));
							formCa.fieldApi = flds.name;
                            if(flds.value != ''){
                                formCa.fieldValue = String.valueOf(System.today().addDays(Integer.valueOf(flds.value)));
                            }
                            else{
                            	formCa.fieldValue = null;
                            }
						}
						else{
							//sObj.put(flds.name,flds.value);
                            formCa.fieldApi = flds.name;
                            formCa.fieldValue = flds.value;
						}
                        
                        etFormActions.add(formCa);
					}

					System.debug(etFormActions);
					//insert sObj;
					//result = 'Inserted Successfully';
				}
			}
		}catch(Exception e){
			result = e.getMessage() + ' : On Line ' + e.getLineNumber();
		}
		return etFormActions;
	}

}