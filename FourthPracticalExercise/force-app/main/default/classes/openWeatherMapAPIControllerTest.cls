@isTest
private class openWeatherMapAPIControllerTest {
    @IsTest
    static void testWeatherConditions() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetWeatherResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, mock);

        Account a = new Account();
        a.Name='Test Account';
        a.ShippingCity='Hamburg';
        a.ShippingCountry='Germany'; 
        insert a;  

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('account', a.Id);
        openWeatherMapAPIController controller = new openWeatherMapAPIController(sc);

        HttpResponse result = openWeatherMapAPIController.makeGetCallout();
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(result.getBody());

        String city = String.valueOf(results.get('name'));
        System.assertEquals('Bucharest', city);

        List<Object> weatherResults = (List<Object>)(results.get('weather'));
        for(Object ob : weatherResults) {
            Map<String, Object> res = (Map<String, Object>)ob;

            String description = String.valueOf(res.get('description'));
            System.assertEquals('clear sky', description);

            String icon = String.valueOf(res.get('icon'));
            System.assertEquals('01d', icon);
        }

        Map<String, Object> mainResults = (Map<String, Object>)(results.get('main'));
            String temp = String.valueOf(mainResults.get('temp'));   
            System.assertEquals('283.2', temp);

        System.assertNotEquals(null, result, 'The callout returned a null response.');
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200.');
        System.assertEquals('application/json;charset=UTF-8', result.getHeader('Content-Type'), 'The content type value is not expected.');

        Test.stopTest();
    }
}
