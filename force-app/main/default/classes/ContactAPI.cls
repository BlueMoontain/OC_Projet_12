@RestResource(urlMapping='/Contact/*')
global with sharing class ContactAPI {
    // Define custom exceptions
    public class BadRequestException extends Exception {}
    public class NotFoundException extends Exception {}

    @HttpPost
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
    
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', 'success');
            response.put('id', contact.Id);
            res.responseBody = Blob.valueOf(JSON.serialize(response));
    
        } catch (BadRequestException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        }
    }

    @HttpPatch
    global static void updateContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
    
            String id = (String) params.get('id');
            String name = (String) params.get('name');
    
            if (String.isBlank(name)) {
                throw new DmlException('Name cannot be empty');
            }
    
            List<Contact> existingContacts = [SELECT Id, LastName FROM Contact WHERE Id = :id LIMIT 1];
            if (!existingContacts.isEmpty()) {
                Contact existingContact = existingContacts[0];
                existingContact.LastName = name;
                update existingContact;
    
                Map<String, Object> response = new Map<String, Object>();
                response.put('status', 'success');
                response.put('id', existingContact.Id);
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                res.statusCode = 200; // Success
            } else {
                throw new NotFoundException('No contact with this id was found');
            }
        } catch (NotFoundException e) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (DmlException e) {
            res.statusCode = 409;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        }
    }

    @HttpDelete 
global static void deactivateContact() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    try {
        String email = req.params.get('email');
        if (email == null) {
            throw new BadRequestException('Email is required');
        }

        List<Contact> existingContacts = [SELECT Id, IsDisabled__c FROM Contact WHERE Email = :email LIMIT 1];
        if (existingContacts.isEmpty()) {
            throw new NotFoundException('The contact does not exist');
        } else if (existingContacts[0].IsDisabled__c) {
            throw new DmlException('The contact is already deactivated');
        } else {
            existingContacts[0].IsDisabled__c = true;
            update existingContacts[0];

            Map<String, Object> response = new Map<String, Object>();
            response.put('status', 'success');
            response.put('message', 'The contact has been deactivated');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200; // Success
        }
    } catch (DmlException e) {
        res.statusCode = 409;
        res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => 'error',
            'message' => e.getMessage()
        }));
    } catch (BadRequestException e) {
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => 'error',
            'message' => e.getMessage()
        }));
    } catch (NotFoundException e) {
        res.statusCode = 404;
        res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => 'error',
            'message' => e.getMessage()
        }));
    } catch (Exception e) {
        res.statusCode = 500;
        res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => 'error',
            'message' => e.getMessage()
        }));
    }
}
// @HttpDelete 
// global static void deactivateContact() {
//     RestRequest req = RestContext.request;
//     RestResponse res = RestContext.response;
//     try {
//         String email = req.params.get('email');
//         if (email == null) {
//             throw new BadRequestException('Email is required');
//         }

//         List<Contact> existingContacts = [SELECT Id, IsDisabled__c FROM Contact WHERE Email = :email LIMIT 1];
//         if (!existingContacts.isEmpty() && !existingContacts[0].IsDisabled__c) {
//             existingContacts[0].IsDisabled__c = true;
//             update existingContacts[0];

//             Map<String, Object> response = new Map<String, Object>();
//             response.put('status', 'success');
//             response.put('message', 'The contact has been deactivated');
//             res.responseBody = Blob.valueOf(JSON.serialize(response));
//             res.statusCode = 200; // Success
//         } else {
//             throw new NotFoundException('The contact is already deleted or does not exist');
//         }
//     } catch (DmlException e) {
//         res.statusCode = 409;
//         res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//             'status' => 'error',
//             'message' => e.getMessage()
//         }));
//     } catch (BadRequestException e) {
//         res.statusCode = 400;
//         res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//             'status' => 'error',
//             'message' => e.getMessage()
//         }));
//     } catch (NotFoundException e) {
//         res.statusCode = 404;
//         res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//             'status' => 'error',
//             'message' => e.getMessage()
//         }));
//     } catch (Exception e) {
//         res.statusCode = 500;
//         res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//             'status' => 'error',
//             'message' => e.getMessage()
//         }));
//     }
// }
}


// OLD VERSION
// global with sharing class ContactAPI {
//     @HttpPost
//     global static void createContact() {
//         RestRequest req = RestContext.request;
//         RestResponse res = RestContext.response;
//         try {
//             Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
//             // if (params == null) {
//             //     throw new CustomException('Invalid request body');
//             // }
//             String email = (String) params.get('email');
//             // if (email == null) {
//             //     throw new CustomException('Email is required');
//             // }
//             String name = (String) params.get('name');
//             // if (name == null) {
//             //     throw new CustomException('Name is required');
//             // }
//             String accountId = (String) params.get('accountId');
//             // if (accountId == null) {
//             //      throw new CustomException('AccountId is required');
//             // }

//             List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];

//             Contact contact;
//             if (existingContacts.isEmpty()) {
//                 contact = new Contact(Email = email, LastName = name, AccountId = accountId);
//                 insert contact;
//             } else {
//                 contact = existingContacts[0];
//                 contact.LastName = name;
//                 contact.AccountId = accountId;
//                 update contact;
//             }

//             Map<String, Object> response = new Map<String, Object>();
//             response.put('status', 'success');
//             response.put('id', contact.Id);
//             res.responseBody = Blob.valueOf(JSON.serialize(response));
//             res.statusCode = 201;
//         } catch (DmlException e) {
//             res.statusCode = 400;
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         } catch (Exception e) {
//             res.statusCode = 400;
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         }
//     }

//     @HttpPatch
//     global static void updateContact() {
//         RestRequest req = RestContext.request;
//         RestResponse res = RestContext.response;
//         try {
//             Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
//             System.debug('Params: ' + params);
//             if (params == null) {
//                 throw new CustomException('Invalid request body');
//             }
//             String email = (String) params.get('email');
//             String name = (String) params.get('name');

//             Contact existingContact = [SELECT Id, LastName FROM Contact WHERE Email = :email LIMIT 1];
//             System.debug('Existing Contact: ' + existingContact);
//             if (existingContact != null) {
//                 existingContact.LastName = name;
//                 update existingContact;

//                 Map<String, Object> response = new Map<String, Object>();
//                 response.put('status', 'success');
//                 response.put('id', existingContact.Id);
//                 res.responseBody = Blob.valueOf(JSON.serialize(response));
//                 res.statusCode = 200;
//             } else {
//                 throw new CustomException('No contact with this email was found');
//             }
//         } catch (DmlException e) {
//             res.statusCode = 409;
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         } catch (Exception e) {
//             res.statusCode = 400;
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         }
//     }

//     @HttpDelete 
//     global static void deactivateContact() {
//         RestRequest req = RestContext.request;
//         RestResponse res = RestContext.response;
//         try {
//             String email = req.params.get('email');
//             if (email == null) {
//                 throw new CustomException('Email is required');
//             }

//             List<Contact> existingContacts = [SELECT Id, IsDisabled__c FROM Contact WHERE Email = :email LIMIT 1];
//             if (!existingContacts.isEmpty() && !existingContacts[0].IsDisabled__c) {
//                 existingContacts[0].IsDisabled__c = true;
//                 update existingContacts[0];

//                 Map<String, Object> response = new Map<String, Object>();
//                 response.put('status', 'success');
//                 response.put('message', 'The contact has been deactivated');
//                 res.responseBody = Blob.valueOf(JSON.serialize(response));
//                 res.statusCode = 200;
//             } else {
//                 throw new CustomException('The contact is already deleted or does not exist');
//             }
//         } catch (DmlException e) {
//             res.statusCode = 409;
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         } catch (Exception e) {
//             res.statusCode = 400;
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         }
//     }

//     public class CustomException extends Exception {}
// }
// @RestResource(urlMapping='/Contact/*')
// global with sharing class ContactAPI {
//     // Method to create a new contact or update an existing one
//     @HttpPost
//     global static void createContact() {
//         RestRequest req = RestContext.request;
//         RestResponse res = RestContext.response;
//         try {
//             // Parse the request body
//             Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
//             String email = (String) params.get('email');
//             if (email == null) {
//                 // Handle null email
//                 res.statusCode = 400; // BAD REQUEST
//                 res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                     'status' => 'error',
//                     'message' => 'Email is required'
//                 }));
//                 return;
//             }
//             String name = (String) params.get('name');
//             String accountId = (String) params.get('accountId');

//             // Check if a contact with the same email already exists
//             List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];

//             Contact contact;
//             if (existingContacts.isEmpty()) {
//                 // If not, create a new contact
//                 contact = new Contact(Email = email, LastName = name);
//                 insert contact;
//             } else {
//                 // If yes, update the existing contact
//                 contact = existingContacts[0];
//                 contact.LastName = name;
//                 contact.AccountId = accountId;
//                 update contact;
//             }

//             // Send a success response
//             Map<String, Object> response = new Map<String, Object>();
//             response.put('status', 'success');
//             response.put('id', contact.Id);
//             res.responseBody = Blob.valueOf(JSON.serialize(response));
//             res.statusCode = 201; // CREATED
//         } catch (DmlException e) {
//             // Handle database errors
//             res.statusCode = 400; // BAD REQUEST
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         } catch (Exception e) {
//             // Handle other errors
//             res.statusCode = 400; // BAD REQUEST
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         }
//     }

//     // Method to update an existing contact
//     @HttpPatch
//     global static void updateContact() {
//         RestRequest req = RestContext.request;
//         RestResponse res = RestContext.response;
//         try {
//             // Parse the request body
//             Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
//             String email = (String) params.get('email');
//             String name = (String) params.get('name');

//             // Try to find the contact
//             Contact existingContact = [SELECT Id, LastName FROM Contact WHERE Email = :email LIMIT 1];
//             if (existingContact != null) {
//                 // If found, update the contact
//                 existingContact.LastName = name;
//                 update existingContact;

//                 // Send a success response
//                 Map<String, Object> response = new Map<String, Object>();
//                 response.put('status', 'success');
//                 response.put('id', existingContact.Id);
//                 res.responseBody = Blob.valueOf(JSON.serialize(response));
//                 res.statusCode = 200; // OK
//             } else {
//                 // If not found, throw an exception
//                 throw new CustomException('No contact with this email was found');
//             }
//         } catch (DmlException e) {
//             // Handle database errors
//             res.statusCode = 409; // CONFLICT
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         } catch (Exception e) {
//             // Handle other errors
//             res.statusCode = 400; // BAD REQUEST
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         }
//     }

//     // Method to deactivate a contact
//     @HttpDelete 
//     global static void deactivateContact() {
//         RestRequest req = RestContext.request;
//         RestResponse res = RestContext.response;
//         try {
//             // Get the email from the request parameters
//             String email = req.params.get('email');

//             // Try to find the contact
//             List<Contact> existingContacts = [SELECT Id, IsDisabled__c FROM Contact WHERE Email = :email LIMIT 1];
//             if (!existingContacts.isEmpty() && !existingContacts[0].IsDisabled__c) {
//                 // If found and not already deactivated, deactivate the contact
//                 existingContacts[0].IsDisabled__c = true;
//                 update existingContacts[0];

//                 // Send a success response
//                 Map<String, Object> response = new Map<String, Object>();
//                 response.put('status', 'success');
//                 response.put('message', 'The contact has been deactivated');
//                 res.responseBody = Blob.valueOf(JSON.serialize(response));
//                 res.statusCode = 200; // OK
//             } else {
//                 // If not found or already deactivated, throw an exception
//                 throw new CustomException('The contact is already deleted or does not exist');
//             }
//         } catch (DmlException e) {
//             // Handle database errors
//             res.statusCode = 409; // CONFLICT
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         } catch (Exception e) {
//             // Handle other errors
//             res.statusCode = 400; // BAD REQUEST
//             res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//                 'status' => 'error',
//                 'message' => e.getMessage()
//             }));
//         }
//     }
//     public class CustomException extends Exception {}
// }
// @RestResource(urlMapping='/Contact/*')
// global with sharing class ContactAPI {
//     @HttpPost
//     global static void createContact() {
//         RestRequest req = RestContext.request;
//         RestResponse res = RestContext.response;
//         Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
//         String email = (String) params.get('email');
//         String name = (String) params.get('name');
//         String accountId = (String) params.get('accountId'); // Ajouter le champ accountId puisque le contact est lié à un compte ?

//         // Rechercher un contact existant avec le même email
//         List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];

//         Contact contact;
//         if (existingContacts.isEmpty()) {
//             // Si aucun contact existant n'est trouvé, créer un nouveau contact
//             contact = new Contact(Email = email, LastName = name);
//             insert contact;
//         } else {
//             // Si un contact existant est trouvé, le mettre à jour
//             contact = existingContacts[0];
//             contact.LastName = name;
//             contact.AccountId = accountId; // ajout de accountId
//             update contact;
//         }

//         Map<String, Object> response = new Map<String, Object>();
//         response.put('status', 'success');
//         response.put('id', contact.Id);
//         res.responseBody = Blob.valueOf(JSON.serialize(response));
//     }

//     @HttpPatch
//     global static void updateContact() {
//         RestRequest req = RestContext.request;
//         RestResponse res = RestContext.response;
//         Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
//         String email = (String) params.get('email');
//         String name = (String) params.get('name');
//         Contact existingContact = [SELECT Id, LastName FROM Contact WHERE Email = :email LIMIT 1];
//         Map<String, Object> response = new Map<String, Object>();
//         if (existingContact != null) {
//             existingContact.LastName = name;
//             update existingContact;
//             response.put('status', 'success');
//             response.put('id', existingContact.Id);
//         } else {
//             response.put('status', 'error');
//             response.put('message', 'Aucun contact avec cet email n\'a été trouvé');
//         }
//         res.responseBody = Blob.valueOf(JSON.serialize(response));
//     }

//     @HttpDelete 
//     global static void deactivateContact() {
//         RestRequest req = RestContext.request;
//         RestResponse res = RestContext.response;
//         String email = req.params.get('email');
//         List<Contact> existingContacts = [SELECT Id, IsDisabled__c FROM Contact WHERE Email = :email LIMIT 1];
//         Map<String, Object> response = new Map<String, Object>();
//         if (!existingContacts.isEmpty() && !existingContacts[0].IsDisabled__c) {
//             existingContacts[0].IsDisabled__c = true;
//             update existingContacts[0];
//             response.put('status', 'success');
//             response.put('message', 'Le contact a été désactivé');
//         } else {
//             response.put('status', 'error');
//             response.put('message', 'Le contact est déjà supprimé ou n\'existe pas');
//         }
//         res.responseBody = Blob.valueOf(JSON.serialize(response));
//     }
