// This class is used to create, update and deactivate contacts using REST API
@RestResource(urlMapping='/Contact/*')
global with sharing class ContactAPI {
    // Define custom exceptions
    public class BadRequestException extends Exception {}
    public class NotFoundException extends Exception {}

    @HttpPost // this method is called when a POST request is made to the URL '/services/apexrest/Contact'
    // Method to create a new contact 
    global static void createContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());

            String email = (String) params.get('email');
            String name = (String) params.get('name');

            // Check if the required parameters are provided
            if (email == null || name == null) {
                throw new BadRequestException('Email and name are required');
            }

            // select contact with same email
            List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];

            Contact contact;
            if (existingContacts.isEmpty()) {
                // Create a new contact
                contact = new Contact(Email = email, LastName = name);
                insert contact;
                res.statusCode = 201; // Resource created
            } else {
                // Update the existing contact
                contact = existingContacts[0];
                contact.LastName = name;
                update contact;
                res.statusCode = 200; // Success
            }

            // map to return the response 
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', 'success');
            response.put('id', contact.Id);
            res.responseBody = Blob.valueOf(JSON.serialize(response));

        } catch (BadRequestException e) {
            res.statusCode = 400; // Bad request
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (Exception e) {
            res.statusCode = 500; // Internal server error
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        }
    }

    @HttpPatch // this method is called when a PATCH request is made to the URL '/services/apexrest/Contact'
    // method to update an existing contact
    global static void updateContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());

            String id = (String) params.get('id');
            String name = (String) params.get('name');

            // Check if the required parameters are provided
            if (String.isBlank(name)) {
                throw new DmlException('Name cannot be empty');
            }

            // select contact with same ID and update
            List<Contact> existingContacts = [SELECT Id, LastName FROM Contact WHERE Id = :id LIMIT 1];
            if (!existingContacts.isEmpty()) {
                Contact existingContact = existingContacts[0];
                existingContact.LastName = name;
                update existingContact;

                // map to return the response 
                Map<String, Object> response = new Map<String, Object>();
                response.put('status', 'success');
                response.put('Contact ID', existingContact.Id);
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                res.statusCode = 200; // Success
            } else {
                throw new NotFoundException('No contact with this id was found');
            }
        } catch (NotFoundException e) {
            res.statusCode = 404; // Not found
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (DmlException e) {
            res.statusCode = 409; // Conflict
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (Exception e) {
            res.statusCode = 500; // Internal server error
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        }
    }

    @HttpDelete // this method is called when a DELETE request is made to the URL '/services/apexrest/Contact'
    // method to deactivate a contact
    global static void deactivateContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String email = req.params.get('email');
            if (email == null) {
                throw new BadRequestException('Email is required');
            }

            // select contact with same email and deactivate
            List<Contact> existingContacts = [SELECT Id, IsDisabled__c FROM Contact WHERE Email = :email LIMIT 1];
            if (existingContacts.isEmpty()) {
                throw new NotFoundException('The contact does not exist');
            } else if (existingContacts[0].IsDisabled__c) {
                throw new DmlException('The contact is already deactivated');
            } else {
                existingContacts[0].IsDisabled__c = true;
                update existingContacts[0];

                // map to return the response and status code
                Map<String, Object> response = new Map<String, Object>();
                response.put('status', 'success');
                response.put('message', 'The contact has been deactivated');
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                res.statusCode = 200; // Success
            }
        } catch (DmlException e) {
            res.statusCode = 409; // Conflict
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (BadRequestException e) {
            res.statusCode = 400; // Bad request
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (NotFoundException e) {
            res.statusCode = 404; // Not found
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (Exception e) {
            res.statusCode = 500; // Internal server error
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        }
    }
}
