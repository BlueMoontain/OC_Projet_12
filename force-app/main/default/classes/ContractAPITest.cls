@isTest
private class ContractAPITest {
    @isTest static void testCreateUpdateContract() {
        // set data
        List<Contract> contracts = DataFactory.createContracts(1, 1);
        Contract testContract = contracts[0];
    
        // prepare new data
        List<Account> accounts = DataFactory.createAccounts(1);
        Account newAccount = accounts[0];
        String newStatus = 'Draft'; 
        Date newStartDate = Date.today();
        Integer newContractTerm = 24;
    
        // Prepare request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'contractId' => testContract.Id,
            'accountId' => newAccount.Id,
            'status' => newStatus,
            'startDate' => newStartDate,
            'contractTerm' => newContractTerm
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        // Call createOrUpdateContract
        ContractAPI.createOrUpdateContract();
        Test.stopTest();
    
        // Check that the contract was updated with the correct details
        Contract updatedContract = [SELECT AccountId, Status, StartDate, ContractTerm FROM Contract WHERE Id = :testContract.Id];
        System.assertEquals(newAccount.Id, updatedContract.AccountId);
        System.assertEquals(newStatus, updatedContract.Status);
        System.assertEquals(newStartDate, updatedContract.StartDate);
        System.assertEquals(newContractTerm, updatedContract.ContractTerm);

        // Check that the HTTP status code is 200
        System.assertEquals(200, res.statusCode);

        // Check that the response body contains the correct status and contractId
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('success', responseBody.get('status'));
        System.assertEquals(testContract.Id, (Id) responseBody.get('contractId'));
    }

    @isTest static void testCreateUpdateContractWithInvalidData() {
        // Prepare request with invalid data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'contractId' => 'invalid',
            'accountId' => 'invalid',
            'status' => 'invalid',
            'startDate' => 'invalid',
            'contractTerm' => 'invalid'
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        // Call createOrUpdateContract
        ContractAPI.createOrUpdateContract();
        Test.stopTest();
    
        // Check that the HTTP status code is 400
        System.assertEquals(400, res.statusCode);

        // Check that the response body contains the correct status and message
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', responseBody.get('status'));
    }
    @isTest static void testCreateUpdateContractWithDmlException() {
        // Use DataFactory to create a list of test accounts
        List<Account> testAccounts = DataFactory.createAccounts(10); 
        // Prepare request with invalid contractTerm to trigger DmlException
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'contractId' => null, // No existing contract
            'accountId' => testAccounts[0].Id, // Use the Id of the first test account
            'status' => 'Draft',
            'startDate' => Date.today(),
            'contractTerm' => -1 // Invalid contractTerm will trigger DmlException
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        // Call createOrUpdateContract
        ContractAPI.createOrUpdateContract();
        Test.stopTest();
    
        // Check that the HTTP status code is 409 (CONFLICT)
        System.assertEquals(409, res.statusCode);
    
        // Check that the response body contains the correct status and message
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', responseBody.get('status'));
    }

    @isTest static void testCreateUpdateContractWithException() {
        // Prepare request with invalid startDate to trigger Exception
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'contractId' => 'invalid',
            'accountId' => '0015g0000028T0xAAI',
            'status' => 'Draft',
            'startDate' => 'invalid', // invalid startDate will trigger Exception
            'contractTerm' => 24
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        // Call createOrUpdateContract
        ContractAPI.createOrUpdateContract();
        Test.stopTest();
    
        // Check that the HTTP status code is 400 (BAD REQUEST)
        System.assertEquals(400, res.statusCode);

        // Check that the response body contains the correct status and message
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', responseBody.get('status'));
    }
    @isTest static void testCreateNewContract() {
        // Create a valid account and contract using DataFactory
        List<Contract> contracts = DataFactory.createContracts(1, 1);
        Account validAccount = [SELECT Id FROM Account WHERE Id = :contracts[0].AccountId LIMIT 1];
    
        // Generate a valid but non-existing contractId
        Contract tempContract = contracts[0];
        Id nonExistingContractId = tempContract.Id;
        delete tempContract;
    
        // Prepare request with non-existing contractId
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'contractId' => nonExistingContractId,
            'accountId' => validAccount.Id,
            'status' => 'Draft',
            'startDate' => Date.today(),
            'contractTerm' => 24
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        // Call createOrUpdateContract
        ContractAPI.createOrUpdateContract();
        Test.stopTest();
    
        // Check that the HTTP status code is 201
        System.assertEquals(201, res.statusCode);
    
        // Check that the response body contains the correct status and contractId
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('success', responseBody.get('status'));
        // Note: You can't check the contractId in the response because it's generated during the execution of the method
    }
}


// @isTest
// private class ContractAPITest {
//     @isTest static void testCreateUpdateContract() {
//         // set data
//         List<Contract> contracts = DataFactory.createContracts(1, 1);
//         Contract testContract = contracts[0];
    
//         // prepare new data
//         List<Account> accounts = DataFactory.createAccounts(1);
//         Account newAccount = accounts[0];
//         String newStatus = 'Draft'; 
//         Date newStartDate = Date.today();
//         Integer newContractTerm = 24;
    
//         // Prepare request
//         RestRequest req = new RestRequest();
//         RestResponse res = new RestResponse();
//         req.requestURI = '/services/apexrest/Contract';  
//         req.httpMethod = 'PUT';
//         req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
//             'contractId' => testContract.Id,
//             'accountId' => newAccount.Id,
//             'status' => newStatus,
//             'startDate' => newStartDate,
//             'contractTerm' => newContractTerm
//         }));
//         RestContext.request = req;
//         RestContext.response = res;
    
//         Test.startTest();
//         // Call createOrUpdateContract
//         ContractAPI.createOrUpdateContract();
//         Test.stopTest();
    
//         // Check that the contract was updated with the correct details
//         Contract updatedContract = [SELECT AccountId, Status, StartDate, ContractTerm FROM Contract WHERE Id = :testContract.Id];
//         System.assertEquals(newAccount.Id, updatedContract.AccountId);
//         System.assertEquals(newStatus, updatedContract.Status);
//         System.assertEquals(newStartDate, updatedContract.StartDate);
//         System.assertEquals(newContractTerm, updatedContract.ContractTerm);
//     }


// test OLD VERSION (2 methodes)
    // @isTest static void testCreateContract() {
    //     // set data
    //     List<Account> accounts = DataFactory.createAccounts(1);
    //     Account testAccount = accounts[0];
    //     String status = 'Draft';
    //     Date startDate = Date.today();
    //     Integer contractTerm = 12;

    //     // Call createContract
    //     RestRequest req = new RestRequest();
    //     RestResponse res = new RestResponse();
    //     req.requestURI = '/services/apexrest/Contract';  
    //     req.httpMethod = 'POST';
    //     RestContext.request = req;
    //     RestContext.response = res;

    //     String result = ContractAPI.createContract(testAccount.Id, status, startDate, contractTerm);

    //     // Check that an ID was returned
    //     System.assertNotEquals(null, result);

    //     // Check that the contract was created with the correct details
    //     Contract newContract = [SELECT AccountId, Status, StartDate, ContractTerm FROM Contract WHERE Id = :result];
    //     System.assertEquals(testAccount.Id, newContract.AccountId);
    //     System.assertEquals(status, newContract.Status);
    //     System.assertEquals(startDate, newContract.StartDate);
    //     System.assertEquals(contractTerm, newContract.ContractTerm);
    // }

    // @isTest static void testUpdateContract() {
    //     // set data
    //     List<Contract> contracts = DataFactory.createContracts(1, 1);
    //     Contract testContract = contracts[0];
    
    //     // prepare new data
    //     List<Account> accounts = DataFactory.createAccounts(1);
    //     Account newAccount = accounts[0];
    //     String newStatus = 'Draft'; 
    //     Date newStartDate = Date.today();
    //     Integer newContractTerm = 24;
    
    //     // Call updateContract
    //     RestRequest req = new RestRequest();
    //     RestResponse res = new RestResponse();
    //     req.requestURI = '/services/apexrest/Contract';  
    //     req.httpMethod = 'PATCH';
    //     RestContext.request = req;
    //     RestContext.response = res;
    
    //     ContractAPI.updateContract(testContract.Id, newAccount.Id, newStatus, newStartDate, newContractTerm);
    
    //     // Check that the contract was updated with the correct details
    //     Contract updatedContract = [SELECT AccountId, Status, StartDate, ContractTerm FROM Contract WHERE Id = :testContract.Id];
    //     System.assertEquals(newAccount.Id, updatedContract.AccountId);
    //     System.assertEquals(newStatus, updatedContract.Status);
    //     System.assertEquals(newStartDate, updatedContract.StartDate);
    //     System.assertEquals(newContractTerm, updatedContract.ContractTerm);
    // }
// }