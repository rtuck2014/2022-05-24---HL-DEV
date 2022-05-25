global without sharing class HL_Activity implements Comparable {
    //Riva Sync Spacing Divider
    public static final string SYNC_SPACING = ('\n'.repeat(5));
    //Riva Sync Text Divider Section Heading
    public static final string SYNC_DIVIDER = 'External Attendees (will NOT automatically be included on Invite)';
    public String FormattedStart {
        get {
            return Activity.StartDateTime.format();
        }
    }
    public String FormattedEnd {
        get {
            return Activity.EndDateTime.format();
        }
    }
    public Event Activity {
        get;
        set;
    }
    public Id LinkId {
        get;
        set;
    }
    public Task Task {
        get;
        set;
    }
    public Boolean isTask {
        get;
        set;
    }
    public Datetime ActivityDate {
        get;
        set;
    }
    //public Date ActivityDate {get; set;}
    public Datetime CreatedDate {
        get;
        set;
    }
    public String Subject {
        get;
        set;
    }
    public String PrimaryAttendee {
        get;
        set;
    }
    public Boolean ViewAccess {
        get;
        set;
    }
    public Boolean ModifyAccess {
        get;
        set;
    }
    public String PrimaryContact {
        get;
        set;
    }
    public String MessageDate {
        get;
        set;
    }
    public Id PrimaryContactId {
        get;
        set;
    }
    public String Description {
        get;
        set;
    }
    public String Type {
        get;
        set;
    }
    global Integer compareTo(Object o) {
        HL_Activity ha = (HL_Activity) o;
        /* if(ha.Activity!=null){
         return (ha.Activity.StartDateTime > Activity.StartDateTime ? 1 : -1);
         }
         else{
         return (ha.Task.ActivityDate>Task.ActivityDate? 1 : -1);
         }
         */
        // if(ha.Activity!=null){
        return (ha.ActivityDate > ActivityDate ? 1 : -1);
        // }
    }

}