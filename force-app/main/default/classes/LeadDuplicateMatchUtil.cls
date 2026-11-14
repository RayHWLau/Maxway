public without sharing class LeadDuplicateMatchUtil {

    private static final String HK_COUNTRY_CODE = 'Hong Kong (852)';
    private static final String MACAU_COUNTRY_CODE = 'Macau (853)';
    private static final String CHINA_COUNTRY_CODE = 'China (86)';

    @TestVisible
    public static String normalizeMobileForComparison(String mobileValue, String countryCode) {
        String digitsOnly = digitsOnly(mobileValue);
        if (String.isBlank(digitsOnly)) {
            return null;
        }

        if (countryCode == HK_COUNTRY_CODE || countryCode == MACAU_COUNTRY_CODE) {
            return rightDigits(digitsOnly, 8);
        }
        if (countryCode == CHINA_COUNTRY_CODE) {
            return rightDigits(digitsOnly, 11);
        }
        return digitsOnly;
    }

    public static void addEmailToken(Set<String> emailTokenSet, String emailValue) {
        if (String.isNotBlank(emailValue)) {
            emailTokenSet.add(emailValue.trim().toLowerCase());
        }
    }

    public static Boolean matchesEmail(Set<String> emailTokens, String primaryEmail, String secondaryEmail) {
        String normalizedPrimaryEmail = String.isBlank(primaryEmail) ? null : primaryEmail.trim().toLowerCase();
        String normalizedSecondaryEmail = String.isBlank(secondaryEmail) ? null : secondaryEmail.trim().toLowerCase();

        return (normalizedPrimaryEmail != null && emailTokens.contains(normalizedPrimaryEmail)) ||
               (normalizedSecondaryEmail != null && emailTokens.contains(normalizedSecondaryEmail));
    }

    public static Boolean matchesMobile(String mobileToken, String mobileValue, String countryCode) {
        if (String.isBlank(mobileToken)) {
            return false;
        }
        return normalizeMobileForComparison(mobileValue, countryCode) == mobileToken;
    }

    private static String digitsOnly(String inputValue) {
        if (String.isBlank(inputValue)) {
            return null;
        }

        String cleanedValue = '';
        for (Integer index = 0; index < inputValue.length(); index++) {
            String currentChar = inputValue.substring(index, index + 1);
            if (currentChar >= '0' && currentChar <= '9') {
                cleanedValue += currentChar;
            }
        }
        return cleanedValue;
    }

    private static String rightDigits(String inputValue, Integer count) {
        if (String.isBlank(inputValue)) {
            return null;
        }
        if (inputValue.length() <= count) {
            return inputValue;
        }
        return inputValue.substring(inputValue.length() - count);
    }
}