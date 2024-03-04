@isTest
private class ContactAPITest {
// Unit tests for the createContact method
// differents scenarios are tested : new contact, already existing contact, contact without name, exception
    @isTest static void testCreateNewContact() {
    // use case : create a new contact with a new email that does not exist in the database
        // setup test data
        List<Account> accounts = DataFactory.createAccounts(1);
        List<Contact> contacts = DataFactory.createContacts(1);
        Contact testContact = contacts[0]; 

        // setup request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'email' => 'newemail@test.com', // Use a new email
            'name' => 'NewLastName'
        }));
        RestContext.request = req;
        RestContext.response = res;

        // Call createContact method
        Test.startTest();
        ContactAPI.createContact();
        Test.stopTest();

        // Check that the new contact was created
        Contact newContact = [SELECT Id, LastName FROM Contact WHERE Email = 'newemail@test.com'];
        System.assertNotEquals(null, newContact);
        System.assertEquals('NewLastName', newContact.LastName);

        // check that the method returned the ID of the new contact
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(newContact.Id, response.get('id'));
    }

    @isTest static void testCreateContactException() {
    // use case : create a new contact with a null request body and expect a 500 status code
        // Set up the request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = null; // "null" will cause a NullPointerException
        RestContext.request = req;
        RestContext.response = res;

        // Call the method createContact
        Test.startTest();
        ContactAPI.createContact();
        Test.stopTest();

        // Check the response status code (500) and message must match the expected values
        System.assertEquals(500, res.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', response.get('status'));
        System.assertNotEquals(null, response.get('message'));
    }
    @isTest static void testCreateContactWithoutName() {
    // use case : create a new contact without providing a name
        //setup test data
        List<Account> accounts = DataFactory.createAccounts(5);
        List<Contact> contacts = DataFactory.createContacts(5);
    
        // setup request and response with a null name
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'email' => 'newemail@test.com' 
            // no name provided
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        // Call createContact method
        Test.startTest();
        ContactAPI.createContact();
        Test.stopTest();
        
        // check that the method returned a 400 status code
        System.assertEquals(400, res.statusCode);
    }

// unit tests for the updateContact method 
// // differents scenarios are tested : update an existing contact, update a non existing contact, contact not found, DmlException
@isTest static void testUpdateContact() {
    // use case : update the name of an existing contact
    // setup test data
    List<Account> accounts = DataFactory.createAccounts(5);
    List<Contact> contacts = DataFactory.createContacts(5);
    Contact testContact = contacts[0]; 

    // setup request and response
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/Contact';  
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
        'id' => testContact.Id,
        'LastName' => 'UpdatedLastName' // 
    }));
    RestContext.request = req;
    RestContext.response = res;

    //call updateContact method
    Test.startTest();
    ContactAPI.updateContact();
    Test.stopTest();
    
    // Check that the id of the updated contact was returned
    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(testContact.Id, response.get('Contact ID')); // use 'Contact ID' instead of 'id'

    // Check that the name of the contact was updated
    Contact updatedContact = [SELECT Id, LastName FROM Contact WHERE Id = :testContact.Id];
    System.assertEquals('UpdatedLastName', updatedContact.LastName);
}

    @isTest static void testUpdateNonExistingContact() {
    // use case : update the name of a contact that does not exist in the database
        // setup test data
        List<Account> accounts = DataFactory.createAccounts(5);
        List<Contact> contacts = DataFactory.createContacts(5);
    
        // setup request and response with a non existing email
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'email' => 'nonexistingemail@test.com', //use a non existing email
            'name' => 'UpdatedLastName'
        }));
        RestContext.request = req;
        RestContext.response = res;
        
        // Call updateContact method
        Test.startTest();
        ContactAPI.updateContact();
        Test.stopTest();
        
        // Check that the method returned a 404 status code
        System.assertEquals(404, res.statusCode);
    }

    @isTest
    static void testUpdateContactnotFound() {
    // use case : contact not found
        // setup test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"id": "invalidId", "name": "Updated"}'); // This will cause a NotFoundException
        RestContext.request = req;
        RestContext.response = res;
    
        // Call the method updateContact
        Test.startTest();
        ContactAPI.updateContact();
        Test.stopTest();
    
        // Check the response status code (404) and message must match the expected values
        System.assertEquals(404, res.statusCode); // 404 Not Found
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', response.get('status'));
        System.assertNotEquals(null, response.get('message'));
    }
    @isTest static void testUpdateContactDmlException() {
        // use case : update with a recquired field missing
        // setup test data
        List<Account> accounts = DataFactory.createAccounts(5);
        List<Contact> contacts = DataFactory.createContacts(5);
        Contact testContact = contacts[0]; 
    
        // setup request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'id' => testContact.Id,
            'Lastname' => '' // use a requiered field
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        //call updateContact method
        Test.startTest();
        ContactAPI.updateContact();
        Test.stopTest();
        
        // Check that a DmlException was thrown
        System.assertEquals(409, res.statusCode);
    }

// unit tests for the deactivateContact method
// differents scenarios are tested : deactivate an existing contact, deactivate a non existing contact, deactivate an already disabled contact, deactivate a contact without email, BadRequest
    @isTest static void testDeactivateContact() {
    // use case : deactivate an existing contact
        // setup test data
        List<Account> accounts = DataFactory.createAccounts(5);
        List<Contact> contacts = DataFactory.createContacts(5);
        Contact testContact = contacts[0]; 
    
        // setup request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'DELETE';
        req.addParameter('id', testContact.Id);
        RestContext.request = req;
        RestContext.response = res;
        
        // Call deactivateContact method
        Test.startTest();
        ContactAPI.deactivateContact();
        Test.stopTest();
        
        // check that the contact was deactivated
        Contact deactivatedContact = [SELECT Id, IsDisabled__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(true, deactivatedContact.IsDisabled__c);
        System.assertEquals(200, res.statusCode);
    }

    @isTest static void testDeactivateNonExistingContact() {
        // setup request and response with a non existing ID
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'DELETE';
        req.addParameter('id', 'nonexistinid'); // use a non existing id
        RestContext.request = req;
        RestContext.response = res;
    
        // Call deactivateContact method    
        Test.startTest();
        ContactAPI.deactivateContact();
        Test.stopTest();
        
        // Check that the method returned a 404 status code
        System.assertEquals(404, res.statusCode); // 404 Not Found
    }

    @isTest
    static void testUpdateContactException() {
    // use case : update a contact with a null request body
        // Set up the test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = null; // This will cause a NullPointerException
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        ContactAPI.updateContact();
        Test.stopTest();

        // Check the response status code (500) and message must match the expected values
        System.assertEquals(500, res.statusCode); // 500 Internal Server Error
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', response.get('status'));
        System.assertNotEquals(null, response.get('message'));
    }

// unit tests for the deactivateContact method
    @isTest static void testDeactivateAlreadyDisabledContact() {
    // use case : deactivate an already disabled contact
        // setup test data
        List<Account> accounts = DataFactory.createAccounts(1);
        List<Contact> contacts = DataFactory.createContacts(1);
        Contact testContact = contacts[0]; 
        testContact.IsDisabled__c = true; // define the contact as disabled
        update testContact;
    
        // setup request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'DELETE';
        req.addParameter('id', testContact.Id); // use disabled contact email
        RestContext.request = req;
        RestContext.response = res;
    
        // Call deactivateContact method
        Test.startTest();
        ContactAPI.deactivateContact();
        Test.stopTest();
        
        // Check that the method returned a 409 status code
        System.assertEquals(409, res.statusCode); // 409 Conflict
    }
    @isTest static void testDeactivateContactWithBadRequest() {
    // use case : deactivate a contact with a bad request
        // setup request and response with a bad request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'DELETE';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{"invalid": "json}'); // This will cause a BadRequestException
        RestContext.request = req;
        RestContext.response = res;
    
        // Call deactivateContact method
        Test.startTest();
        ContactAPI.deactivateContact();
        Test.stopTest();
        
        // Check that the method returned a 400 status code
        System.assertEquals(400, res.statusCode);
    }

    @isTest static void testBadRequestException() {
        // Set up the test data
        Contact testContact = new Contact(Email = 'test@example.com', LastName = 'Test');
        insert testContact;

        // Set up the mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'email' => 'test@example.com',
            'name' => 'Test'
        }));
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        ContactAPI.createContact();
        Test.stopTest();

        // Check the response
        System.assertEquals(400, res.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', response.get('status'));
        System.assertEquals('Contact with this email already exists', response.get('message'));
    }

    @isTest static void testGeneralException() {
        // Set up the mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('invalid json');
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        ContactAPI.createContact();
        Test.stopTest();

        // Check the response
        System.assertEquals(500, res.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', response.get('status'));
        System.assertNotEquals(null, response.get('message'));
    }
}