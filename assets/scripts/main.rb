require 'ruboto'
require 'custom_methods'

confirm_ruboto_version(6, false)

java_import "android.provider.ContactsContract"
java_import "android.content.ContentResolver"
java_import "android.content.Context"
java_import "android.database.Cursor"
java_import "android.widget.ArrayAdapter"
java_import "android.widget.CursorAdapter"
java_import "android.widget.SimpleCursorAdapter"
java_import "android.text.method.ScrollingMovementMethod"
java_import "android.view.WindowManager"
java_import "android.view.Gravity"
java_import "android.view.KeyEvent"
java_import "android.text.util.Linkify"
java_import "android.app.AlertDialog"
java_import "android.content.DialogInterface"
java_import "android.content.Intent"
java_import "android.net.Uri"
java_import "android.app.AlertDialog"

ruboto_import "org.ruboto.callbacks.RubotoOnTabChangeListener"
ruboto_import "org.ruboto.callbacks.RubotoOnKeyListener"

ruboto_import_widgets :TextView, :NumberPicker, :TabHost, :LinearLayout, :Button, :ListView, :TabWidget, :FrameLayout, :EditText, :ToggleButton, :ScrollView, :Spinner

def contacts_list
  @cur = contacts_cursor
  @contacts = []
  if @cur.getCount > 0
    while @cur.moveToNext do
      @contacts << @cur.getString(@cur.getColumnIndex(ContactsContract::Contacts::DISPLAY_NAME))
    end
  end
  @contacts
end

def cr
  @cr ||= getContentResolver
end

def contacts_cursor
  @contacts_cursor ||= cr.query ContactsContract::Contacts::CONTENT_URI, nil, nil, nil, nil
  @contacts_cursor
end

#call the contact
def call(number)
  intent = Intent.new(Intent::ACTION_CALL)
  intent.setData(Uri.parse("tel:#{number}"))
  self.startActivity(intent)
end

def call_number_from_contact(contact_cursor)
  count_phone_numbers = contact_cursor.getString(contact_cursor.getColumnIndex(ContactsContract::Contacts::HAS_PHONE_NUMBER)).to_i
  return nil if count_phone_numbers == 0

  id = contact_cursor.getString(contact_cursor.getColumnIndex(ContactsContract::Contacts::LOOKUP_KEY))
  phone_cursor = cr.query( ContactsContract::CommonDataKinds::Phone::CONTENT_URI, nil,
                            ContactsContract::Contacts::LOOKUP_KEY + " = ?", [id], nil)

  if phone_cursor.getCount == 1
    phone_cursor.moveToFirst
    phone     = phone_cursor.getString(phone_cursor.getColumnIndex(ContactsContract::CommonDataKinds::Phone::DATA))
    phoneType = phone_cursor.getString(phone_cursor.getColumnIndex(ContactsContract::CommonDataKinds::Phone::TYPE))
    phone_cursor.close
    call(phone)
  else
    adapter = SimpleCursorAdapter.new(self, 
            R::layout::simple_list_item_1, 
            phone_cursor, 
            [ContactsContract::CommonDataKinds::Phone::DATA, ContactsContract::CommonDataKinds::Phone::TYPE],
            [AndroidIds::text1])

    AlertDialog::Builder.new(self).
      setTitle("Phones list").
      setAdapter(adapter, @alert_dialog_phones_select_listener).
      create.
      show
  end
end

@alert_dialog_phones_select_listener = RubotoOnItemClickListener.new.handle_item_click do |i|
  # call_number(i)
  Log.i("Click", "rubuto has been clicked")
end

$activity.start_ruboto_activity "$index" do
  setTitle "Time My Call"

  # setup_content do
  #   @tabs = tab_host do
  #     linear_layout(:orientation => LinearLayout::VERTICAL, :height => :fill_parent) do
  #       tab_widget(:id => AndroidIds::tabs)
  #       frame_layout(:id => AndroidIds::tabcontent, :height => :fill_parent) do
  #         linear_layout :id => 55555, :orientation => LinearLayout::VERTICAL, :width => :fill_parent do
  #           #select time
  #           linear_layout :orientation => LinearLayout::HORIZONTAL do
  #             @hour_picker    = number_picker.setRange(0, 24)
  #             @minutes_picker = number_picker.setRange(0, 60)
  #             @second_picker  = number_picker.setRange(0, 60)
  #           end
  #           text_view :text => "Select the time when to cut off the call"
  #           linear_layout :orientation => LinearLayout::HORIZONTAL do
  #             text_view :text => "Auto recall"
  #             toggle_button :width => :wrap_content
  #           end
  #           button :text => "call"
  #         end
  #         @contacts = list_view :id => 55556, :list => contacts_list
  #         linear_layout(:id => 55557, :orientation => LinearLayout::VERTICAL) do
  #         end
  #       end
  #     end
  #   end
  #   registerForContextMenu(@contacts)
  #   
  #   @tabs.setup
  #   @tabs.addTab(@tabs.newTabSpec("main").setContent(55555).setIndicator("Main"))
  #   @tabs.addTab(@tabs.newTabSpec("contacts").setContent(55556).setIndicator("Contacts"))
  #   @tabs.addTab(@tabs.newTabSpec("history").setContent(55557).setIndicator("History"))
  #   @tabs.setOnTabChangedListener(@on_tab_change_listener)
  #   @tabs
  #   
  # end
  #
  # Tab change
  #

  # @on_tab_change_listener = RubotoOnTabChangeListener.new.handle_tab_changed do |tab|
  #   if tab == "scripts"
  #       getSystemService(Context::INPUT_METHOD_SERVICE).
  #          hideSoftInputFromWindow(@tabs.getWindowToken, 0)
  #   end
  # end


  setup_content do
    linear_layout :orientation => LinearLayout::VERTICAL do
      linear_layout :orientation => LinearLayout::VERTICAL, :gravity => Gravity::CENTER_HORIZONTAL do
        text_view :text => "Select the time when to cut off the call"

        linear_layout :orientation => LinearLayout::HORIZONTAL, :gravity => Gravity::CENTER_HORIZONTAL do
          @hour_picker    = number_picker.setRange(0, 24)
          @minutes_picker = number_picker.setRange(0, 60)
          @second_picker  = number_picker.setRange(0, 60)
        end

        startManagingCursor(contacts_cursor);

        @adapter = SimpleCursorAdapter.new(self, 
                R::layout::simple_list_item_1, 
                contacts_cursor, 
                [ContactsContract::Contacts::DISPLAY_NAME],
                [AndroidIds::text1])

        @contact_spinner = spinner :prompt => 'Choose your contact'
        @contact_spinner.setAdapter(@adapter)

        toggle_button :width => :wrap_content, :textOff => 'Auto recall OFF', :textOn => 'Auto recall ON' 
        button :text => "CALL"
      end
    end
  end

  handle_create_options_menu do |menu|
    add_menu("Exit") {finish}

    true
  end

  handle_click do |view|
    case view.getText
    when "CALL":
      contact_cursor = @contact_spinner.getSelectedItem
      if contact_cursor
        call_number_from_contact(contact_cursor)
      end
    end
  end

end
