public with sharing class TestDataFactory_CustomSettings {
    
    public static List<Countries_Regions_Continents_ISO_Codes__c> generateCountriesRegionsContinentsISOCodes(String continent, String country, String ISO2, String ISO3, String Region, Integer numOfRecords) {
        return generateCountriesRegionsContinentsISOCodesInternal(continent, country, ISO2, ISO3, Region, numOfRecords);
    }
    
    private static List<Countries_Regions_Continents_ISO_Codes__c> generateCountriesRegionsContinentsISOCodesInternal(String continent, String country, String ISO2, String ISO3, String Region, Integer numOfRecords) {
        
        List<Countries_Regions_Continents_ISO_Codes__c> countriesRegionsContinentsISOCodesList = new List<Countries_Regions_Continents_ISO_Codes__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            Countries_Regions_Continents_ISO_Codes__c crcISOcode = new Countries_Regions_Continents_ISO_Codes__c();
            crcISOcode.Name          = country;
            crcISOcode.Continent__c  = continent;
            crcISOcode.Country__c    = country;
            crcISOcode.ISO_2__c      = ISO2;
            crcISOcode.ISO_3__c      = ISO3;
            crcISOcode.Region__c     = Region;
            countriesRegionsContinentsISOCodesList.add(crcISOcode);
        }
        
        return countriesRegionsContinentsISOCodesList;
    }
    
    public static void initializeEndpointURIsCustomSetting() {
        try {
            Endpoint_URIs__c customSetting                          = Endpoint_URIs__c.getOrgDefaults();
            customSetting.TrailheadBadges_URI_Trailhead__c          = 'https://trailhead.salesforce.com/me/';
            customSetting.ContactId_URI_Salesforce_Certificate__c   = 'http://certification.salesforce.com/verification-email?init=1&email=';
            customSetting.SalesforceCertificates_URI__c             = 'http://certification.salesforce.com/certification-detail?conId=';
            update customSetting;
        }
        catch (Exception ex) {
            Endpoint_URIs__c customSetting                          = new Endpoint_URIs__c();
            customSetting.TrailheadBadges_URI_Trailhead__c          = 'https://trailhead.salesforce.com/me/';
            customSetting.ContactId_URI_Salesforce_Certificate__c   = 'http://certification.salesforce.com/verification-email?init=1&email=';
            customSetting.SalesforceCertificates_URI__c             = 'http://certification.salesforce.com/certification-detail?conId=';
            insert customSetting;
        }
    }
    
    public static List<GoogleAuthSettings__c> generateGoogleAuthSettings(String name, String googleClientId, String googleclientSecret, String APIKey, String domain10k) {
        return generateGoogleAuthSettingsInternal(name, googleClientId, googleclientSecret, APIKey, domain10k);
    }
    
    private static List<GoogleAuthSettings__c> generateGoogleAuthSettingsInternal(String name, String googleClientId, String googleclientSecret, String APIKey, String domain10k) {
        
        List<GoogleAuthSettings__c> googleAuthLi    = new List<GoogleAuthSettings__c>();
                                                        
        GoogleAuthSettings__c objCustomSetting      = new GoogleAuthSettings__c();
        objCustomSetting.Name                       = name;
        objCustomSetting.GoogleClientID__c          = googleClientId;
        objCustomSetting.GoogleClientSecret__c      = googleclientSecret;
        objCustomSetting.API_Key__c                 = APIKey;
        objCustomSetting.X10K_Domain__c             = domain10k;
        googleAuthLi.add(objCustomSetting);
        
        return googleAuthLi;
    }
    
    public static ConnectedApp__c createConnectedAppCustomSetting() {
        /*ConnectedApp__c credentials = new ConnectedApp__c( Callback_URL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/AuthorizeSalesforceOrg', 
                                                            Consumer_Key__c = '3MVG9hq7jmfCuKfcGjlDxJufcTij8DYinl.ioRbU7QNTrZC8q67ySP3hrO.hcTzWYMk8AjBySMwCqkNlYA1jI', 
                                                            Consumer_Secret__c = '3922199713804899562' ); */
        ConnectedApp__c credentials = new ConnectedApp__c( Callback_URL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/AuthorizeSalesforceOrg', 
                                                            Consumer_Key__c = '3MVG9uudbyLbNPZNRb0Klk8MWh1YXLQzh8Pg9FaT3rn.K7NUg3GJtltUqeHl2sD8AujLMvuHYhRxrTJfg2Nni', 
                                                            Consumer_Secret__c = '8679647137275828905' );                                                    
                                                            
        insert credentials;
        return credentials;
    }
}