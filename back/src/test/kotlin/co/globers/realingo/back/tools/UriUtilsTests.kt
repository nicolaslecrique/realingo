package co.globers.realingo.back.tools

import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test

class UriUtilsTests {

    @Test
    fun testGenerateUriByClean() {
        Assertions.assertEquals("with-space-B8B8F25A5FC7", generateUri("with space"))
        Assertions.assertEquals("e-ecauai-99B50C561531", generateUri("&é(---è_çà)]°ùμâï?./!*"))
        Assertions.assertEquals("-8FC6BBF80D17", generateUri("風俗通義"))
    }

}
