public with sharing class openWeatherMapAPIController {
    
    public String city {get;set;}
    public String temp {get;set;}
    public String description {get;set;}
    public String iconId {get;set;}
    
    public openWeatherMapAPIController(ApexPages.StandardController controller){
        
        Account acct = (Account)controller.getRecord();
        acct = [SELECT Id, Name, ShippingCity FROM Account WHERE Id =:acct.Id];
        
        String accountCity = acct.ShippingCity;
        String apiKey = '4aef19424bf9aa1eba016ceed9d60ac3';
        String requestEndpoint = 'https://api.openweathermap.org/data/2.5/weather?q=' + accountCity + '&appid=' + apiKey;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestEndpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        
        if(response.getStatusCode()==200){
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            city = String.valueOf(results.get('name'));

            List<Object> weatherResults = (List<Object>)(results.get('weather'));
            
            for(Object ob : weatherResults){
                Map<String, Object> res = (Map<String, Object>)ob;
                description = String.valueOf(res.get('description'));
                iconId = String.valueOf(res.get('icon'));
                temp = String.valueOf(res.get('temp'));
                String imageURL='http://openweathermap.org/img/wn/' + iconId + '@2x.png';
            }
            
            Map<String, Object> mainResults = (Map<String, Object>)(results.get('main'));
                temp = String.valueOf(mainResults.get('temp'));
          
            
        } else {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error retrieving the weather info');
            ApexPages.addMessage(msg);
        }

    }
}