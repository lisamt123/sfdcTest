/**
*   Name          : MockResponse_HerokuConnection 
*   Dated         : 30 March, 2017
*   Author        : BM
*   Useges        : Used to return mock response. 
*/
@isTest
global class MockResponse_HerokuConnection implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) 
    {
        Organization orgz = [SELECT IsSandbox FROM Organization LIMIT 1];
        Heroku_oAuth_Setting__mdt credentials = [SELECT ID, QualifiedApiName, Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
                
        Map<String, String> herokuEndpointsMap = new Map<String, String>();   
        
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
        }
        
        if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Delete'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Connection deleted Successfully.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;            
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Create'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Connection created successfully","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Update'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Connection updated successfully","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Metadata'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","metadataList":[{"metadataName":[{"name":"Test2","action":"upsert","artifactId":"123"},{"name":"Test2","action":"upsert","artifactId":"123"},{"name":"Test1","action":"upsert","artifactId":"123"}],"metadataType":"ApexPage"},{"metadataName":[{"name":"Test2","action":"upsert","artifactId":"123"},{"name":"Test2","action":"upsert","artifactId":"123"},{"name":"Test1","action":"upsert","artifactId":"123"}],"metadataType":"ApexClass"}]}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_MetadataType_Artifact'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"artifactList":[{"artifactSource":"TeatClass","compareStatus":"false","artifactTarget":""}],"status":"Success"}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }  
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_MetadataTypes'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"status":"Success","logTime":"2018-03-01 09:21:49.482","runningStatus":"Completed","metadataList":["ApexClass"]}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
         else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_ArtifactData'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"targetArtifactData":"global class MyClass{}","status":"Success","sourceArtifactData":"global class MyClass{}"}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Compare'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"status":"Success","message":"Request to compare Salesforce org has been send successfully."}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_CodeReview'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Request for scan has been sent successfully.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_ScanResult'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","LogIssue":[{"artifactType":"ApexClass","lineNo":"1","artifactName":"AccountTest","violation":"Avoid using global modifier","severity":"Low"}]}';
            res.setBody(resBody);  
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_ReviewLogs'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","Log":[{"logId":"20170920131951699","status":"Violation","logTime":"2017-09-20 13:19:51.699"}]}';
            res.setBody(resBody);   
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Permission_Retrieve'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"permissionList":[{"deployRelease":true,"contactId":"a1I2C0000009jFDAAA","connectionId":"a1I2C0000009jFDAAA","validateRelease":false}],"status":"Success"}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Permission'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Permission successfully added to Connection.","status":"Success"}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_AccessToken'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Access token retrieved successfully.","status":"Success","accessToken":"A123efgr111453assfdc"}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }

        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_StoriesArtifacts_Retrieve'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","ReleaseStories":[{"storyId":"a0X2C000000E9zIUAS","artifacts":[{"metadataName":[{"name":"Test","action":"upsert","artifactId":"233"}],"metadataType":"ApexClass"}]},{"storyId":"","artifacts":[{"metadataName":[{"name":"Test","action":"upsert","artifactId":"233"},{"name":"ApexTest","action":"upsert","artifactId":"150"}],"metadataType":"ApexClass"}]}]}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Story'))) {  
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","metadataList":[{"metadataName":[{"name":"Service_Test","action":"upsert","artifactId":"173"}],"metadataType":"ApexClass"}]}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Artifacts_Retrieve'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"artifact":{"artifactPackageXML":[{"metadataName":["AmazonS1"],"metadataType":"ApexClass"}],"artifactDestructiveXML":[{"metadataName":["AmazonS2"],"metadataType":"ApexClass"}]},"status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Artifact'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"connectionIdList":["a5Z2C011000M6ZdAAA","a5Z2C011000M6ZdBBB"],"message":"Release Artifact updated successfully.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_StoriesArtifacts_Create'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Release Stories and Artifacts updated successfully.","storyList":["TEST0000K2JOUA0"],"status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_Releases_Retrieve'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            Story__c story = [SELECT Id FROM Story__c];
            String resBody = '{"releaseList":["a1I2C0001239jAAAAA","a1I2C0001239jAAAAA"],"status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200);  
            return res;             
        }
        
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_UpdateStoryArtifactsOnRelease'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            Story__c story = [SELECT Id FROM Story__c];
            String resBody = '{"message":"Story artifacts successfully updated on Release.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_Releases_Migrate'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            Story__c story = [SELECT Id FROM Story__c];
            String resBody = '{"message":"Story artifacts successfully added to Release.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }

        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_Artifacts_Retrieve'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            Story__c story = [SELECT Id FROM Story__c];
            String resBody = '{"Status":"Success","metadataList":[{"metadataName":[{"name":"Service_Test","action":"upsert","artifactId":"173"}],"metadataType":"ApexClass"}]}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_Artifacts_Create'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"connectionIdList":["a5Z2C011000M6ZdAAA","a5Z2C011000M6ZdBBB"],"message":"Story Artifact updated successfully.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_Delete'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Story deleted Successfully.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }

        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Validate_Progress'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"status":"Success","runningStatus":"Completed","validationProgress":{"numberComponentsTotal":42,"numberTestErrors":0,"numberComponentErrors":40,"numberTestsTotal":0,"numberTestsCompleted":0,"numberComponentsDeployed":2,"pollTime":5}}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Validate_Deployment'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200);   
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Deployment_Issues'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","validationProgress":{"numberComponentsTotal":42,"numberTestErrors":0,"numberComponentErrors":40,"numberTestsTotal":0,"numberTestsCompleted":0,"numberComponentsDeployed":2}, "testLevel":"Run Specified Tests","specifiedTests":["ATest","BTest"] ,"LogIssue":[{"description":"package.xml - Entity of type Type named TEST cannot be found","type":"Warning"}],"metadataList":[{"metadataName":[{"name":"ChangePasswordController","action":"upsert"}],"metadataType":"ApexClass"}]}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Deployment_Logs'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","validateRelease":"true","deployRelease":"true","targetRecentDeployTime":"2017-09-20 13:19:51.699","testLevel":"Default","validationProgress":{"numberComponentsTotal":42,"numberTestErrors":0,"numberComponentErrors":40,"numberTestsTotal":0,"numberTestsCompleted":0,"numberComponentsDeployed":2},"Log":[{"logId":"20170920131951699","status":"Failed","logTime":"2017-09-20 13:19:51.699","action":"validate", "sourceConnection":"a1c2C0000123qLZAAA", "targetConnection":"a1c2C0000123qLZAAA" ,"asyncResultId":"a1c2C0000123qLZAAA", "testsEnabled":"true"}]}'; 
            res.setBody(resBody);   
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Delete'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Release deleted Successfully.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c +  herokuEndpointsMap.get('Release_Clone'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Release cloned successfully","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_CodeReview'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Request for scan has been sent successfully.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_ScanResult'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","LogIssue":[{"artifactType":"ApexClass","lineNo":"1","artifactName":"AccountTest","violation":"Avoid using global modifier","severity":"Low"}]}';
            res.setBody(resBody);  
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_ReviewLogs'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","Log":[{"logId":"20170920131951699","status":"Violation","logTime":"2017-09-20 13:19:51.699"}]}';
            res.setBody(resBody);   
            res.setStatusCode(200); 
            return res;             
        }
        
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Project_ReviewLogs'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","ReleaseLog":[{"releaseId":"a1I2C0000009jFDAAA","releaseName":"TestReleaseAmit"}]}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Project_ConnectionPermission_Retrieve'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"permissionList":[{"deployRelease":true,"contactId":"a1I2C0000009jFDAAA","connectionId":"a1I2C0000009jFDAAA","validateRelease":false}],"status":"Success"}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Project_ConnectionPermission'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Permission successfully added to Project.","status":"Success"}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        
        
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Project_Code_Severity_Retrieve'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"ruleList":[{"ruleName":"Avoid deeplu nested Ie..else","ruleSeverity":"High","ruleState":"Active"}],"status":"Success"}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Project_Code_Severity_Create'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Project code severity updated successfully.","status":"Success"}';
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }  
        
        
        
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Update'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Release updated successfully","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Create'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Release created successfully","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_CodeReview'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json');  
            String resBody = '{"message":"Request for scan has been sent successfully.","status":"Success"}'; 
            res.setBody(resBody); 
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_ScanResult'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","LogIssue":[{"artifactType":"ApexClass","lineNo":"1","artifactName":"AccountTest","violation":"Avoid using global modifier","severity":"Low"}]}';
            res.setBody(resBody);  
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_ReviewLogs'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"Status":"Success","Log":[{"logId":"20170920131951699","status":"Violation","logTime":"2017-09-20 13:19:51.699"}]}';
            res.setBody(resBody);   
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains(herokuEndpointsMap.get('Github_Repo_Endpoint'))) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '[{"id":121208655,"name":"12feb","full_name":"aparbriskminds/12feb","url":"https://api.github.com/repos/aparbriskminds/12feb","contents_url":"https://api.github.com/repos/aparbriskminds/12feb"}]';
            res.setBody(resBody);   
            res.setStatusCode(200); 
            return res;             
        }
        else if(req.getEndpoint().contains('/contents/src/package.xml')) { 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            String resBody = '{"message":"Not Found","documentation_url":"https://developer.github.com/v3/repos/contents/#get-contents"}';
            res.setBody(resBody);   
            res.setStatusCode(200); 
            return res;             
        }
        else {
            return null;
        } 
    }
}