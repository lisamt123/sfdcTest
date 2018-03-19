/**
*   Name          : MockResponseCallout 
*   Dated         : 4 July, 2016
*   Author        : BM
*   Useges        : Used to return mock response. 
*/
@isTest
global class MockResponseCallout implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint().contains('http://certification.salesforce.com/verification-email?init=1&email') ) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('<span class="name">name</span><span class="name">Matthew Lamb</span><a href="/certification-detail?conId=testtesttest" class="btn btn-small fancybox fancybox.iframe">');
            res.setStatusCode(200);
            return res;
        }
        else if(req.getEndpoint().contains('http://certification.salesforce.com/certification-detail?conId=')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('<span id="cert-name" class="credential" data-full-name="gaurav nirwal" data-conid="testtesttest">Salesforce Certified Administrator</span><span class="date-certified">April 30, 2011 </span>');
            res.setStatusCode(200);
            return res;
        }
        else if(req.getEndpoint().contains('https://trailhead.salesforce.com/me/')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String resBody = '<title>Salesforce Trailhead &#124; Becca Lammers&#39;s Profile</title>'+'<div data-react-class="profile/UserBio" data-react-props="{&quot;full_name&quot;:&quot;Ankit Sharma&quot;,&quot;work_info&quot;:&quot;Briskminds&quot;,&quot;bio&quot;:null}"><div class="user-information__bio" data-reactroot="" data-reactid="1" data-react-checksum="-1052747598"><h1 data-test-user-name="true" data-reactid="2">Ankit Sharma</h1><h2 data-test-user-work-info="true" data-reactid="3">Briskminds</h2><p data-test-user-bio="true" data-reactid="4"></p></div>'+'<div data-react-class="BadgesPanel" data-react-props="{&quot;badges&quot;:[{&quot;user_id&quot;:5324917,&quot;api_name&quot;:&quot;visualforce_fundamentals&quot;,&quot;state&quot;:&quot;Completed&quot;,&quot;last_attempted_at&quot;:&quot;2017-06-05T03:43:32.730-07:00&quot;,&quot;finished_at&quot;:&quot;2017-06-05T03:43:35.089-07:00&quot;,&quot;created_at&quot;:&quot;2017-06-02T03:51:36.595-07:00&quot;,&quot;updated_at&quot;:&quot;2017-06-05&quot;,&quot;type&quot;:&quot;Th::UserModule&quot;,&quot;drm_synced&quot;:true,&quot;drm_last_sync_attempt&quot;:&quot;2017-09-20T11:17:39.489-07:00&quot;,&quot;path&quot;:&quot;/modules/visualforce_fundamentals&quot;,&quot;badge_type&quot;:&quot;module&quot;,&quot;icon_url&quot;:&quot;https://developer.salesforce.com/resource/images/trailhead/badges/modules/trailhead_module_visualforce_basics.png&quot;,&quot;title&quot;:&quot;Visualforce Basics&quot;,&quot;progress&quot;:100,&quot;tags&quot;:[&quot;module&quot;],&quot;points&quot;:4100,&quot;employee&quot;:false,&quot;private&quot;:false,&quot;linkedin_share&quot;:null,&quot;chatter_share&quot;:&quot;/share/chatter/module/visualforce_fundamentals&quot;,&quot;google_share&quot;:{&quot;contenturl&quot;:&quot;https://trailhead.salesforce.com/modules/visualforce_fundamentals&quot;,&quot;clientid&quot;:&quot;567293635236-pni7pm941i8p6td5380rnpq9ivkut5vr.apps.googleusercontent.com&quot;,&quot;cookiepolicy&quot;:&quot;single_host_origin&quot;,&quot;prefilltext&quot;:&quot;Just earned the Visualforce Basics badge on Trailhead, the fun way to learn Salesforce!&quot;,&quot;calltoactionurl&quot;:&quot;https://trailhead.salesforce.com/modules/visualforce_fundamentals&quot;},&quot;twitter_share&quot;:&quot;http://twitter.com/share?url=https%3A%2F%2Ftrailhead.salesforce.com%2Fmodules%2Fvisualforce_fundamentals\u0026text=Just+earned+the+Visualforce+Basics+badge+on+%40Trailhead+and+you+should+too%21\u0026title=Visualforce+Basics&quot;,&quot;facebook_share&quot;:&quot;https://www.facebook.com/dialog/share?app_id=140586622674265\u0026display=popup\u0026href=https%3A%2F%2Ftrailhead.salesforce.com%2Fmodules%2Fvisualforce_fundamentals\u0026quote=Just+earned+the+Visualforce+Basics+badge+on+%40Salesforce+Trailhead%21+Beary+proud+of+this+badge%21+Goat+check+it+out%2C+owl+wait%21&quot;}],&quot;sharing&quot;:false,&quot;chatter&quot;:false}"></div>';               
            res.setBody(resBody);
            res.setStatusCode(200);
            return res;
        }
        else if(req.getEndpoint().contains('https://login.salesforce.com')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String resBody = '{"access_token" : "Test", ' +
                               '"refresh_token" : "Test", ' +
                               '"signature" : "Test", ' +
                               '"id_token" : "Test" , ' +
                               '"scope" : "Test", ' +
                               '"instance_url" : "Test", ' +
                               '"id" : "Test", ' +
                               '"token_type" : "Test", ' +
                               '"issued_at" : "Test" ' +
                              '}';
            res.setBody(resBody);
            res.setStatusCode(200);
            System.debug('Goes here or not : '+resBody);
            return res;         
        }
        else
             return null;
    }
}