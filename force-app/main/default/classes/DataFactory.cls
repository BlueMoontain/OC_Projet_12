
@isTest
public class DataFactory {
    public static List<Account> createAccounts(Integer numAccounts) {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < numAccounts; i++) {
            Account account = new Account(Name = 'Test Account' + i);
            accounts.add(account);
        }
        insert accounts;
        return accounts;
    }
    
    public static List<Contact> createContacts(Integer numContacts) {
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numContacts; i++) {
            Contact contact = new Contact(
                LastName = 'TestLastName' + i,
                Email = 'test' + i + '@example.com'
            );
            contacts.add(contact);
        }
        insert contacts;
        return contacts;
    }

    public static List<Contract> createContracts(Integer numContracts, Integer numAccounts) {
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < numAccounts; i++) {
            Account account = new Account(Name = 'Test Account' + i);
            accountList.add(account);
            }
            insert accountList;
    
            List<Contract> contractList = new List<Contract>();
            for(Integer i = 0; i < numContracts; i++) {
                Account relatedAccount = accountList[i];
                Contract contract = new Contract(
                    AccountId = relatedAccount.Id,
                    Status = 'Draft',
                    StartDate = Date.today(),
                    ContractTerm = 12
                );
                contractList.add(contract);
            }
            insert contractList;
            return contractList;
        }
}