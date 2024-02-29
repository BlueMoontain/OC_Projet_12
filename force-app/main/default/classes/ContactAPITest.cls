@isTest
private class ContactAPITest {

// test de la méthode createContact
    @isTest static void testCreateExistingContact() {
        // Générer des données de test
        List<Account> accounts = DataFactory.createAccounts(1);
        List<Contact> contacts = DataFactory.createContacts(1);
        Contact testContact = contacts[0]; 

        // setup request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'email' => testContact.Email,
            'name' => 'NewLastName'
        }));
        RestContext.request = req;
        RestContext.response = res;

        // Appeler la méthode createContact
        Test.startTest();
        ContactAPI.createContact();
        Test.stopTest();

        // Vérifier que la méthode a renvoyé l'ID du contact existant
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(testContact.Id, response.get('id'));

        // Vérifier que le nom du contact a été mis à jour
        Contact updatedContact = [SELECT Id, LastName FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('NewLastName', updatedContact.LastName);
    }
    @isTest static void testCreateNewContact() {
        // Générer des données de test
        List<Account> accounts = DataFactory.createAccounts(1);
        List<Contact> contacts = DataFactory.createContacts(1);
        Contact testContact = contacts[0]; 

        // Appeler la méthode createContact avec un nouvel email
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'email' => 'newemail@test.com', // Utiliser un nouvel email
            'name' => 'NewLastName'
        }));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ContactAPI.createContact();
        Test.stopTest();

        // Vérifier que la méthode a créé un nouveau contact
        Contact newContact = [SELECT Id, LastName FROM Contact WHERE Email = 'newemail@test.com'];
        System.assertNotEquals(null, newContact);
        System.assertEquals('NewLastName', newContact.LastName);


    // Vérifier que la méthode a renvoyé l'ID du nouveau contact
    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(newContact.Id, response.get('id'));
    }

    @isTest
    static void testCreateContactException() {
        // Set up the test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = null; // This will cause a NullPointerException
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
    @isTest static void testCreateContactWithoutName() {
        // Générer des données de test
        List<Account> accounts = DataFactory.createAccounts(5);
        List<Contact> contacts = DataFactory.createContacts(5);
    
        // Appeler la méthode createContact sans fournir de nom
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'email' => 'newemail@test.com' // Ne pas fournir de nom
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        ContactAPI.createContact();
        Test.stopTest();
        
        // Vérifier que la méthode a renvoyé un code de statut 400
        System.assertEquals(400, res.statusCode);
    }
// test de la méthode UpdateContact
    @isTest static void testUpdateContact() {
        // Générer des données de test
        List<Account> accounts = DataFactory.createAccounts(5);
        List<Contact> contacts = DataFactory.createContacts(5);
        Contact testContact = contacts[0]; 
    
        // Appeler la méthode updateContact
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'id' => testContact.Id,
            'name' => 'UpdatedLastName'
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        ContactAPI.updateContact();
        Test.stopTest();
        
        // Vérifier que la méthode a renvoyé l'ID du contact existant
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(testContact.Id, response.get('id'));
    
        // Vérifier que le nom du contact a été mis à jour
        Contact updatedContact = [SELECT Id, LastName FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('UpdatedLastName', updatedContact.LastName);
    }

    @isTest static void testUpdateNonExistingContact() {
        // Générer des données de test
        List<Account> accounts = DataFactory.createAccounts(5);
        List<Contact> contacts = DataFactory.createContacts(5);
    
        // Appeler la méthode updateContact avec un email qui n'existe pas
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
    
        Test.startTest();
        ContactAPI.updateContact();
        Test.stopTest();
        
        // Vérifier que la méthode a renvoyé un code de statut 404
        System.assertEquals(404, res.statusCode);
    }
    @isTest
    static void testUpdateContactnotFound() {
        // Set up the test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"id": "invalidId", "name": "Updated"}'); // This will cause a NotFoundException
        RestContext.request = req;
        RestContext.response = res;
    
        // Call the method
        Test.startTest();
        ContactAPI.updateContact();
        Test.stopTest();
    
        // Check the response
        System.assertEquals(404, res.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', response.get('status'));
        System.assertNotEquals(null, response.get('message'));
    }

    @isTest
    static void testUpdateContactDmlException() {
        // Create a contact
        Contact contact = new Contact(Email = 'test@example.com', LastName = 'Test');
        insert contact;

        // Set up the test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"email": "test@example.com", "name": ""}'); // This will cause a DmlException
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        ContactAPI.updateContact();
        Test.stopTest();

        // Check the response
        System.assertEquals(409, res.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', response.get('status'));
        System.assertNotEquals(null, response.get('message'));
    }

// test de la méthode deactivateContact

    @isTest static void testDeactivateContact() {
        // Générer des données de test
        List<Account> accounts = DataFactory.createAccounts(5);
        List<Contact> contacts = DataFactory.createContacts(5);
        Contact testContact = contacts[0]; 
    
        // Appeler la méthode deactivateContact
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'DELETE';
        req.addParameter('email', testContact.Email);
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        ContactAPI.deactivateContact();
        Test.stopTest();
        
        // Vérifier que le contact a été désactivé
        Contact deactivatedContact = [SELECT Id, IsDisabled__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(true, deactivatedContact.IsDisabled__c);
        System.assertEquals(200, res.statusCode);
    }

    @isTest static void testDeactivateNonExistingContact() {
        // Appeler la méthode deactivateContact avec un email qui n'existe pas
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'DELETE';
        req.addParameter('email', 'nonexistingemail@test.com'); // Utiliser un email qui n'existe pas
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        ContactAPI.deactivateContact();
        Test.stopTest();
        
        // Vérifier que la méthode a renvoyé un code de statut 404
        System.assertEquals(404, res.statusCode);
    }

    @isTest
    static void testUpdateContactException() {
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

        // Check the response
        System.assertEquals(500, res.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', response.get('status'));
        System.assertNotEquals(null, response.get('message'));
    }

    @isTest static void testDeactivateContactWithoutEmail() {
        // Appeler la méthode deactivateContact sans fournir d'email
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        ContactAPI.deactivateContact();
        Test.stopTest();
        
        // Vérifier que la méthode a renvoyé un code de statut 400
        System.assertEquals(400, res.statusCode);
    }
    

    @isTest static void testDeactivateAlreadyDisabledContact() {
        // Générer des données de test
        List<Account> accounts = DataFactory.createAccounts(1);
        List<Contact> contacts = DataFactory.createContacts(1);
        Contact testContact = contacts[0]; 
        testContact.IsDisabled__c = true;
        update testContact;
    
        // Appeler la méthode deactivateContact avec un contact déjà désactivé
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'DELETE';
        req.addParameter('email', testContact.Email);
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        ContactAPI.deactivateContact();
        Test.stopTest();
        
        // Vérifier que la méthode a renvoyé un code de statut 409
        System.assertEquals(409, res.statusCode);
    }
    @isTest static void testDeactivateContactWithBadRequest() {
        // Appeler la méthode deactivateContact avec une requête mal formée
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contact';  
        req.httpMethod = 'DELETE';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{"invalid": "json}');
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        ContactAPI.deactivateContact();
        Test.stopTest();
        
        // Vérifier que la méthode a renvoyé un code de statut 400
        System.assertEquals(400, res.statusCode);
    }
}