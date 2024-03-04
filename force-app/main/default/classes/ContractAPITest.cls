@isTest
private class ContractAPITest {
// Unit test for the createOrUpdateContract method
// Different scenarios are tested for a PUT request: create a new contract, update an existing contract, create (or update an existing contract) with invalid data
    @isTest static void testCreateNewContract() {
        // use case: create a new contract
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
        req.httpMethod = 'POST'; //POST
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
        // Call createContract
        ContractAPI.createContract(); 
        Test.stopTest();

        // Check that the HTTP status code is 201
        System.assertEquals(201, res.statusCode);

        // Check that the response body contains the correct status and contractId
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('success', responseBody.get('status'));
    }
    
    @isTest static void testCreateContractWithException() {
        // use case: create a new contract with invalid data to trigger Exception
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'POST'; 
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'accountId' => 'invalid', // invalid accountId will trigger Exception
            'status' => 'Draft',
            'startDate' => Date.today(),
            'contractTerm' => 24
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        ContractAPI.createContract(); 
        Test.stopTest();
    
        // Check that the HTTP status code is 400 
        System.assertEquals(400, res.statusCode); // 400 BAD REQUEST
    
        // Check that the response body contains the correct status and message
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', responseBody.get('status'));
    }
    
    @isTest static void testUpdateContract() {
    // use case: update an existing contract
        // set data
        List<Contract> contracts = DataFactory.createContracts(1, 1);
        Contract testContract = contracts[0];
    
        // prepare new data to update the contract
        List<Account> accounts = DataFactory.createAccounts(1);
        Account newAccount = accounts[0];
        String newStatus = 'Draft'; 
        Date newStartDate = Date.today();
        Integer newContractTerm = 24;
    
        // Prepare request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'PATCH'; //PATCH
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'contractId' => testContract.Id,
            'accountId' => newAccount.Id,
            'status' => newStatus,
            'startDate' => newStartDate,
            'contractTerm' => newContractTerm
        }));
        //set request and response
        RestContext.request = req;
        RestContext.response = res;
        
        // Call UpdateContract
        Test.startTest();
        ContractAPI.updateContract();
        Test.stopTest();
    
        // Check that the contract was updated with the correct details
        Contract updatedContract = [SELECT AccountId, Status, StartDate, ContractTerm FROM Contract WHERE Id = :testContract.Id];
        System.assertEquals(newAccount.Id, updatedContract.AccountId);
        System.assertEquals(newStatus, updatedContract.Status);
        System.assertEquals(newStartDate, updatedContract.StartDate);
        System.assertEquals(newContractTerm, updatedContract.ContractTerm);

        // Check that the HTTP status code is 200
        System.assertEquals(200, res.statusCode); // 200 OK

        // Check that the response body contains the correct status and contractId
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('success', responseBody.get('status'));
        System.assertEquals(testContract.Id, (Id) responseBody.get('contractId'));
    }

    @isTest static void testUpdateContractWithInvalidData() {
    // use case: update an existing contract with invalid data
        // Prepare request with invalid data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'PATCH';
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
        // Call UpdateContract
        ContractAPI.updateContract(); 
        Test.stopTest();
    
        // Check that the HTTP status code is 400
        System.assertEquals(400, res.statusCode);

        // Check that the response body contains the correct status and message
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', responseBody.get('status'));
    }
    @isTest static void testCreateContractWithDmlException() {
    // use case: create a contract with invalid contractTerm
        // Use DataFactory to create a list of test accounts
        List<Account> testAccounts = DataFactory.createAccounts(10); 
        // Prepare request with invalid contractTerm to trigger DmlException
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'POST'; 
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'contractId' => null,
            'accountId' => testAccounts[0].Id, 
            'status' => 'Draft',
            'startDate' => Date.today(),
            'contractTerm' => -1 // Invalid contractTerm will trigger DmlException
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        // Call createOrUpdateContract
        Test.startTest();
        ContractAPI.createContract(); 
        Test.stopTest();
    
        // Check that the HTTP status code is 409 
        System.assertEquals(409, res.statusCode); // 409 CONFLICT
    
        // Check that the response body contains the correct status and message
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', responseBody.get('status'));
    }

    @isTest static void testUpdateContractWithException() {
    // use case: update an existing contract with invalid data
        // Prepare request with invalid startDate to trigger Exception
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'PATCH'; 
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'contractId' => 'invalid',
            'accountId' => '0015g0000028T0xAAI',
            'status' => 'Draft',
            'startDate' => 'invalid', // invalid startDate will trigger Exception
            'contractTerm' => 24
        }));
        RestContext.request = req;
        RestContext.response = res;
        
        // Call UpdateContract method
        Test.startTest();
        ContractAPI.updateContract(); 
        Test.stopTest();
    
        // Check that the HTTP status code is 400 
        System.assertEquals(400, res.statusCode); // 400 BAD REQUEST

        // Check that the response body contains the correct status and message
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', responseBody.get('status'));
    } 
    @isTest static void testUpdateContractWithDmlException() {
        // use case: update an existing contract with invalid contractTerm to trigger DmlException
        List<Contract> contracts = DataFactory.createContracts(1, 1);
        Contract testContract = contracts[0];
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Contract';  
        req.httpMethod = 'PATCH'; 
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'contractId' => testContract.Id,
            'accountId' => testContract.AccountId,
            'status' => 'Draft',
            'startDate' => Date.today(),
            'contractTerm' => -1 // Invalid contractTerm will trigger DmlException
        }));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        ContractAPI.updateContract(); 
        Test.stopTest();
    
        // Check that the HTTP status code is 409 
        System.assertEquals(409, res.statusCode); // 409 CONFLICT
    
        // Check that the response body contains the correct status and message
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('error', responseBody.get('status'));
    }   
}