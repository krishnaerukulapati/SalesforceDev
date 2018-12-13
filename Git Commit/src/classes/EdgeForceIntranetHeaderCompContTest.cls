/**
  * Apex Class: IntranetHeaderComponentControllerTest
  * Description: test class for IntranetHeaderComponentController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class EdgeForceIntranetHeaderCompContTest {
    
    private static testmethod void HeaderComponentControllerTest(){
        //Creates new user
        User usr = TestUtil.createUser(true);
        EdgeForceIntranetHeaderCompController conObj;
        
        //Create controller obj to fetch current logged in user detail
        system.runAs(usr){
            conObj = new EdgeForceIntranetHeaderCompController();
        }
        
        //Assert currentUser is newly created user
        //system.assertEquals(conObj.currentUser.Id,usr.Id);
    }
}