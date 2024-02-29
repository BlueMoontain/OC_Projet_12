@RestResource(urlMapping='/Contract/*')
global with sharing class ContractAPI {
    @HttpPut
    global static void createOrUpdateContract() {
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
                if (existingContract.Status != 'Activated') {
                    existingContract.AccountId = accountId;
                }
                existingContract.Status = status;
                existingContract.StartDate = startDate;
                existingContract.ContractTerm = contractTerm;
                update existingContract;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'status' => 'success',
                    'contractId' => existingContract.Id
                }));
                res.statusCode = 200; // OK
            } else {
                Contract newContract = new Contract(
                    AccountId = accountId,
                    Status = status,
                    StartDate = startDate,
                    ContractTerm = contractTerm
                );
                insert newContract;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'status' => 'success',
                    'contractId' => newContract.Id
                }));
                res.statusCode = 201; // CREATED
            }
        } catch (DmlException e) {
            res.statusCode = 409; // plus précis 409 ?
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
// En 2 méthodes (old version)
//     @HttpPost
//     global static String createContract(Id accountId, String status, Date startDate, Integer contractTerm) {
//         // Créez un nouveau contrat avec les détails fournis et retournez son ID
//         Contract newContract = new Contract(
//             AccountId = accountId,
//             Status = status,
//             StartDate = startDate,
//             ContractTerm = contractTerm
//         );
//         insert newContract;
//         return newContract.Id;
//     }

//     @HttpPatch
//     global static void updateContract(Id contractId, Id accountId, String status, Date startDate, Integer contractTerm) {
//         Contract existingContract;
//         try {
//             existingContract = [SELECT Id, AccountId, Status, StartDate, ContractTerm FROM Contract WHERE Id = :contractId];
//         } catch (Exception e) {
//             RestContext.response.statusCode = 404;
//             RestContext.response.responseBody = Blob.valueOf('Aucun contrat avec cet ID n\'a été trouvé.');
//             return;
//         }
//         if (existingContract.Status != 'Activated') {
//             existingContract.AccountId = accountId;
//         }
//         existingContract.Status = status;
//         existingContract.StartDate = startDate;
//         existingContract.ContractTerm = contractTerm;
//         update existingContract;
//     }
// }