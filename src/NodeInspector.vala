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

using Gtk;
using Gdk;
using Granite.Widgets;

public class NodeInspector : Stack {

  private Entry       _name;
  private Switch      _task;
  private Switch      _fold;
  private Box         _link_box;
  private ColorButton _link_color;
  private TextView    _note;
  private DrawArea    _da;
  private Button      _detach_btn;
  private string      _orig_note = "";
  private Node?       _node = null;

  public NodeInspector( DrawArea da ) {

    _da = da;

    /* Set the transition duration information */
    transition_duration = 500;
    transition_type     = StackTransitionType.OVER_DOWN_UP;

    var empty_box = new Box( Orientation.VERTICAL, 10 );
    var empty_lbl = new Label( _( "<big>Select a node to view/edit information</big>" ) );
    var node_box  = new Box( Orientation.VERTICAL, 10 );

    empty_lbl.use_markup = true;
    empty_box.pack_start( empty_lbl, true, true );

    add_named( node_box,  "node" );
    add_named( empty_box, "empty" );

    /* Create the node widgets */
    create_title( node_box );
    create_task( node_box );
    create_fold( node_box );
    create_link( node_box );
    create_note( node_box );
    create_buttons( node_box );

    _da.node_changed.connect( node_changed );
    _da.theme_changed.connect( theme_changed );

    show_all();

  }

  /* Returns the width of this window */
  public int get_width() {
    return( 300 );
  }

  /* Creates the name entry */
  private void create_title( Box bbox ) {

    Box   box = new Box( Orientation.VERTICAL, 2 );
    Label lbl = new Label( _( "Title" ) );

    _name = new Entry();
    _name.activate.connect( name_changed );
    _name.focus_out_event.connect( name_focus_out );

    lbl.xalign = (float)0;

    box.pack_start( lbl,   true, false );
    box.pack_start( _name, true, false );

    bbox.pack_start( box, false, true );

  }

  /* Creates the task UI elements */
  private void create_task( Box bbox ) {

    var box  = new Box( Orientation.HORIZONTAL, 0 );
    var lbl  = new Label( _( "Task" ) );

    lbl.xalign = (float)0;

    _task = new Switch();
    _task.button_release_event.connect( task_changed );

    box.pack_start( lbl,   false, true, 0 );
    box.pack_end(   _task, false, true, 0 );

    bbox.pack_start( box, false, true );

  }

  /* Creates the fold UI elements */
  private void create_fold( Box bbox ) {

    var box = new Box( Orientation.HORIZONTAL, 0 );
    var lbl = new Label( _( "Fold" ) );

    lbl.xalign = (float)0;

    _fold = new Switch();
    _fold.button_release_event.connect( fold_changed );

    box.pack_start( lbl,   false, true, 0 );
    box.pack_end(   _fold, false, true, 0 );

    bbox.pack_start( box, false, true );

  }

  /*
   Allows the user to select a different color for the current link
   and tree.
  */
  private void create_link( Box bbox ) {

    _link_box = new Box( Orientation.HORIZONTAL, 0 );
    var lbl   = new Label( _( "Link Color" ) );

    _link_box.homogeneous = true;
    lbl.xalign            = (float)0;

    _link_color = new ColorButton();
    _link_color.color_set.connect(() => {
      _da.change_current_link_color( _link_color.rgba );
    });

    _link_box.pack_start( lbl,         false, true, 0 );
    _link_box.pack_end(   _link_color, true,  true, 0 );

    bbox.pack_start( _link_box, false, true );

  }

  /* Creates the note widget */
  private void create_note( Box bbox ) {

    Box   box = new Box( Orientation.VERTICAL, 0 );
    Label lbl = new Label( _( "Note" ) );

    lbl.xalign = (float)0;

    _note = new TextView();
    _note.set_wrap_mode( Gtk.WrapMode.WORD );
    _note.buffer.text = "";
    _note.buffer.changed.connect( note_changed );
    _note.focus_in_event.connect( note_focus_in );
    _note.focus_out_event.connect( note_focus_out );

    ScrolledWindow sw = new ScrolledWindow( null, null );
    sw.min_content_width  = 300;
    sw.min_content_height = 300;
    sw.add( _note );

    box.pack_start( lbl, false, false );
    box.pack_start( sw,  true,  true );

    bbox.pack_start( box, true, true );

  }

  /* Creates the node editing button grid and adds it to the popover */
  private void create_buttons( Box bbox ) {

    var grid = new Grid();
    grid.column_homogeneous = true;
    grid.column_spacing     = 5;

    var copy_btn = new Button.from_icon_name( "edit-copy-symbolic", IconSize.SMALL_TOOLBAR );
    copy_btn.set_tooltip_text( _( "Copy Node To Clipboard" ) );
    copy_btn.clicked.connect( node_copy );

    var cut_btn = new Button.from_icon_name( "edit-cut-symbolic", IconSize.SMALL_TOOLBAR );
    cut_btn.set_tooltip_text( _( "Cut Node To Clipboard" ) );
    cut_btn.clicked.connect( node_cut );

    /* Create the detach button */
    _detach_btn = new Button.from_icon_name( "minder-detach-symbolic", IconSize.SMALL_TOOLBAR );
    _detach_btn.set_tooltip_text( _( "Detach Node" ) );
    _detach_btn.clicked.connect( node_detach );

    /* Create the node deletion button */
    var del_btn = new Button.from_icon_name( "edit-delete-symbolic", IconSize.SMALL_TOOLBAR );
    del_btn.set_tooltip_text( _( "Delete Node" ) );
    del_btn.clicked.connect( node_delete );

    /* Add the buttons to the button grid */
    grid.attach( copy_btn,    0, 0, 1, 1 );
    grid.attach( cut_btn,     1, 0, 1, 1 );
    grid.attach( _detach_btn, 2, 0, 1, 1 );
    grid.attach( del_btn,     3, 0, 1, 1 );

    /* Add the button grid to the popover */
    bbox.pack_start( grid, false, true );

  }

  /*
   Called whenever the node name is changed within the inspector.
  */
  private void name_changed() {
    _da.change_current_name( _name.text );
  }

  /*
   Called whenever the node title loses input focus. Updates the
   node title in the canvas.
  */
  private bool name_focus_out( EventFocus e ) {
    _da.change_current_name( _name.text );
    return( false );
  }

  /* Called whenever the task enable switch is changed within the inspector */
  private bool task_changed( Gdk.EventButton e ) {
    Node? current = _da.get_current_node();
    if( current != null ) {
      _da.change_current_task( !current.task_enabled(), false );
    }
    return( false );
  }

  /* Called whenever the fold switch is changed within the inspector */
  private bool fold_changed( Gdk.EventButton e ) {
    Node? current = _da.get_current_node();
    if( current != null ) {
      _da.change_current_fold( !current.folded );
    }
    return( false );
  }

  /*
   Called whenever the text widget is changed.  Updates the current node
   and redraws the canvas when needed.
  */
  private void note_changed() {
    _da.change_current_note( _note.buffer.text );
  }

  /* Saves the original version of the node's note so that we can */
  private bool note_focus_in( EventFocus e ) {
    _node      = _da.get_current_node();
    _orig_note = _note.buffer.text;
    return( false );
  }

  /* When the note buffer loses focus, save the note change to the undo buffer */
  private bool note_focus_out( EventFocus e ) {
    if( (_node != null) && (_node.note != _orig_note) ) {
      _da.undo_buffer.add_item( new UndoNodeNote( _da, _node, _orig_note ) );
    }
    return( false );
  }

  /* Copies the current node to the clipboard */
  private void node_copy() {
    _da.copy_node_to_clipboard();
  }

  /* Cuts the current node to the clipboard */
  private void node_cut() {
    _da.cut_node_to_clipboard();
  }

  /* Detaches the current node and makes it a parent node */
  private void node_detach() {
    _da.detach();
    _detach_btn.set_sensitive( false );
  }

  /* Deletes the current node */
  private void node_delete() {
    _da.delete_node();
  }

  /* Grabs the input focus on the name entry */
  public void grab_name() {
    _name.grab_focus();
  }

  /* Grabs the focus on the note widget */
  public void grab_note() {
    _note.grab_focus();
  }

  /* Called whenever the theme is changed */
  private void theme_changed() {

    int    num_colors = _da.get_theme().num_link_colors();
    RGBA[] colors     = new RGBA[num_colors];

    /* Gather the theme colors into an RGBA array */
    for( int i=0; i<num_colors; i++ ) {
      colors[i] = _da.get_theme().link_color( i );
    }

    /* Clear the palette */
    _link_color.add_palette( Orientation.HORIZONTAL, 10, null );

    /* Set the palette with the new theme colors */
    _link_color.add_palette( Orientation.HORIZONTAL, 10, colors );

  }

  /* Called whenever the user changes the current node in the canvas */
  private void node_changed() {

    Node? current = _da.get_current_node();

    if( current != null ) {
      _name.set_text( current.name );
      _task.set_active( current.task_enabled() );
      if( current.is_leaf() ) {
        _fold.set_active( false );
        _fold.set_sensitive( false );
      } else {
        _fold.set_active( current.folded );
        _fold.set_sensitive( true );
      }
      if( current.is_root() ) {
        _link_box.visible = false;
      } else {
        _link_box.visible = true;
        _link_color.rgba  = current.link_color;
        _link_color.alpha = 65535;
      }
      _detach_btn.set_sensitive( current.parent != null );
      _note.buffer.text = current.note;
      set_visible_child_name( "node" );
    } else {
      set_visible_child_name( "empty" );
    }

  }

}
