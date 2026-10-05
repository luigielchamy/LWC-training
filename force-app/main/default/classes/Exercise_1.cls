//Create a function that takes in a list, maps it and counts the occurences of each of its values
public with sharing class Exercise_1   {
    public static Map<String, Integer> countOccurrences(List<String> values) {
        Map<String, Integer> occurrences = new Map<String, Integer>();
        for(String val : values) {
            if(occurrences.containsKey(val)) {
                occurrences.put(val, occurrences.get(val)+1);
            } else {
                occurrences.put(val, 1);
            }
        }
        return occurrences;
    }
}