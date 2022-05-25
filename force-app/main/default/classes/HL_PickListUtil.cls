/*
 * Name: HL_PickListUtil 
 * Created Date: 09/06/2019
 * Created By: Kishan J
 * Functionality : Utility class which returns the dependent values for the parent field
 */

public class HL_PickListUtil {

	public static Map<String, List<dependentPicklistWrapper>> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField) {
		// validFor property cannot be accessed via a method or a property,
		// so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
		List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
		List<PicklistEntryWrapper> depEntries =
				HL_PickListUtil.wrapPicklistEntries(theField.getDescribe().getPicklistValues());

		// Set up the return container - Map<ControllingValue, List<DependentValues>>
		Map<String, List<dependentPicklistWrapper>> objResults = new Map<String, List<dependentPicklistWrapper>>();
		List<String> controllingValues = new List<String>();

		for (Schema.PicklistEntry ple : contrEntries) {
			String value = ple.getValue();
			objResults.put(value, new List<dependentPicklistWrapper>());
			controllingValues.add(value);
		}

		for (PicklistEntryWrapper plew : depEntries) {
			dependentPicklistWrapper dependentPicklistWrapper = new dependentPicklistWrapper();
            dependentPicklistWrapper.value = plew.value;
            String label = plew.label;
            dependentPicklistWrapper.label = label.contains('\'') ? label.replace('\'',' ') : label;
			String validForBits = base64ToBits(plew.validFor);
        // For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
			for (Integer i = 0; i < validForBits.length(); i++) {
				String bit = validForBits.mid(i, 1);
				if (bit == '1') {
					objResults.get(controllingValues.get(i)).add(dependentPicklistWrapper);
				}
			}
		}

		return objResults;
	}

	// Convert decimal to binary representation (alas, Apex has no native method :-(
	//    eg. 4 => '100', 19 => '10011', etc.
	// Method: Divide by 2 repeatedly until 0. At each step note the remainder (0 or 1).
	// These, in reverse order, are the binary.
	public static String decimalToBinary(Integer val) {
		String bits = '';
		while (val > 0) {
			Integer remainder = Math.mod(val, 2);
			val = Integer.valueOf(Math.floor(val / 2));
			bits = String.valueOf(remainder) + bits;
		}
		return bits;
	}

	// Convert a base64 token into a binary/bits representation
	// e.g. 'gAAA' => '100000000000000000000'
	public static String base64ToBits(String validFor) {
		if (String.isEmpty(validFor)) return '';

		String validForBits = '';

		for (Integer i = 0; i < validFor.length(); i++) {
			String thisChar = validFor.mid(i, 1);
			Integer val = base64Chars.indexOf(thisChar);
			String bits = decimalToBinary(val).leftPad(6, '0');
			validForBits += bits;
		}
		return validForBits;
	}


	private static final String base64Chars = '' +
			'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
			'abcdefghijklmnopqrstuvwxyz' +
			'0123456789+/';


	private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
		return (List<PicklistEntryWrapper>)
			JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
	}

	public class PicklistEntryWrapper {
		public String active {get; set;}
		public String defaultValue {get; set;}
		public String label {get; set;}
		public String value {get; set;}
		public String validFor {get; set;}
	}
    public class dependentPicklistWrapper{
        public String label {get; set;}
		public String value {get; set;}
    } 
}