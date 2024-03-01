// this class is used to create or update a contract
@RestResource(urlMapping='/Contract/*')
global with sharing class ContractAPI {
    @HttpPut
    global static void createOrUpdateContract() {
        // method to create or update a contract
        // set the response type to JSON format with parameters/ status / contractId
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            Id contractId = (Id) params.get('contractId');
            Id accountId = (Id) params.get('accountId');
            String status = (String) params.get('status');
            String startDateString = (String) params.get('startDate');
            Date startDate = Date.valueOf((String) params.get('startDate'));
            Integer contractTerm = (Integer) params.get('contractTerm');
            Contract existingContract;
            try {
                existingContract = [SELECT Id, AccountId, Status, StartDate, ContractTerm FROM Contract WHERE Id = :contractId];
            } catch (Exception e) {
                existingContract = null;
            }
            if (existingContract != null) {
                if (existingContract.Status != 'Activated') { // if the contract is not activated, the account can be changed
                    existingContract.AccountId = accountId;
                }
                existingContract.Status = status;
                existingContract.StartDate = startDate;
                existingContract.ContractTerm = contractTerm;
                // update the contract
                update existingContract;
                // return the contract ID
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'status' => 'success',
                    'contractId' => existingContract.Id
                }));
                res.statusCode = 200; // status OK
            } else {
                Contract newContract = new Contract(
                    AccountId = accountId,
                    Status = status,
                    StartDate = startDate,
                    ContractTerm = contractTerm
                );
                insert newContract; // create the new contract
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'status' => 'success',
                    'contractId' => newContract.Id
                }));
                res.statusCode = 201; // CREATED
            }
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
}