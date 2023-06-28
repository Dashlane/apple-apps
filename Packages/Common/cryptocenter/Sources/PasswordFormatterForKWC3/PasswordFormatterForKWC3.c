#include "PasswordFormatterForKWC3.h"
#include <stdbool.h>

// This is code for backward support due to the early versions of Dashlane.
// The original encoding used for the client apps were not based on UTF8 at
// the time, hence some very old accounts were created with an encoding
// that was not UTF8. In order to continue to support these old accounts
// this code was added.


static bool isUnicodeNonCharacter(unsigned int ucs4);
static unsigned char highSurrogate(unsigned int ucs4);
static unsigned char lowSurrogate(unsigned int ucs4);

bool isUnicodeNonCharacter(unsigned int ucs4)
{
    // Unicode has a couple of "non-characters" that one can use internally,
    // but are not allowed to be used for text interchange.
    //
    // Those are the last two entries each Unicode Plane (U+FFFE, U+FFFF,
    // U+1FFFE, U+1FFFF, etc.) as well as the entries between U+FDD0 and
    // U+FDEF (inclusive)
    
    return (ucs4 & 0xfffe) == 0xfffe
    || (ucs4 - 0xfdd0U) < 16;
}

unsigned char highSurrogate(unsigned int ucs4) {
    return (unsigned char)((ucs4>>10) + 0xd7c0);
}
unsigned char lowSurrogate(unsigned int ucs4) {
    return (unsigned char)(ucs4%0x400 + 0xdc00);
}

char* doTheMagic(const char* chars, int* len) {
    
    bool headerdone = false;
    unsigned char replacement = 0xfd;
    int need = 0;
    int error = -1;
    unsigned int uc = 0;
    unsigned int min_uc = 0;
    
    if( !headerdone && *len > 3 && (unsigned char)chars[0] == 0xef && (unsigned char)chars[1] == 0xbb && (unsigned char)chars[2] == 0xbf)
    {
        // starts with a byte order mark
        chars += 3;
        len -= 3;
        headerdone = true;
    }
    
    char *result = malloc(need + *len + 1);// char[need + *len + 1]; // worst case
    unsigned char *qch = (unsigned char *)result;
    unsigned char ch;
    int invalid = 0;
    
    for (int i = 0; i < *len; ++i) {
        ch = chars[i];
        if (need) {
            if ((ch&0xc0) == 0x80) {
                uc = (uc << 6) | (ch & 0x3f);
                --need;
                if (!need) {
                    // utf-8 bom composes into 0xfeff code point
                    bool nonCharacter = isUnicodeNonCharacter(uc);
                    if (!headerdone && uc == 0xfeff) {
                        // dont do anything, just skip the BOM
                    } else if (!(nonCharacter) && uc > 0xffff && uc < 0x110000) {
                        // surrogate pair
                        *qch++ = highSurrogate(uc);
                        *qch++ = lowSurrogate(uc);
                    } else if ((uc < min_uc) || (uc >= 0xd800 && uc <= 0xdfff) || nonCharacter || uc >= 0x110000) {
                        // error: overlong sequence, UTF16 surrogate or non-character
                        *qch++ = replacement;
                        ++invalid;
                    } else {
                        *qch++ = (unsigned char)uc;
                    }
                    headerdone = true;
                }
            } else {
                // error
                i = error;
                *qch++ = replacement;
                ++invalid;
                need = 0;
                headerdone = true;
            }
        } else {
            if (ch < 128) {
                *qch++ = (unsigned char)(ch);
                headerdone = true;
            } else if ((ch & 0xe0) == 0xc0) {
                uc = ch & 0x1f;
                need = 1;
                error = i;
                min_uc = 0x80;
                headerdone = true;
            } else if ((ch & 0xf0) == 0xe0) {
                uc = ch & 0x0f;
                need = 2;
                error = i;
                min_uc = 0x800;
            } else if ((ch&0xf8) == 0xf0) {
                uc = ch & 0x07;
                need = 3;
                error = i;
                min_uc = 0x10000;
                headerdone = true;
            } else {
                // error
                *qch++ = replacement;
                ++invalid;
                headerdone = true;
            }
        }
    }
    if ( need > 0)
    {
        // unterminated UTF sequence
        for (int i = error; i < *len; ++i) {
            *qch++ = replacement;
            ++invalid;
        }
    }
    *len = (int)(qch - (unsigned char*)result);
    return result;
}
