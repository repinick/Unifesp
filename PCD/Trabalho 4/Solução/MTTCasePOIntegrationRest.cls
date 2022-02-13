/* 
----------------------------------------------------------------------------------------------------
-- - Name:        MTTCasePOIntegrationRest
-- - @Author: 	  Nicoli Ferreira
-- - Description: Webservice to receive Case and PO information. 
-- -	          Processes the received data asynchronous.
-- -------------------------------------------------------------------------------------------------
*/

@RestResource(urlMapping='/MTT/Case/*') 
global with sharing class MTTCasePOIntegrationRest {

/*****************************************************************************************
* Method Name   : integrationCasePO
* Description   : Formats and validates data received from eParts. After formatting, 
the data is sent to the MTTCasePOIntegrationRestService class for asynchronous processing.
******************************************************************************************/
    
    private static final Id RT_CASE_SJKPARTS = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SJK Parts').getRecordTypeId();
    
    @HttpPost
    global static MTTWSResponse integrationCasePO(){
        
        RestRequest req = RestContext.request; 
        
        Boolean isBlock = IntegrationUtils.isIntegrationBlocked('MTTCasePOIntegrationRest');
        if(isBLock) return new MTTWSResponse('Error','','Inactive integration');
        
        try{ 
 
            MTTInboundCasePo mtt = new MTTInboundCasePo();
            
            System.debug(req.requestBody.toString());
            
            mtt = (MTTInboundCasePO) JSON.deserialize(req.requestBody.toString() , MTTInboundCasePO.Class);
			
            MTTCasePoDataModel dataModel = new MTTCasePoDataModel();
            dataModel = mtt.ConvertData();
            
            // Web Number required
            if(String.isNotBlank(dataModel.webNumber)){
                    
                //create case
                Case newCase = new Case();
                PO__c[] poCaseId;
                
                String caseIdByOrder;
                
                if(String.isBlank(dataModel.caseNumber)){
                    
                    poCaseId = [SELECT Case__c FROM PO__c WHERE Web_Number__c =: dataModel.webNumber]; // search Case through web number
                    
                    if(poCaseId.size() == 0)
                		if(String.isNotBlank(dataModel.poNumber)) caseIdByOrder = findOpenCaseIdByPONumber(dataModel.poNumber); // search Case through PO number
			
                }                    
                
                List<Case> lCase = new List<Case>();
        
                if(String.isNotBlank(dataModel.caseNumber) || String.isNotBlank(caseIdByOrder) || poCaseId.size() > 0){ 
                    
                    QB_Query queryBuilderCase = new QB_Query(new REP_Case()); 
                    QB_Criteria crit = new QB_Criteria();     
                    
                    //CaseNumber
                    if(String.isNotBlank(dataModel.caseNumber)) crit.add(QB_Restriction.eq('CaseNumber' , dataModel.caseNumber));
                    
                    //WebNumber
                    else if(poCaseId.size() > 0) crit.add(QB_Restriction.eq('Id' , poCaseId[0].Case__c));
                    
                    //PONumber
                    else if(String.isNotBlank(caseIdByOrder)) crit.add(QB_Restriction.eq('Id' , caseIdByOrder));
                    
                    queryBuilderCase.setCriteria(crit);
                    
                    queryBuilderCase.withForUpdate();
                    
                    lCase = (List<Case>) queryBuilderCase.search();
                    
                }  
                
                if(lCase.isEmpty()){
                    
                    newCase.RecordTypeId = RT_CASE_SJKPARTS;
                    newCase.Description = 'eParts PO/Order integrated successfully';
                    newCase.New_Item_Created__c = true;
                    newCase.Status = 'Analyse Request';
                    newCase.Origin = 'eParts';
                    
                    insert newCase;
                    
                    dataModel.caseNumber = ([SELECT caseNumber FROM Case WHERE Id =: newCase.Id]).caseNumber; 
                
                } else dataModel.caseNumber = ([SELECT caseNumber FROM Case WHERE Id =: lCase[0].Id]).caseNumber;
                
                
                //mtt.ConvertData -> MTTCasePoDataModel
                System.enqueueJob(new MTTCasePOIntegrationRestService(dataModel)); // queue processing class
           
                return new MTTWSResponse('Success', dataModel.caseNumber,'');
            
            } else return new MTTWSResponse('Error','', 'Web Number is missing');
        } 
        catch (Exception e){
            
            System.debug('Error parsing JSON'+ e.getMessage() + ' /// ' + e.getStackTraceString());
            return new MTTWSResponse('Error','', e.getMessage() + ' /// ' + e.getStackTraceString());
        
        }
    } 

/*****************************************************************************************
* Method Name   : findOpenCaseIdByPONumber
* Description   : tries to find an Open Case by PO Number. 
******************************************************************************************/
   
    private static String findOpenCaseIdByPONumber(String poNumber){
        
        QB_Query queryBuilderPO = new QB_Query(new REP_PO());  
		QB_Criteria crit = new QB_Criteria();  
        
		crit.add(QB_Restriction.eq('PO_Number__c' , poNumber));
		crit.add(QB_Restriction.notEq('Case__r.Status' , 'Closed'));
		crit.add(QB_Restriction.notEq('Case__r.Status' , 'Cancelled'));
		queryBuilderPO.setCriteria(crit);
		
        List<PO__c> lPOs = (List<PO__c>) queryBuilderPO.search();
        
        if(lPOs.isEmpty()) return null;
		else return lPOs.get(0).Case__c;
        
    }
    
    public class GenericException extends Exception{}

}