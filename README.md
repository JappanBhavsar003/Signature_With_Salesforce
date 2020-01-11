# Signature_With_Salesforce
This repo contains simple signature utility tool to store signature at field level for any object.<br/><br/>
<b>Steps:</b>
1. Clone this repo
2. Use Ant Migration tool to deploy this package into your target salesforce org.
3. Now if you want to add signature on any salesforce object like 'Account' object then create 2 fields on account object<br/>
    3.1 Authority Signature (Authority_Signature__c) - Type of Rich TextArea<br/>
    3.2 Authority Signature Link (Authority_Signature_Link__c) - Type of Formula (Text) - Value: HYPERLINK('/apex/signature?id='+Id+'&field=Authority_Signature__c','Click Here to Sign','_BLANK')
4. Now open any account record and click 'Authority Signature Link' field's link and it will open a page where we can sign the signature and submit to the salesforce. Salesforce will store this signature as document and add it's link as image in 'Authority Signature' rich textarea field.

**Please make sure you have created 'signature' folder in document otherwise it won't save document and gives you an error.

[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/mnGsAW7DDlo/0.jpg)](http://www.youtube.com/watch?v=mnGsAW7DDlo)

