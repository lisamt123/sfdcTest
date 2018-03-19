public without sharing class TimecardGridController {    
    
    
    @AuraEnabled
    public static Date getToDayDate(){
        date d = System.today();
        return d;//return today date
    }
   
    @AuraEnabled
    public static Date generateWeekStartDate(Date selDate){
          
          Integer numberOfDays ; 
          Date startDate;
          Date weekStart = selDate.toStartofWeek();
          numberOfDays = 0;
          Datetime dt = datetime.newInstance(weekStart.year(), weekStart.month(),weekStart.day());
          
          
          if(dt.format('EEE').tolowercase() == 'sun'){      
              if(selDate == selDate.toStartofWeek()){
                  numberOfDays  = -6;
              }else{     
                  numberOfDays = 1;
              }     
          }else if(dt.format('EEE').tolowercase() == 'sat'){
              if(selDate == selDate.toStartofWeek()){
                  numberOfDays  = -5;
              }else{     
                  numberOfDays = 2;
              }  
              
          }          
          startDate  = weekStart.addDays(numberOfDays);
          return startDate;         
    }
    
    @AuraEnabled
    public static List<Assignment__c> getActiveAssignment(Date selDate) {
        Date startDate = generateWeekStartDate(selDate);
        Date endDate = startDate.addDays(6);
          
        //get current user
        List<User> UserList = new List<User>([SELECT Id, ContactId FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1]);
        
        
        //return all active assignments
        return [SELECT id, Start_Date__c, End_Date__c, Project__c, Project__r.Require_Stories_on_Time_Entries__c, Project__r.Name,  Role__c, Assignment_Type__c, Project__r.Account__r.Most_Recent_Billing_Period_End_Date__c,
                Resource__c, (SELECT id, Assignment__c, Date__c,  Description__c, Hours__c, Story__c, Task__c 
                            FROM Time_Entries__r WHERE Date__c >=: startdate and Date__c <=: enddate)
                FROM Assignment__c WHERE Status__c = 'Active' And Resource__c = :UserList[0].ContactId ORDER BY NAME];
    }
    
    @AuraEnabled
    public static List<AssigAndTimeWrapper> getwrapp (String day, String month, String year) {
        Date selDate = datetime.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day)).date();
        //get all active assignment
        

        List<Assignment__c> ActiveAssignmentsList = getActiveAssignment(selDate);        
        
        //lst of current week                                                       
        List<weekWrapper> WeekWrapperList = getCurrentWeek (String.valueOf(selDate.day()), String.valueOf(selDate.month()), String.valueOf(selDate.year())) ;
           
        //temp current week lst
        List<TimeEntryWrapper> tempTimeEntryList ;
        
        //lst wrapper time entry
        List<AssigAndTimeWrapper> wrappTimeList = new List<AssigAndTimeWrapper>();
        
       
        //Boolean
        Boolean isEdit ;
        
        //temp time entry map
        Map<String, List<Time_Entry__c>> tempmap;
        for(Assignment__c ass : ActiveAssignmentsList){            
            tempmap = new Map<String, List<Time_Entry__c>>();
            tempTimeEntryList = new List<TimeEntryWrapper>();

            
            for(Time_Entry__c te:ass.Time_Entries__r){                
                List<Time_Entry__c> relTimeList = new List<Time_Entry__c>();
                String dteString = te.Date__c.format(); 
                if(tempmap.containsKey(dteString))
                    relTimeList.addAll(tempmap.get(dteString));
                
                relTimeList.add(te);                
                tempmap.put(dteString,relTimeList);
            }
            Date toDayDate = selDate;
            //Sunday Date
           // Date weekStart = toDayDate.toStartofWeek();
            
            Date weekStart = generateWeekStartDate(selDate);
            weekStart = weekStart.addDays(-1);
            
            
            
            for(Integer i=1;i<8;i++){
                //isEdit
                if( ass.Project__r.Account__r.Most_Recent_Billing_Period_End_Date__c != null){
                    isEdit = (ass.Project__r.Account__r.Most_Recent_Billing_Period_End_Date__c <  Date.parse(WeekWrapperList[i].Date1) &&  ass.Start_Date__c <= Date.parse(WeekWrapperList[i].Date1) && ass.End_Date__c >= Date.parse(WeekWrapperList[i].Date1));
                }
                else{
                    isEdit = (ass.Start_Date__c <= Date.parse(WeekWrapperList[i].Date1) && ass.End_Date__c >= Date.parse(WeekWrapperList[i].Date1));
                }
                
                Date theDay = Date.parse(WeekWrapperList[i].Date1);
                if(tempmap.containsKey(WeekWrapperList[i].Date1)){
                    
                    tempTimeEntryList.add(new TimeEntryWrapper(tempmap.get(WeekWrapperList[i].Date1),theDay,WeekWrapperList[i].Name,ass.id, isEdit));        
                }
                else{
                    Time_Entry__c  te = new Time_Entry__c(Assignment__c=ass.id,date__c= weekStart.addDays(i));
                    tempTimeEntryList.add(new TimeEntryWrapper(new List<Time_Entry__c>{te},theDay,WeekWrapperList[i].Name,ass.id, isEdit));        
                }
            }
            wrappTimeList.add(new AssigAndTimeWrapper(ass,tempTimeEntryList));
            
        }
            List<AssigAndTimeWrapper> tmpWrapperList = new List<AssigAndTimeWrapper>(wrappTimeList);
            wrappTimeList = filterAssignAndTimeProjectRoleWise(wrappTimeList);
        return wrappTimeList;
    }

    public static List<AssigAndTimeWrapper> filterAssignAndTimeProjectRoleWise(List<AssigAndTimeWrapper> wrappAssignTimeList ){
        List<AssigAndTimeWrapper> tmpWrapperList = new List<AssigAndTimeWrapper>();
        
        Map<String,AssigAndTimeWrapper> tmpWrappermap = new Map<String,AssigAndTimeWrapper>();
        for(AssigAndTimeWrapper wrapper : wrappAssignTimeList) {
            String ckey = wrapper.ass.Project__c + '_' + wrapper.ass.Role__c ;
            List<TimeEntryWrapper> tmp = wrapper.TimeEntryList ;
            if(tmpWrappermap.containsKey(ckey)){
                List<TimeEntryWrapper> timeEntryWrapper = new List<TimeEntryWrapper>();
                List<TimeEntryWrapper> timeEntryList = tmpWrappermap.get(ckey).TimeEntryList ;
                for(Integer i = 0; i < 7; i++){
                    if((timeEntryList[i].isEdit != tmp[i].isEdit) && (tmp[i].isEdit)) { 
                        timeEntryList[i] = tmp[i];
                    }
                    timeEntryWrapper.add(timeEntryList[i]);
                }
                wrapper.TimeEntryList = new List<TimeEntryWrapper>(timeEntryWrapper) ; 
            }
                
            tmpWrappermap.put(ckey,wrapper);        
        }
        for(String s : tmpWrappermap.keySet()) {
            tmpWrapperList.add(tmpWrappermap.get(s));
        }
        return tmpWrapperList ;
    }
    
    @AuraEnabled
    public static List<weekWrapper> getCurrentWeek (String day, String month, String year){
        Date selDate = datetime.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day)).date();
        //getting date for monday as starting date
        Date weekStart = generateWeekStartDate(selDate);
        
        List<String> weekDaysList = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'};
        LIst<String> monthList = new List<String>{'Jan','Feb','Mar','April','May','June','July','Aug'
                      ,'Sept','Oct','Nov','Dec'};
        List<weekWrapper> WeekWrapperList = new List<weekWrapper>();
        WeekWrapperList.add(new weekWrapper('ACTIVE ASSIGNMENTS','',''));
        
        for(Integer i=0 ; i<7 ; i++){
            String thedate = weekStart.addDays(i).format(); 
            String formatedDate= monthList[ weekStart.addDays(i).month() - 1] +', '+weekStart.addDays(i).day();
            WeekWrapperList.add(new weekWrapper(weekDaysList[i],thedate,formatedDate));            
        }
        return WeekWrapperList;
    }
    @AuraEnabled
    public static List<StoryTaskWrapper> getUserStories(String projectId)
    {
        String currentUserId = UserInfo.getUserId();
        List<StoryWrapper> storyWrapperList = new List<StoryWrapper>();
        List<TaskWrapper> taskWrapperList = new List<TaskWrapper>();
        List<StoryTaskWrapper> storyTaskWrapperList = new List<StoryTaskWrapper>();
        Map<String, List<TaskWrapper>> storyToTaskMap = new Map<String, List<TaskWrapper>>();
        String storyName;
        String taskName;
        List<Story__c> storyList = [SELECT Id, Name, Story_Name__c, 
                                        (SELECT Id, Name, Task_Name__c FROM Tasks__r) 
                                    FROM Story__c 
                                    WHERE Project__c =: projectId 
                                    ORDER BY LastViewedDate DESC];
        for(Story__c storyRec : storyList)
        {
            if((storyRec.Story_Name__c).length() > 40)
            {
                storyName = storyRec.Name+' - '+(storyRec.Story_Name__c).substring(0, 40);
                storyWrapperList.add(new StoryWrapper(storyRec.Id, storyName));
            }
            else
            {
                storyName = storyRec.Name+' - '+storyRec.Story_Name__c;
                storyWrapperList.add(new StoryWrapper(storyRec.Id, storyName));
            }
            taskWrapperList = new List<TaskWrapper>();
            for(Task__c taskRec : storyRec.Tasks__r)
            {
                if((taskRec.Task_Name__c).length() > 40)
                {
                    taskName = taskRec.Name+' - '+(taskRec.Task_Name__c).substring(0, 40);
                    taskWrapperList.add(new TaskWrapper(taskRec.Id, taskName));
                }
                else
                {
                    taskName = taskRec.Name+' - '+taskRec.Task_Name__c;
                    taskWrapperList.add(new TaskWrapper(taskRec.Id, taskName));
                }
            }
            storyToTaskMap.put(storyRec.Id, taskWrapperList);
        }
        storyTaskWrapperList.add(new StoryTaskWrapper(storyWrapperList, storyToTaskMap));
        return storyTaskWrapperList;
    }
    @AuraEnabled
    public static List<TaskWrapper> getStoryTasks(String storyId)
    {
        String selectedStoryId = storyId;
        String taskName;
        List<TaskWrapper> taskWrapperList = new List<TaskWrapper>();
        List<Task__c> taskList = [SELECT Id, Name, Task_Name__c FROM Task__c WHERE Story__c =: selectedStoryId];
        for(Task__c taskRec : taskList)
        {
            if((taskRec.Task_Name__c).length() > 40)
            {
                taskName = taskRec.Name+' - '+(taskRec.Task_Name__c).substring(0, 40);
                taskWrapperList.add(new TaskWrapper(taskRec.Id, taskName));
            }
            else
            {
                taskName = taskRec.Name+' - '+taskRec.Task_Name__c;
                taskWrapperList.add(new TaskWrapper(taskRec.Id, taskName));
            }
        }
        return taskWrapperList;
    }
    //Task Wrapper
    public class TaskWrapper
    {
        @AuraEnabled public String recId {get; set;}
        @AuraEnabled public String recName {get; set;}

        public TaskWrapper(String recId, String recName)
        {
            this.recId = recId;
            this.recName = recName;
        }
    }
    //Stories Wrapper
    public class StoryWrapper
    {
        @AuraEnabled public String recId {get; set;}
        @AuraEnabled public String recName {get; set;}

        public StoryWrapper(String recId, String recName)
        {
            this.recId = recId;
            this.recName = recName;
        }
    }
    //Stories-Task Wrapper
    public class StoryTaskWrapper
    {
        @AuraEnabled public List<StoryWrapper> storyWrapperList {get; set;}
        @AuraEnabled public Map<String, List<TaskWrapper>> storyToTaskMap {get; set;}
        public StoryTaskWrapper(List<StoryWrapper> storyWrapperList, Map<String, List<TaskWrapper>> storyToTaskMap)
        {
            this.storyWrapperList = storyWrapperList;
            this.storyToTaskMap = storyToTaskMap;
        }
    }
    //wrapper current week date and day
    public class weekWrapper {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Date1;
        @AuraEnabled
        public String formatedDate;
        public weekWrapper (String n, String d,String f){
            Name=n;
            Date1=d;
            formatedDate= f;
        }
    }
    //wrapper active assignmet and related time entry
    public class AssigAndTimeWrapper{
        @AuraEnabled
        public Assignment__c ass ;
        @AuraEnabled
        public List<TimeEntryWrapper> TimeEntryList;
        public AssigAndTimeWrapper(Assignment__c a, List<TimeEntryWrapper> l){
            ass = a ;
            TimeEntryList = l ;           
        }
    }
    //wrapper time entry 
    public class TimeEntryWrapper{
        @AuraEnabled
        public List<Time_Entry__c> tymEnry;
        @AuraEnabled
        public Date RelDate;
        @AuraEnabled
        public ID assID;
        @AuraEnabled
        public String dayName ;    
        @AuraEnabled
        public Decimal totOfTimeEnries;
        @AuraEnabled
        public Boolean isEdit ;
        public TimeEntryWrapper(List<Time_Entry__c> t,Date d,String name,ID i,Boolean is){
            isEdit = is;
            tymEnry = t;
            RelDate = d;
            assID = i;
            dayName = name;       
            totOfTimeEnries= 0;
            for(Time_Entry__c tym :tymEnry){
                if(tym.Hours__c != null ){
                    totOfTimeEnries += tym.Hours__c ;
                }
            }
                
        }
    }
    @AuraEnabled 
    public static Time_Entry__c[]  submitSave(Time_Entry__c[]  TimeEntry){    
        List<Time_Entry__c> tymList = new List<Time_Entry__c>();
        for(object sobj :TimeEntry){
            tymList.add((Time_Entry__c)sobj);
        }
        
        upsert tymList ;
        return tymList ;
    }
    
}