/**
@Name          : LookupSObjectController_Test
@Dated         : 08 nov, 2016
@Author        :
@Description   : This is used to test LookupSObjectController. 
*/

@IsTest
public class LookupSObjectController_Test{
    
    @IsTest
    public static void unitTest(){
        
        TestDataFactory dataFactory = new TestDataFactory();
        List<Account> accountsList  = dataFactory.generateAccounts(1);
        insert accountsList;
        
        //testing static methods
        LookupSObjectController.lookup('Test', 'Account', 'none');
        LookupSObjectController.lookup('Test', 'Account', 'where name like \'test\'');
        LookupSObjectController.initValue(accountsList[0].id, 'Account');
        
    }

}