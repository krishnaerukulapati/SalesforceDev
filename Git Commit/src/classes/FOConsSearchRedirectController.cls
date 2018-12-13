public class FOConsSearchRedirectController {
    public String getSearchURL() {
        AppMenuItem eccApp = [
            select 
                id, Name
            from 
                AppMenuItem 
            where 
                Name = 'FO'];
        return URL.getSalesforceBaseUrl().toExternalForm() + '/console?tsid=' + eccApp.Name;
    }
}