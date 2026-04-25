@IsTest
public class WABAStatusUpdateFlowTest {
    
    @IsTest
    public static void getStatusBatch(){
        Test.StartTest();
         WABAStatusUpdateFlow.initiateStatusBatch();
        Test.StopTest();
    }

}