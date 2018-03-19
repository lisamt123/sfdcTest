public with sharing class CreatePackageXMLController {

	public String artifactPackageXMLString     {get;set;}
    public String artifactDestructiveXMLString {get;set;}
	public String errorMessage                 {get;set;}
	private Release__c release;
	public CreatePackageXMLController(ApexPages.StandardController stdController) {
        errorMessage = '';
        release      = [SELECT Id, Project__c, Project__r.Name FROM Release__c WHERE Id =: stdController.getId()];

		HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Release_Artifacts_Retrieve','',release.Id,release.Project__c,release.Project__r.Name);

		if(res.getStatusCode() == 200 ) {
            ResponseWrapper response = (ResponseWrapper) JSON.deserialize(res.getBody(), ResponseWrapper.class);
            if(response.Status == 'Success' && response.artifact != null) {
            	if(response.artifact.artifactPackageXML != null) {
            		artifactPackageXMLString = '{';

            		for(ArtifactList artifact : response.artifact.artifactPackageXML) {
            			if(artifact.metadataName != null && artifact.metadataName.size() > 0 && artifact.metadataName[0].trim() != '') {
            				artifactPackageXMLString += artifactPackageXMLString == '{' ? '' : ',';
            				artifactPackageXMLString += '"' + artifact.metadataType + '":' + JSON.serialize(artifact.metadataName);
            			}
            		}
            		artifactPackageXMLString += '}';
            		
            	}
            	if(response.artifact.artifactDestructiveXML != null) {
            		artifactDestructiveXMLString = '{';

            		for(ArtifactList artifact : response.artifact.artifactDestructiveXML) {
            			if(artifact.metadataName != null && artifact.metadataName.size() > 0 && artifact.metadataName[0].trim() != '') {
            				artifactDestructiveXMLString += artifactDestructiveXMLString == '{' ? '' : ',';
            				artifactDestructiveXMLString += '"' + artifact.metadataType + '":' + JSON.serialize(artifact.metadataName);
            			}
            		}
            		artifactDestructiveXMLString += '}';
            		
            	}
            }
            if((artifactPackageXMLString == null || artifactPackageXMLString == '{}' ) && (artifactDestructiveXMLString == null || artifactDestructiveXMLString == '{}')) 
                errorMessage = 'There are no artifacts attached to this Release. Please add some artifacts before downloading package.xml.';
        }
	}

	public PageReference redirectBackToRelease() {
        PageReference releaseDetail = new ApexPages.StandardController(release).view();
        releaseDetail.setRedirect(true);
        return releaseDetail;
    }

    public class ResponseWrapper {
	 	public Artifact artifact;
	 	public String status;
	}
	public class Artifact {
	 	public List<ArtifactList> artifactPackageXML;
	 	public List<ArtifactList> artifactDestructiveXML;
	}
	public class ArtifactList {
	 	public List<String> metadataName;
	 	public String metadataType;
	}
}