global class Signature {
    // Variable declaration
    public string objectId {get;set;}
    public string objectField {get;set;}
    private Schema.SObjectType objectType {get;set;}
    global Signature(){
        objectId = null;
        objectField = '';
        objectId = ApexPages.currentPage().getParameters().get('id');
        objectField = ApexPages.currentPage().getParameters().get('field');
        if(objectId != null){
            Id objId = (Id)objectId;
            objectType = objId.getSobjectType();
        }
        System.debug('objectId ->' + objectId + ' objectField -> '+ objectField + ' objectType ->' + objectType);
    }
    
    // function declaration
    // submitSignature - To submit signature in salesforce object's rich text field 
    @RemoteAction
    global static SignatureResponse submitSignature(string objectId, string objectField, string data){
        // Null and Empty string handling
        if(objectId == '' || objectId == null){
            return new SignatureResponse(true,'Please make sure you have passed valid object salesforce Id',null);
        }
        if(objectField == '' || objectField == null){
            return new SignatureResponse(true,'Please make sure you have passed valid object field name(Field Type must be rich textarea)',null);
        }
        if(data == null){
            return new SignatureResponse(true, 'Please make sure you have passed valid blob data to store a signature',null);
        }
        // ObjectId handling
        Id objId = objectId;
        System.debug('objId-->'+ objId);
        Schema.SObjectType objType = null;
        try{
            objType = objId.getSobjectType();
            boolean isFieldExist;
            if(objType != null){
                isFieldExist = doesFieldExist(objType.getDescribe().getName(),objectField);
                if(isFieldExist){
                    string query = 'SELECT Id, Name, ' + objectField + ' FROM ' +  objType.getDescribe().getName() + ' WHERE Id = :objId';
                    List<sObject> sRecords = Database.query(query);
                    System.debug('sRecords-->'+ sRecords);
                    if(!sRecords.isEmpty()){
                        // Select Folders
                        List<Folder> signFolder = new List<Folder>();
                        signFolder = [SELECT Id, Name FROM Folder WHERE Name = 'signature' limit 1];
                        if(signFolder.isEmpty()){
                            return new SignatureResponse(true, 'Please make sure you have cretaed \'signature\' folder in your salesforce org',null);
                        }
                        // Insert Blob as Document in salesforce
                        blob file = EncodingUtil.base64Decode(data.substring(data.indexOf(',')+1,data.length()));
                        Document doc = new Document();
                        doc.body = file;
                        doc.name = 'Signature_'+ objectId +'_'+String.valueOf(System.today());
                        doc.ContentType= 'image/jpg';
                        doc.isPublic = true;
                        doc.FolderId = signFolder[0].Id;
                        insert doc;
                        // Now set this inserted document in rich text area field of an object
                        for(sObject rec : sRecords){
                            String instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
                            string srcLink = instanceUrl + '/servlet/servlet.FileDownload?file=' + doc.id;
                            string richText = '<img alt="signature" src="'+ srcLink +'" style="height:100px;width:150px;"></img>';
                            rec.put(''+objectField+'',richText);
                        }
                        update sRecords;
                        return new SignatureResponse(false,'Signature uploaded successfully!',null);
                    }
                }
            }
        }catch(Exception ex){
            objType = null;
            return new SignatureResponse(true, 'Exception occure: '+ ex.getMessage(),null);
        }
        System.debug('objType-->'+ objType);
       
        return new SignatureResponse(true,'Something went wrong! Please try again later.',null);
        
    }
    
    // doesFieldExist - To check if the field is exist or not in salesforce object
    public static boolean doesFieldExist(String objName, string fieldName)
    {
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception ex) {
            System.debug('Exception-->'+ ex.getMessage());
        }
        return false;
    }
    
    // Class declaration
    global class SignatureResponse{
        boolean isError {get;set;}
        string message {get;set;}
        object data {get;set;}
        SignatureResponse(boolean isError, string message, object data){
            this.isError = isError;
            this.message = message;
            this.data = data;
        }
    }
}