@RestResource(urlMapping='/Contract/*')
global with sharing class ContractAPI {

    // this method creates a new contract
    @HttpPost // this method is called when a POST request is sent to the URL '/services/apexrest/Contract
    global static void createContract() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            Id accountId = (Id) params.get('accountId');
            String status = (String) params.get('status');
            Date startDate = Date.valueOf((String) params.get('startDate'));
            Integer contractTerm = (Integer) params.get('contractTerm');
            // create a new contract
            Contract newContract = new Contract(
                AccountId = accountId,
                Status = status,
                StartDate = startDate,
                ContractTerm = contractTerm
            );
            // insert the new contract
            insert newContract; 
            // return the new contract id
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'success',
                'contractId' => newContract.Id
            }));
            res.statusCode = 201; // CREATED
        } catch (DmlException e) {
            res.statusCode = 409; // CONFLICT
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (Exception e) {
            res.statusCode = 400; // BAD REQUEST
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        }
    }

    // PATCH /services/apexrest/Contract/{contractId}
    // this method updates an existing contract
    @HttpPatch
    global static void updateContract() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            Id contractId = (Id) params.get('contractId');
            Id accountId = (Id) params.get('accountId');
            String status = (String) params.get('status');
            Date startDate = Date.valueOf((String) params.get('startDate'));
            Integer contractTerm = (Integer) params.get('contractTerm');

            Contract existingContract = [SELECT Id, AccountId, Status, StartDate, ContractTerm FROM Contract WHERE Id = :contractId];

            if (existingContract.Status != 'Activated') { // if the contract is not activated, account can be changed
                existingContract.AccountId = accountId;
            }

            existingContract.Status = status;
            existingContract.StartDate = startDate;
            existingContract.ContractTerm = contractTerm;

            update existingContract; // update the contract

            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'success',
                'contractId' => existingContract.Id
            }));
            res.statusCode = 200; // Status code 200 = OK
        } catch (DmlException e) {  
            res.statusCode = 409; // Status code 409 = CONFLICT
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        } catch (Exception e) {
            res.statusCode = 400; // Status Code 400 = BAD REQUEST
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            }));
        }
    }
}