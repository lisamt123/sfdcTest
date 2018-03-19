trigger TestAccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    for(Account acc : Trigger.new) {
        if(Trigger.isInsert) {
            // ...
        }

        // ...

        if(Trigger.isDelete) {
            // ...
        }
    }
    Account a = Trigger.new[0]; //Bad: Accessing the trigger array directly is not recommended.
   
	for( Account a : Trigger.new ){   
	    //Good: Iterate through the trigger.new array instead.
	}
}