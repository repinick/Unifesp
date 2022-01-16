/* 
----------------------------------------------------------------------------------------------------
-- - Name:        MTTCasePOIntegrationRest
-- - @Author: 	  Nicoli Ferreira
-- - Description: Webservice to receive Case and PO information. 
-- -	          Processes the received data synchronously.
-- -------------------------------------------------------------------------------------------------
*/

@RestResource(urlMapping='/MTT/Case/*') 
global with sharing class MTTCasePOIntegrationRest {

/*****************************************************************************************
* Method Name   : integrationCasePO
* Description   : Formats and validates data received from eParts. After formatting, 
the data is sent to the MTTCasePOIntegrationRestService class for synchronous processing.
******************************************************************************************/
        
    @HttpPost
    global static MTTWSResponse integrationCasePO(){
        
        RestRequest req = RestContext.request; 
        
        Boolean isBlock = IntegrationUtils.isIntegrationBlocked('MTTCasePOIntegrationRest');
        if(isBLock) return new MTTWSResponse('Error', 'Inactive integration');
        
        try{ 
            
            // Deserializa pacote de dados JSON
            MTTInboundCasePo mtt = new MTTInboundCasePo();
            //System.debug(req.requestBody.toString());
            mtt = (MTTInboundCasePO) JSON.deserialize(req.requestBody.toString() , MTTInboundCasePO.Class);
            
            // Utiliza método Adapter para converter os dados recebidos 
            MTTCasePoDataModel dataModel = new MTTCasePoDataModel();
            dataModel = mtt.ConvertData();
            
            // Web Number required (chave primária do Portal Web)
            if(String.isNotBlank(dataModel.webNumber)){ 
            
                // Processamento Síncrono
                MTTCasePOIntegrationRestService casePo = new MTTCasePOIntegrationRestService(dataModel);
                casePO.execute();
       
                return new MTTWSResponse('Success', ''); // Reposta para o Portal
            
            } else return new MTTWSResponse('Error', 'Web Number is missing');
        } 
        catch (Exception e){
            
            System.debug('Error parsing JSON'+ e.getMessage() + ' /// ' + e.getStackTraceString());
            return new MTTWSResponse('Error', e.getMessage() + ' /// ' + e.getStackTraceString());
        
        }
    } 
    
    public class GenericException extends Exception{}

}
