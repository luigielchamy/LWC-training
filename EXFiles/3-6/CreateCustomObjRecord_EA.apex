//TODO #1  Declare a variable whose type is Course__c named newCourse  
//         and initialize it to a newly constructed Course__c sObject,
//         assigning the field Name the value '[104] Introduction to Programming',
//         the field Description__c the value 'Learn the basics of programming with OOP',
//         the field Status__c the value 'Active',
//         the field Duration__c the value 5.

//TODO #2  Use the insert statement to insert newCourse into the database.
sObject newCourse =  new Course__c(Name = '[104] Introduction to Programming',
                                   Description__c = 'Learn the basics of programming with OOP',
                                   Status__c = 'Active', 
                                   Duration__c = 5);
                                   
Course_Devilery_c newDelivery = 

insert newCourse;

// //EXTRA : You need to create an apex calss that contains a method.
// The method should take 2 parameters (course name and number of deliveries)
// You should call from execute anonymous the class and method to create a course with X deliveries related to this course where X is the number you gave in parameter.




