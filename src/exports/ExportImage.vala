/*
* Copyright (c) 2018 (https://github.com/phase1geo/Minder)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Trevor Williams <phase1geo@gmail.com>
*/

using Cairo;
using Gdk;
using Gtk;

public class ExportImage : Object {

  /* Default constructor */
  public static void export( string fname, string type, DrawArea da ) {

    /* Get the rectangle holding the entire document */
    double x, y, w, h;
    da.document_rectangle( out x, out y, out w, out h );

    /* Create the drawing surface */
    var surface = new ImageSurface( Format.RGB24, ((int)w + 20), ((int)h + 20) );
    var context = new Context( surface );

    /* Translate the image */
    context.translate( (10 - x), (10 - y) );

    /* Recreate the image */
    da.draw_background( context );
    da.draw_all( context );

    /* Write the pixbuf to the file */
    var pixbuf = pixbuf_get_from_surface( surface, 0, 0, ((int)w + 20), ((int)h + 20) );

    try {
      pixbuf.save( fname, type );
    } catch( Error e ) {
      stdout.printf( "Error writing %s: %s\n", type, e.message );
    }

  }

}
