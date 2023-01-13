@isTest
private class SelectListPicklistTest  {
	@isTest
	static void AccountPicklist()
	{
		Account acct = new Account();
		sObject sObj = acct;
		List<String> myOptions = SelectListPicklist.getSelectOptions('Account', 'AccountSource');
		system.assertNotEquals(myOptions.size(),0);
	}

	@isTest
	static void ContactPicklist()
	{
		Contact con = new Contact();
		sObject sObj = con;
		List<String> myOptions = SelectListPicklist.getSelectOptions('Contact', 'LeadSource');
		system.assertNotEquals(myOptions.size(),0);
	}
}