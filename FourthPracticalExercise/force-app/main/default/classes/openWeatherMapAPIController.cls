public with sharing class openWeatherMapAPIController {

    private Account a;
    private String accountCity;
    private static String Apy_key;
    private static String Base_URL;
    private static String Image_Base_URL;
    private static String requestEndpoint;
    private static String imageURL;
    private static String city {get;set;}
    private static String temp {get;set;}
    private static String description {get;set;}
    private static String iconId {get;set;}
 
    public openWeatherMapAPIController(ApexPages.StandardController controller) {
        this.a = (Account)controller.getRecord();
        accountCity = a.ShippingCity;

        Open_Weather_Map__c openWeatherSetting = Open_Weather_Map__c.getOrgDefaults();
        Apy_key = openWeatherSetting.Api_Key__c;
        Base_URL = openWeatherSetting.Base_URL__c;
        Image_Base_URL = openWeatherSetting.Image_Base_URL__c;
        requestEndpoint = Base_URL + accountCity + '&appid=' + Apy_key;

        // Apy_key = Open_Weather_Map__c.getInstance('Api Key').Api_Key__c;
        // Base_URL = Open_Weather_Map__c.getInstance('Base URL').Base_URL__c;
        // Image_Base_URL = Open_Weather_Map__c.getInstance('Image Base URL').Image_Base_URL__c;      
    }

    public static HttpResponse makeGetCallout() {  
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestEndpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.debug(response.getBody());

        if(response.getStatusCode()==200) {
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            city = String.valueOf(results.get('name'));

            List<Object> weatherResults = (List<Object>)(results.get('weather'));        
            for(Object ob : weatherResults){
                Map<String, Object> res = (Map<String, Object>)ob;
                description = String.valueOf(res.get('description'));
                iconId = String.valueOf(res.get('icon'));
                imageURL= Image_Base_URL + iconId + '@2x.png';
            }    

            Map<String, Object> mainResults = (Map<String, Object>)(results.get('main'));
            temp = String.valueOf(mainResults.get('temp'));
        
        } else {
          //  customMsg = System.Label.Open_Weather_Map_API_Error;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Open_Weather_Map_API_Error));
        }
        return response;
    }
}