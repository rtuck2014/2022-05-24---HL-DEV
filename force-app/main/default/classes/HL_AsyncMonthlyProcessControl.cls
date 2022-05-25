public class HL_AsyncMonthlyProcessControl Implements System.Queueable { 

List<SObject> RecordsToProcess= new List<SObject>();
Boolean isInsert = true;

public HL_AsyncMonthlyProcessControl (List<SObject> RecordsToProcess, Boolean isInsert){ 
this.RecordsToProcess = RecordsToProcess;
this.isInsert = isInsert;
} 

public void execute (QueueableContext context) { 
    if(isInsert){
        Database.Insert(RecordsToProcess, True);
    }
    else{
        Database.Update(RecordsToProcess, True);
    }
} 

}