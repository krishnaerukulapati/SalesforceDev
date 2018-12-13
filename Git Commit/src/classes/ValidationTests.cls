@isTest
private class ValidationTests {
	@isTest static void CanValidatePhone()
	{
		//positive tests
		Boolean expectedResult = true;
		Boolean retVal = Validation.IsValidPhoneNumber('9015176262');
		system.assert(retVal == expectedResult);

		retVal = Validation.IsValidPhoneNumber('19015176262');
		system.assert(retVal == expectedResult);


		//negative tests
		expectedResult = false;

		retVal = Validation.IsValidPhoneNumber('0015176262');
		system.assert(retVal == expectedResult);

		retVal = Validation.IsValidPhoneNumber('1015176262');
		system.assert(retVal == expectedResult);

		retVal = Validation.IsValidPhoneNumber('1115176262');
		system.assert(retVal == expectedResult);

		retVal = Validation.IsValidPhoneNumber('001517626');
		system.assert(retVal == expectedResult);

		retVal = Validation.IsValidPhoneNumber('(001) 517-6262');
		system.assert(retVal == expectedResult);

		retVal = Validation.IsValidPhoneNumber('(a01) 517-6262');
		system.assert(retVal == expectedResult);

		retVal = Validation.IsValidPhoneNumber('90151a1176262');
		system.assert(retVal == false);

		retVal = Validation.IsValidPhoneNumber('19015b176262');
		system.assert(retVal == expectedResult);

		retVal = Validation.IsValidPhoneNumber('9015b+1762620');
		system.assert(retVal == expectedResult);

		retVal = Validation.IsValidPhoneNumber('9015176262 ext. 1234');
		system.assert(retVal == expectedResult);


		retVal = Validation.IsValidPhoneNumber('');
		system.assert(retVal == expectedResult);


		retVal = Validation.IsValidPhoneNumber(null);
		system.assert(retVal == expectedResult);
	}
}