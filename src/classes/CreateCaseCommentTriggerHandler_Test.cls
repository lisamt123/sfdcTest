@isTest
private class CreateCaseCommentTriggerHandler_Test 
{
	
	@isTest static void test_CreateCaseCommentTriggerHandler() 
	{
		Case c1 = new Case(Subject='blah');
        insert c1;
        String caseId = c1.Id;
        String caseNum = [SELECT Id, CaseNumber FROM Case WHERE Id =: c1.Id].CaseNumber;
        String threadId = 'ref:_' 
                            + UserInfo.getOrganizationId().left(5) 
                            + '' 
                            + UserInfo.getOrganizationId().mid(11,4) + '._' 
                            + caseId.left(5) + '' 
                            + caseId.mid(10,5) + ':ref';

        List<EmailMessage> emails = new List<EmailMessage>();
        String str = 'Soooo, did you see the Warriors game last night? Crazy, right? It was nice to see Harrison Barnes back and the entire crowd cheered when he entered the game. Steph Curry is probably not human,'+
                        ' because he shoots the ball from the parking lot and it swishes like butter. How many characters am I up to now? Lemme check, so hold on Anyways, then it started raining today and my dogs don’t'+
                        ' like rain so it’s really difficult to take them outside to do their business in the morning when they don’t want to deal with the rain. I try to talk them into the fact that they’re actually'+
                        ' getting a bath and pooping at the same time, kind of a two birds with one stone thing. They don’t buy it. Speaking of rain, it didn’t rain on my wedding day like the weather people thought it'+
                        ' would. How do they keep their jobs when they’re wrong all of the time? It’s almost like they could do my job. Wait, I didn’t mean that how it sounded. Where are we at now Did you see the President'+
                        ' speak about gun control today? It’s important. Probably the most important problem of our time and we have to solve it. Here’s what he said today Soooo, did you see the Warriors game last night?'+
                        ' Crazy, right? It was nice to see Harrison Barnes back and the entire crowd cheered when he entered the game. Steph Curry is probably not human, because he shoots the ball from the parking lot and'+
                        ' it swishes like butter. How many characters am I up to now? Lemme check, so hold on Anyways, then it started raining today and my dogs don’t like rain so it’s really difficult to take them outside'+
                        ' to do their business in the morning when they don’t want to deal with the rain. I try to talk them into the fact that they’re actually getting a bath and pooping at the same time, kind of a two birds'+
                        ' with one stone thing. They don’t buy it. Speaking of rain, it didn’t rain on my wedding day like the weather people thought it would. How do they keep their jobs when they’re wrong all of the time?'+
                        ' It’s almost like they could do my job. Wait, I didn’t mean that how it sounded. Where are we at now Did you see the President speak about gun control today? It’s important. Probably the most important'+
                        ' problem of our time and we have to solve it. Here’s what he said today Soooo, did you see the Warriors game last night? Crazy, right? It was nice to see Harrison Barnes back and the entire crowd'+
                        ' cheered when he entered the game. Steph Curry is probably not human, because he shoots the ball from the parking lot and it swishes like butter. How many characters am I up to now? Lemme check,'+
                        ' so hold on Anyways, then it started raining today and my dogs don’t like rain so it’s really difficult to take them outside to do their business in the morning when they don’t want to deal with'+
                        ' the rain. I try to talk them into the fact that they’re actually getting a bath and pooping at the same time, kind of a two birds with one stone thing. They don’t buy it. Speaking of rain, it didn’t'+
                        ' rain on my wedding day like the weather people thought it would. How do they keep their jobs when they’re wrong all of the time? It’s almost like they could do my job. Wait, I didn’t mean that how'+
                        ' it sounded. Where are we at now Did you see the President speak about gun control today? It’s important. Probably the most important problem of our time and we have to solve it. Here’s what he said'+
                        ' today Soooo, did you see the Warriors game last night? Crazy, right? It was nice to see Harrison Barnes back and the entire crowd cheered when he entered the game. Steph Curry is probably not human,'+
                        ' because he shoots the ball from the parking lot and it swishes like butter. How many characters am I up to now? Lemme check, so hold on Anyways, then it started raining today and my dogs don’t like'+
                        ' rain so it’s really difficult to take them outside to do their business in the morning when they don’t want to deal with the rain. I try to talk them into the fact that they’re actually getting a bath'+
                        ' and pooping at the same time, kind of a two birds with one stone thing. They don’t buy it. Speaking of rain, it didn’t rain on my wedding day like the weather people thought it would. How do they'+
                        ' keep their jobs when they’re wrong all of the time? It’s almost like they could do my job. Wait, I didn’t mean that how it sounded. Where are we at now Did you see the President speak about gun control'+
                        ' today? It’s important. Probably the most important problem of our time and we have to solve it. Here’s what he said today';
        emails.add(new EmailMessage(ParentId=c1.Id,FromAddress='yo@yo.com',FromName='Yo',Subject='10K Case number '+caseNum,TextBody=str+'TextBody> wrote:'+threadId,ToAddress='to@to.com', Incoming=True));
        emails.add(new EmailMessage(ParentId=c1.Id,FromAddress='yo@yo.com',FromName='Yo',Subject='10K Case number '+caseNum,HtmlBody='<b>HtmlBody</b><i>more</i>',ToAddress='to@to.com', Incoming=True));
        insert emails;
        
        List<CaseComment> comments = [select Id,CommentBody from CaseComment where ParentId=:c1.Id];
        System.assert(comments.size() == 1);
        
        for (CaseComment comment:comments) 
        {
          System.debug(comment.CommentBody);
          System.assert(comment.CommentBody!=null && comment.CommentBody!='');
        }
    }
}