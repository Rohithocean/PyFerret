/* Python.h should always be first */
#include <Python.h>
#include <string.h>
#include "grdel.h"
#include "cferbind.h"
#include "cairoCFerBind.h"
#include "FerMem.h"

/*
 * Delete a font object for this "Window".
 *
 * Returns one if successful.   If an error occurs, grdelerrmsg
 * is assigned an appropriate error message and zero is returned.
 */
grdelBool cairoCFerBind_deleteFont(CFerBind *self, grdelType font)
{
    CCFBFont *fontobj;

    /* Sanity check */
    if ( (self->enginename != CairoCFerBindName) &&
         (self->enginename != PyQtCairoCFerBindName) ) {
        strcpy(grdelerrmsg, "cairoCFerBind_deleteFont: unexpected error, "
                            "self is not a valid CFerBind struct");
        return 0;
    }

    fontobj = (CCFBFont *) font;
    if ( fontobj->id != CCFBFontId ) {
        strcpy(grdelerrmsg, "cairoCFerBind_deleteFont: unexpected error, "
                            "font is not CCFBFont struct");
        return 0;
    }

#ifdef USEPANGOCAIRO
    if ( fontobj->fontdesc != NULL ) {
        pango_font_description_free(fontobj->fontdesc);
        fontobj->fontdesc = NULL;
    }
#else
    if ( fontobj->fontface != NULL ) {
        cairo_font_face_destroy(fontobj->fontface);
        fontobj->fontface = NULL;
    }
#endif

    /* Wipe the id to detect errors */
    fontobj->id = NULL;

    /* Free the memory */
    FerMem_Free(font, __FILE__, __LINE__);

    return 1;
}

