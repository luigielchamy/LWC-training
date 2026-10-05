@isTest
public class Exercise_1_test {
    @isTest
    public static void anything(){
        List<String> arr = new List<String>{'a', 'a', 'b', 'c', 'c', 'd'};
    
        System.Test.startTest();
        Map<String, Integer> m = Exercise_1.countOccurrences(arr);
        System.Test.stopTest();
    
        System.debug(m);
        System.AssertEquals(2, m.get('a'), 'a should be 2');
        System.AssertEquals(1, m.get('b'), 'b shuold be 1');    
        System.AssertEquals(2, m.get('c'), 'c should be 2');    
        System.AssertEquals(1, m.get('d'), 'd should be 1');
    }
}