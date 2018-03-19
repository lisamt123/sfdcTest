@isTest(seeAllData = true)
public class Foo {

	Integer birthYear;
    Integer birthMonth;
    Integer birthDate;
    Integer height;
    Integer weight;
    Integer birthYear1;
    Integer birthMonth1;
    Integer birthDate1;
    Integer height1;
    Integer weight1;
    Integer birthYear2;
    Integer birthMonth2;
    Integer birthDate2;
    Integer height2;
    Integer weight2;
   public static testMethod void testSomething() {
      Account a = null;
	   // This is better than having a NullPointerException
	   // System.assertNotEquals(a, null, 'account not found');
	   //a.toString();
   }
}