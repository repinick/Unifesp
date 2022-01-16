/* 
----------------------------------------------------------------------------------------------------
-- - Name:        MTTCasePOIntegrationRestService 
-- - @Author: 	  Nicoli Ferreira
-- - Description: Class that processes the 1st integration with eParts, 
-- -			  creating the Case and the PO if they do not exist.
-- -------------------------------------------------------------------------------------------------
*/

public class MTTCasePOIntegrationRestService{ 
    
    private MTTCasePoDataModel mttInbound;
    
    private List<MTTCasePoDataModel.POItem> poItems;
    private Map<String,MTTCasePoDataModel.POItem> mapPOItems;
    
    private Map<String,PricebookEntry> mapPriceBookentry;	
	private Map<String,Product2> mapProduct;
    private List<Pricebook2> pricebook;
    
    private Case objectCase;
    private PO__c objectPO;
    private Account account;
    private EEJ_Aircraft__c aircraft;
    
    private String partSerialNumber;
    
    private String poWebNumber;

    private String Ship_to_Party;
    private String Sold_to_Party;
    
    private String value;
        
    private static final String RECTYPE_MATERIAL = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Material').getRecordTypeId();
    private static final Id RT_CASE_SJKPARTS = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SJK Parts').getRecordTypeId();
    
/*****************************************************************************************
* Method Name   : MTTCasePOIntegrationRestService
* Description   : constructor method.
******************************************************************************************/
    
    public MTTCasePOIntegrationRestService(MTTCasePoDataModel mttInbound){
        
        this.mttInbound = mttInbound;
        this.poWebNumber = poWebNumber;

        this.poItems = new List<MTTCasePoDataModel.POItem>();
        this.mapPOItems = new Map<String,MTTCasePoDataModel.POItem>();
        
        this.pricebook = REP_Pricebook.getStandardPricebooks('Material');
		this.mapPriceBookentry = new Map<String,PricebookEntry>();
		this.mapProduct = new Map<String,Product2>();
        
        this.objectCase = new Case();
		this.objectPO = new PO__c();
		this.account = new Account();
        
    }
    
/*****************************************************************************************
* Method Name   : execute
* Description   : calls the processing methods.
******************************************************************************************/
    
    public void execute(){
        
        Exception ex;
        Savepoint sp = Database.setSavepoint();

        try{
            
			getAccount(); 

			getMapsAndValidItens();	

			createProductAndPriceBookentry();

			createCase(); 

			createPO();
 
        }
        
        catch(Exception e){
            
            String message = 'Error: ' + e.getMessage();
            System.debug(message);
            
            sendingEmail(message);
        }   
    }
    
/*****************************************************************************************
* Method Name   : sendingEmail
* Description   : send email error to 'toAddresses' value.
******************************************************************************************/
    public void sendingEmail(String e){
		
        String plainTextBody = '';
        plainTextBody += 'Web Number: ' + this.mttInbound.webNumber + '\n';
        plainTextBody += 'PO Number: ' + this.mttInbound.poNumber + '\n';
        plainTextBody += 'Customer MFIR: ' + this.mttInbound.customer.mfir + '\n\n';
        
 		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 		
        String[] toAddresses = new String[] {'sjkpartsrequest@embraer.com.br'}; 
  		mail.setToAddresses(toAddresses);

   		// The email template ID used for the email
   		//mail.setTemplateId('Email template id');
        
        mail.setSenderDisplayName('Salesforce Integration');
        mail.setSubject('SJKParts x eParts Integration Error');
        mail.setPlainTextBody(plainTextBody + e);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

/*****************************************************************************************
* Method Name   : getAccount
* Description   : get account by Mfir.
******************************************************************************************/
    
    public void getAccount(){
        
        QB_Query queryBuilderAccount = new QB_Query(new REP_Account());
        queryBuilderAccount.setCriteria(new QB_Criteria().add(QB_Restriction.eq('Mfir__c' , this.mttInbound.customer.mfir))); 
        
        List<Account> accounts = (List<Account>) queryBuilderAccount.search();
        
        if(accounts == null || accounts.isEmpty()) throw new GenericException('MFir not found ' + this.mttInbound.customer.mfir);
        
		this.account = accounts[0];
    }
    
/*****************************************************************************************
* Method Name   : getMapsAndValidItens
* Description   : get Map And Valid Itens.
******************************************************************************************/

    public void getMapsAndValidItens(){
         
        //   var (data type - item)	  Name	 Items List
   		for(MTTCasePoDataModel.POItem item : this.mttInbound.poItems){
            
            if(String.isNotBlank(item.ecode)){
				this.mapPOItems.put(item.ecode, item);
                System.debug('Item ecode:' + item.ecode);
            }
		}
    }
    
/*****************************************************************************************
* Method Name   : createProductAndPriceBookentry
* Description   : create Product2 and PriceBookentry, if they already exist do not create anything, just return existing information.
******************************************************************************************/	
	
	public void createProductAndPriceBookentry(){

		Map<String,PricebookEntry> mapPBEntry = new Map<String,PricebookEntry>();
		List<PricebookEntry> lPricebookentry = new List<PricebookEntry>();
		List<PricebookEntry> lPricebookentryStd = new List<PricebookEntry>();

        loadProducts(); 

		List<Product2> lNewProducts = new List<Product2>();
            
        for(MTTCasePoDataModel.POItem item : this.mttInbound.poItems){
            
            if(!this.mapProduct.containsKey(item.ecode)){
                
                Product2 newProduct = buildProduct2(item);
                mapProduct.put(newProduct.ecode__c, newProduct);
                    
                lNewProducts.add(newProduct);
            }
        }	

		if(!lNewProducts.isEmpty()) {
			insert lNewProducts;
			loadProducts();
		}

		for(PricebookEntry entry : getProductByPriceBookEntry()){
			mapPBEntry.put(entry.Product2.Ecode__c , entry);
		}

		for(Product2 prod : this.mapProduct.values()){
            
			if(!mapPBEntry.containsKey(prod.Ecode__c)) {
				lPricebookentryStd.add(buildPriceBookentryStd(prod.Id));
				lPricebookentry.add(buildPriceBookentry(prod.Id));
			}
		}

		if(!lPricebookentry.isEmpty()) {
			insert lPricebookentryStd;
			insert lPricebookentry;

            for(PricebookEntry entry : getBookEntryById(new Map<Id,PricebookEntry>(lPricebookentry).keySet())){  
                if(!mapPBEntry.containsKey(entry.Product2.Ecode__c)) mapPBEntry.put(entry.Product2.Ecode__c, entry);
            }
        }    

		this.mapPriceBookentry = mapPBEntry;
	}

/*****************************************************************************************
* Method Name   : loadProducts
* Description   : load the products related to the PO items.
******************************************************************************************/	
	
    public void loadProducts(){

		QB_Query queryBuilder = new QB_Query( new REP_Product() );        
		QB_Criteria crit = new QB_Criteria();
	
		crit.add( QB_Restriction.isIn('Ecode__c' , (List<String>) JSON.deserialize(JSON.serialize(this.mapPOItems.keyset()), List<String>.class)) );

		queryBuilder.setCriteria(crit);
		List<Product2> products = (List<Product2>) queryBuilder.search();

		for (Product2 prod : products) {
			this.mapProduct.put( prod.Ecode__c, prod );
		}
	
    }
    
/*****************************************************************************************
* Method Name   : buildProduct2
* Description   : build Product2.
******************************************************************************************/	
	
    public Product2 buildProduct2(MTTCasePoDatamodel.POItem item){
        
        return new Product2(
            Ecode__c = item.ecode
            ,ProductCode = item.ecode
            ,IsActive = true
            ,Description = item.pnDescription
            ,PartNumber__c = item.pn
            ,Name = item.ecode
            ,RecordTypeId = RECTYPE_MATERIAL
       	);
    }
    
/*****************************************************************************************
* Method Name   : getProductByPriceBookEntry
* Description   : get Product By PriceBookEntry.
******************************************************************************************/	
	
	public List<PricebookEntry> getProductByPriceBookEntry(){

        QB_Query queryBuilder = new QB_Query( new REP_PricebookEntry() );        
		QB_Criteria crit = new QB_Criteria();
		
		crit.add( QB_Restriction.isIn('Product2.Ecode__c' , (List<String>) JSON.deserialize(JSON.serialize(this.mapPOItems.keyset()), List<String>.class)) );
        
        crit.add( QB_Restriction.eq('IsActive' , true) );
        crit.add( QB_Restriction.eq('Pricebook2.Name' , 'Material') );
        
        queryBuilder.setCriteria(crit);
		
        return (List<PricebookEntry>) queryBuilder.search();
	}
    
/*****************************************************************************************
* Method Name   : buildPriceBookentryStd
* Description   : Creates standard and inactive PricebookEntry object body.
******************************************************************************************/	
	
	public PricebookEntry buildPriceBookentryStd(String productId){

		return new PricebookEntry(
				Product2Id = productId
				,Pricebook2Id = this.pricebook[1].Id
				,UnitPrice = 0
				,IsActive = false
            	,CurrencyIsoCode = String.isBlank(this.mttInbound.poItems[0].sCurrency) ? 'USD' : this.mttInbound.poItems[0].sCurrency
		);
	}

/*****************************************************************************************
* Method Name   : buildPriceBookentry
* Description   : creates body of the active PricebookEntry object.
******************************************************************************************/	
	
	public PricebookEntry buildPriceBookentry(String productId){

		return new PricebookEntry(
				Product2Id = productId
				,Pricebook2Id = this.pricebook[0].Id
				,UnitPrice = 0
				,IsActive = true
				,CurrencyIsoCode = String.isBlank(this.mttInbound.poItems[0].sCurrency) ? 'USD' : this.mttInbound.poItems[0].sCurrency
		);
	}
    
/*****************************************************************************************
* Method Name   : getBookEntryById
* Description   : get BookEntry By Id.
******************************************************************************************/
	
	public List<PricebookEntry> getBookEntryById(Set<Id> entryIds){
		
        QB_Query queryBuilder = new QB_Query(new REP_PricebookEntry());        
        queryBuilder.setCriteria((new QB_Criteria()).add( QB_Restriction.isIn('Id' , (List<String>) JSON.deserialize(JSON.serialize(entryIds), List<String>.class))));
		
		return (List<PricebookEntry>) queryBuilder.search();
	}
	  
/*****************************************************************************************
* Method Name   : getContact
* Description   : get Contact by Email.
******************************************************************************************/
    
    public List<Contact> getContact(){
        
        QB_Query queryBuilder = new QB_Query(new REP_Contact());  
        
        if(String.isBlank(this.mttInbound.customer.contactEmail)) return new List<Contact>();
        else queryBuilder.setCriteria(new QB_Criteria().add(QB_Restriction.eq('EMAIL' , (this.mttInbound.customer.contactEmail)))); 

		return (List<Contact>) queryBuilder.search();  
    
    }
    
/*****************************************************************************************
* Method Name   : getAircraft
* Description   : get Aircraft by Serial Number.
******************************************************************************************/
    
    public EEJ_Aircraft__c getAircraft(){
   
        if(String.isBlank(this.mttInbound.aircraft.serialNumber)) return null;

		QB_Query queryBuilderAircraft = new QB_Query(new REP_EEJ_Aircraft());        
		
		queryBuilderAircraft.setCriteria(new QB_Criteria().add(QB_Restriction.eq('AC_Serial_Number__c' , this.mttInbound.aircraft.serialNumber))); 

		List<EEJ_Aircraft__c> aircraft = (List<EEJ_Aircraft__c>) queryBuilderAircraft.search();

		if(aircraft == null || aircraft.isEmpty()) 
            return null;

		return aircraft[0];
        
    }
    
/*****************************************************************************************
* Method Name   : createCase
* Description   : insert or update Case.
******************************************************************************************/
    
    public void createCase(){
        
        Map<String,CfgCaseReasonAOGNFO__c> mapAOG = CfgCaseReasonAOGNFO__c.getAll();
        Map<String,CfgCaseReasonSB__c> mapSB = CfgCaseReasonSB__c.getAll();
        
        EEJ_Aircraft__c aircraft = getAircraft(); 
        
        String caseIdByOrder;
        PO__c[] poCaseId;
        
        if(String.isBlank(this.mttInbound.caseNumber)){
        
            poCaseId = [SELECT Case__c FROM PO__c WHERE Web_Number__c =: this.mttInbound.webNumber];
            
            if(poCaseId.size() == 0)
                if(String.isNotBlank(this.mttInbound.poNumber)) caseIdByOrder = findOpenCaseIdByPONumber(this.mttInbound.poNumber);
                
        }   
			
        List<Case> lCase = new List<Case>();
        
        if(String.isNotBlank(this.mttInbound.caseNumber) || String.isNotBlank(caseIdByOrder) || poCaseId.size() > 0){ 
            
        	QB_Query queryBuilderCase = new QB_Query(new REP_Case()); 
			QB_Criteria crit = new QB_Criteria();     
            
            //CaseNumber
            if(String.isNotBlank(this.mttInbound.caseNumber)) crit.add(QB_Restriction.eq('CaseNumber' , this.mttInbound.caseNumber));
        	
            //WebNumber
            else if(poCaseId.size() > 0) crit.add(QB_Restriction.eq('Id' , poCaseId[0].Case__c));
            
            //PONumber
            else if(String.isNotBlank(caseIdByOrder)) crit.add(QB_Restriction.eq('Id' , caseIdByOrder));
            
        	queryBuilderCase.setCriteria(crit);
            
            queryBuilderCase.withForUpdate(); // FOR UPDATE
            
			lCase = (List<Case>) queryBuilderCase.search();
            
        } 
        
        if(lCase.isEmpty() & hasSODItens()) this.objectCase = null;
        else{
            this.objectCase.RecordTypeId = RT_CASE_SJKPARTS;
          	this.objectCase.Phase__c = 'Order Processing';
            this.objectCase.Description = 'eParts PO/Order integrated successfully';
            this.objectCase.New_Item_Created__c = true;
			this.objectCase.Subject = 'eParts PO# ' + String.valueOf(this.mttInbound.poNumber);
			this.objectCase.Status = 'Analyse Request';
			this.objectCase.AccountId = this.account.Id;
			this.objectCase.Origin = 'eParts';
            this.objectCase.Reason = getReasonCase(mapAOG, mapSB);
            
         	if(String.isNotBlank(this.mttInbound.caseNumber) || String.isNotBlank(caseIdByOrder) || poCaseId.size() > 0){
                this.objectCase.Id = lCase[0].Id;
				this.objectCase.ContactId = lCase[0].ContactId;
            }
            
			if(aircraft != null){
				this.objectCase.EEJ_A_C__c = aircraft.Id;
				this.objectCase.Priority = 'AOG';
				this.objectCase.A_C_Model_read_only__c =  aircraft.Model__c;
			} else this.objectCase.Priority = 'Critical';
			
			list<Contact> lContact = getContact();
	
			if(lContact != null && !lContact.isEmpty() && this.objectCase.ContactId == null) this.objectCase.ContactId = lContact[0].Id;
	
			upsert this.objectCase ;
	
			QB_Query queryBuilderCase2 = new QB_Query(new REP_Case());        
			queryBuilderCase2.setCriteria(new QB_Criteria().add(QB_Restriction.eq('Id' , this.objectCase.Id)));
	
			List<Case> caseObj = (List<Case>) queryBuilderCase2.search();
	
			this.objectCase = caseObj[0];
		}	
    }
    
/*****************************************************************************************
* Method Name   : findOpenCaseIdByPONumber
* Description   : tries to find an Open Case by PO Number. 
******************************************************************************************/
   
    private String findOpenCaseIdByPONumber(String poNumber){
        
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
    
    private Boolean hasSODItens() {
		
        Boolean hasSOD = false;
        
		for(MTTCasePoDataModel.POItem item : this.mttInbound.poItems){ 
			if(item.center.contains('SOD')) {
				hasSOD = true;
				break;
			}
		}
		return hasSOD;	
	}
    
/*****************************************************************************************
* Method Name   : getReasonCase
* Description   : get value for Case object's Reason field.
******************************************************************************************/	
	
	public String getReasonCase(Map<String,CfgCaseReasonAOGNFO__c> mapAOG , Map<String,CfgCaseReasonSB__c> mapSB){

		String reason = '';
		
		for(String keyAOG : mapAOG.keySet()){
			for(MTTCasePoDataModel.POItem item : this.mttInbound.poItems){
				if (String.isNotBlank(item.shippingInstructions) && item.shippingInstructions.containsIgnoreCase(keyAOG)) return 'AOG NFO';
			}
		}
				
        for(MTTCasePoDataModel.POItem item : this.mttInbound.poItems){ 
            
			if(String.isNotBlank(item.source)){
				for(String lChaveSB : mapSB.keySet()){
					if(item.source.containsIgnoreCase(lChaveSB)) return 'SB';
				}
			}
		}	

		return 'PO';
	}
	
/*****************************************************************************************
* Method Name   : createPO
* Description   : insert or update PO.
******************************************************************************************/
    
    public void createPO(){
        
		definePOWebNumber(); 

		PO__c po = buildPO(); 

		Schema.SObjectField externalId = PO__c.Fields.Web_Number__c;

		Database.UpsertResult result = Database.upsert(po, externalId, false);
        
        if(!result.isSuccess())	throw new GenericException('Upsert PO'); 

		this.objectPO = po;

		List<PO_Item__c> poItems = new List<PO_Item__c>();
        
		for(MTTCasePoDataModel.POItem item : this.mttInbound.poItems){
			
            poItems.add(buildPOItem(item, po.Id));
            System.debug('Request Number: ' + item.requestItemNumber);
		
        }

		Schema.SObjectField externalIdItem = PO_Item__c.Fields.Request_Item_Number__c;

		Database.UpsertResult[] results = Database.upsert(poItems, externalIdItem, false);
	
    }
    
	private void definePOWebNumber() {
        
		String caseNumber = this.objectCase == null ? '[NOCASE]' : this.objectCase.Casenumber;
        this.poWebNumber = this.mttInbound.poNumber + caseNumber;
		
		if(String.isNotBlank(this.mttInbound.webNumber)){
			this.poWebNumber = this.mttInbound.webNumber;
			while(this.poWebNumber.length() < 7) this.poWebNumber = '0' + this.poWebNumber;
		}
        
	}
       
/*****************************************************************************************
* Method Name   : buildPO
* Description   : build PO.
******************************************************************************************/
	
	public PO__c buildPO(){

		PO__c po = new PO__c(
				PO_Number__c = this.mttInbound.poNumber
            	,Name = this.mttInbound.poNumber
				,Distribution_Chanel__c = Integer.valueOf(this.mttInbound.distributionChannel)
				,Division__c = Integer.valueOf(this.mttInbound.division)
				,Aircraft_Model__c = String.isBlank(this.mttInbound.aircraft.aircraftModel) ? null : Integer.valueOf(this.mttInbound.aircraft.aircraftModel) 
				,Serial_Number__c = this.mttInbound.aircraft.serialNumber
				,PO_Created_By__c = this.account.Id
				,Web_Number__c = this.poWebNumber 
				,Case__c = this.objectCase == null ? null : this.objectCase.Id
				,PO_created_by_MFIR__c = this.mttInbound.customer.mfir
				,Sales_area_data__c = this.mttInbound.salesArea
				,Created_by_user__c = this.mttInbound.customer.name
		);
        
        if(this.mttInbound.purchaseDate != null) po.Purchase_Data__c = this.mttInbound.purchaseDate;

        po.Ship_to_Party__c = this.mttInbound.shipTo.mfir != null ? Decimal.valueOf(this.mttInbound.shipTo.mfir) : null;
        po.Sold_to_Party__c = this.mttInbound.soldTo.mfir != null ? Decimal.valueOf(this.mttInbound.soldTo.mfir) : null;
		
		return po;
	}
    
/*****************************************************************************************
* Method Name   : buildPOItem
* Description   : build POItem.
******************************************************************************************/

	public PO_Item__c buildPOItem(MTTCasePoDataModel.POItem item, String poId){
  
        PO_Item__c itemPO = new PO_Item__c(

				PO__c = poId
				,Name = this.mttInbound.poNumber + item.ITM_NUMBER 
				,Request_Item_Number__c = item.requestItemNumber 
				,Web_Number_Line__c = item.requestItemNumber
				,Ecode__c = this.mapProduct.get(item.ecode).Id 
				,PN__c = item.pn
				,PN_Description__c = item.pnDescription
				,Center__c = item.center
				,Amount_Requested__c = item.amountRequested 
				,Coverage__c = item.coverage 
				,Currency__c = item.sCurrency 
				,Part_Serial_Number__c = item.partSerialNumber
				,Order_Blocking_sent_by_WEB__c = item.orderBlockingSentbyWEB
				,To_be_defined__c = item.toBeDefined
				,Source__c = item.source
				,Shipping_Instructions__c = item.shippingInstructions
            	,Deposit__c = item.deposit
            	,Priority__c = item.priority
		);
        
        if(String.isNotBlank(String.valueOf(item.value))) itemPO.Value__c = item.value;
		
        if(item.deliveryDate != null) itemPO.Delivery_Date__c = item.deliveryDate; 

		return itemPO;
	}
    
/*****************************************************************************************
* inner class Name 	: GenericException
* Description   	: used to throw exceptions with customized message.
******************************************************************************************/

	public class GenericException extends Exception{}

}