public with sharing class CreateCaseCommentTriggerHandler 
{
	public static void copyEmailMessagesToCaseComments(List<EmailMessage> emails)
	{
		List<CaseComment> comments        = new List<CaseComment>();
        Map<String, Id> caseNumberToIdMap = new Map<String, Id>();
        Set<String> caseNumberSet         = new Set<String>();
        Set<String> userEmailSet          = new Set<String>();
        Map<String, Id> createdByUserEmailToIdMap   = new Map<String, Id>();
        Id caseId;
        String threadId;

        for(EmailMessage email:emails)
        {
            if((email.Subject).contains('10K Case number'))
            {
                String str          = email.Subject;
                Integer indx        = str.indexOf('10K Case number');
                Integer indxStart   = indx + 16;
                Integer indxEnd     = indx + 24;
                String caseNum      = str.substring(indxStart,indxEnd);
                caseNumberSet.add(caseNum);
                userEmailSet.add(email.FromAddress);
            }
        }
        if(!userEmailSet.isEmpty())
        {
            for(User userRec : [SELECT Id, Email, Contact.Email FROM User WHERE Email IN: userEmailSet OR Contact.Email IN: userEmailSet])
            {
                if(userEmailSet.contains(userRec.Email))
                {
                    createdByUserEmailToIdMap.put(userRec.Email, userRec.Id);
                }
                else
                {
                    createdByUserEmailToIdMap.put(userRec.Contact.Email, userRec.Id);
                }
            }
        }
        if(!caseNumberSet.isEmpty())
        {
            for(Case caseObj : [SELECT Id, CaseNumber FROM Case WHERE CaseNumber IN : caseNumberSet])
            {
                caseNumberToIdMap.put(caseObj.CaseNumber, caseObj.Id);
            }
        }
        if(!caseNumberToIdMap.isEmpty())
        {
            for(EmailMessage email:emails)
            {
                if((email.Subject).contains('10K Case number'))
                {
                    String str          = email.Subject;
                    Integer indx        = str.indexOf('10K Case number');
                    Integer indxStart   = indx + 16;
                    Integer indxEnd     = indx + 24;
                    String caseNum      = str.substring(indxStart,indxEnd).trim();
                    caseId              = caseNumberToIdMap.get(caseNum);
                    threadId            = getThreadId((String)caseId);
                }
                if(email.TextBody != null && threadId != null && email.TextBody.contains(threadId))
                {
                    caseId = email.ParentId;
                    CaseComment comment = new CaseComment(ParentId = caseId);
                    comment.IsPublished = true;
                    String header = 'From: '+ email.FromName + ' <' + email.FromAddress + '>\n';
                    header += 'To: '+ email.ToAddress + '\n';
                    header += email.CcAddress!=null?'CC: '+ email.CcAddress + '\n\n':'\n';
                    if (email.TextBody != null) 
                    {
                        if(email.TextBody.contains('From: noreply@salesforce.com [mailto:noreply@salesforce.com] On Behalf Of 10K DoubleClick Support'))
                        {
                            comment.CommentBody = email.TextBody.substringBefore('From: noreply@salesforce.com [mailto:noreply@salesforce.com] On Behalf Of 10K DoubleClick Support');
                        }
                        else
                        {
                            comment.CommentBody = email.TextBody.substringBefore('wrote:');
                        }
                    } 
                    else if (email.HtmlBody != null) 
                    {
                      comment.CommentBody = email.HtmlBody.replaceAll('\\<.*?>','');
                    }
                    comment.CreatedById = createdByUserEmailToIdMap.get(email.FromAddress);
                    comments.add(comment);
                }
            }
        }
        
        if (!comments.isEmpty())
        {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation = true;
            Database.insert(comments, dml);
        }
	}

    private static String getThreadId(String caseId)
    {
        return 'ref:_' 
            + UserInfo.getOrganizationId().left(5) 
            + '' 
            + UserInfo.getOrganizationId().mid(11,4) + '._' 
            + caseId.left(5) + '' 
            + caseId.mid(10,5) + ':ref';
    }
}