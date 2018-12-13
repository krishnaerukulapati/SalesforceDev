public with sharing class Validation {
	public static Boolean IsValidPhoneNumber(string phone)
	{
		if (String.isEmpty(phone) || 
			phone == null || 
			(phone.length() == 10 && (phone.left(1) == '0' || phone.left(1) == '1')) || 	//handles 023-234-2344
			(phone.length() == 11 && phone.left(1) != '1') || 	//handles 99015176262
			(phone.length() == 11 && (phone.left(2) == '10' || phone.left(2) == '11')) ||  //handles 1022-345-6789 
			phone.left(2) == '(0')
			return false;


        String regExp = '^\\d{10,11}?$';
      	Pattern MyPattern = Pattern.compile(regExp);
        Matcher MyMatcher = MyPattern.matcher(phone);
        Boolean isValid = MyMatcher.matches();

        system.debug('isValid='+String.valueOf(isValid));
		return isValid;
	}

}