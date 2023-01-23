#ifndef PasswordFormatterForKWC3_h
#define PasswordFormatterForKWC3_h
#include <stdlib.h>

/// This method encode a Password in a custom way so it matches the legacy implementation on Windows
/// All Dashlane Clients uses this custom encoding commonly known as "doTheMagic"
/// @param chars the Password to encode
/// @param len the length of the given password
char* doTheMagic(const char* num1, int* num2);

#endif /* PasswordFormatterForKWC3_h */
