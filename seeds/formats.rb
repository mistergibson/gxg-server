def seed_formats()
    format_manifest = {}
    format_template = GxG::DB[:roles][:formats].format_template()
    #
    file_format = {:mime=>"application/octet-stream", :meta => {}, :file_segments => []}
    component_format = {:component=>"<component-class>", :settings => {}, :options => {}, :script=>"", :content=>[]}
    app_format = {:component => "application", :requirements => [], :options=>{}, :script=>"", :content=>[]}
    lib_format = {:component => "library", :type => "text/ruby", :requirements => [], :options=>{}, :script=>"", :content=>[]}
    page_format = {
        :component => "org.gxg.gui.page",
        :requirements => [],
        :auto_start => [],
        :settings => {:page_title => "Untitled Page", :theme => "default", :accesskey => "", :contenteditable => false, :dir => "ltr", :draggable => false, :dropzone => "", :lang => "en", :spellcheck => false, :translate => "no"},
        :options => {:style => {}, :states => ["page"], :tabindex => 0},
        :script => "",
        :content => []
    }
    # User Avatar
    format_manifest[:avatar] = {
        :uuid => :"50ede549-c464-42a4-a4bd-f062d1765dfd",
        :version => 0.0,
        :ufs => "org.gxg.person.avatar",
        :title => "Personal Avatar",
        :mime_types => [],
        :content => {
            :image_format => "application/octet-stream",
            :image_data => ::GxG::ByteArray.new
        }
    }
    # Email
    format_manifest[:email] = {
        :uuid => :"fed5c452-2dc7-43af-861f-611779f0c484",
        :version => 0.0,
        :ufs => "org.gxg.email",
        :title => "Email",
        :mime_types => [],
        :content => {
            :address => "",
            :desires_html => false
        }
    }
    # Phone
    format_manifest[:phone] = {
        :uuid => :"04b05802-24a6-471a-9ff5-537109fab684",
        :version => 0.0,
        :ufs => "org.gxg.phone",
        :title => "Phone Number",
        :mime_types => [],
        :content => {
            :country_code => "",
            :number => "",
            :extension => "",
            :allows_sms => false
        }
    }
    # GeoLocation Data
    format_manifest[:geolocation] = {
        :uuid => :"bf665578-b816-43ae-8b8a-08998623225f",
        :version => 0.0,
        :ufs => "org.gxg.geolocation",
        :title => "Geolocation Data",
        :mime_types => [],
        :content => {
            :latitude => "",
            :longitude => "",
            :altitude => "",
            :perimeter_data => nil
        }
    }
    # Region
    format_manifest[:region] = {
        :uuid => :"9fcbba4b-f6bf-464d-a030-59aadea64627",
        :version => 0.0,
        :ufs => "org.gxg.region",
        :title => "Region",
        :mime_types => [],
        :content => {
            :within_region_uuid => nil,
            :scale => "",
            :designation => "",
            :iso_code => "",
            :iso_number => "",
            :iso_two_letter => "",
            :iso_three_letter => "",
            :iso_name => "",
            :abbreviation => "",
            :name => "",
            :region_avatar => nil,
            :region_flag_avatar => nil,
            :settings => {},
            :areas => [],
            :geolocation_uuid => nil
        }
    }
    # Address
    # ### territory and nation use Region uuids.
    format_manifest[:address] = {
        :uuid => :"42d3861c-630a-43fc-a26d-a387552ef705",
        :version => 0.0,
        :ufs => "org.gxg.address",
        :title => "Address",
        :mime_types => [],
        :content => {
            :address_one => "",
            :address_two => "",
            :city => "",
            :territory_uuid => "",
            :nation_uuid => "",
            :postal_code => "",
            :geolocation_uuid => nil
        }
    }
    # Vehicle
    format_manifest[:vehicle] = {
        :uuid => :"0a446e2e-a868-4271-86b0-ff35accb1306",
        :version => 0.0,
        :ufs => "org.gxg.vehicle",
        :title => "Vehicle Profile",
        :mime_types => [],
        :content => {
            :vehicle_id_number => "",
            :vehicle_type => "",
            :vehicle_make => "",
            :vehicle_model => "",
            :plate_id => "",
            :plate_jurisdiction => "",
            :plate_expiration => nil
        }
    }
    # Organization
    # ## use 'person' as 'contact' record.
    format_manifest[:organization] = {
        :uuid => :"b529aa78-0471-42fe-a615-d26355f090fa",
        :version => 0.0,
        :ufs => "org.gxg.organization",
        :title => "Organization Profile",
        :mime_types => [],
        :content => {
            :organization_type => "",
            :description => "",
            :logo_avatar_uuid => "",
            :website => "",
            :main_contact_uuid => "",
            :technical_contact_uuid => "",
            :development_contact_uuid => "",
            :engineering_contact_uuid => "",
            :billing_contact_uuid => "",
            :shipping_contact_uuid => "",
            :sales_contact_uuid => "",
            :marketing_contact_uuid => "",
            :press_contact_uuid => ""
        }
    }
    # Occupation
    format_manifest[:occupation] = {
        :uuid => :"a10498e3-b7db-46e6-9594-cf9de14d4675",
        :version => 0.0,
        :ufs => "org.gxg.person.occupation",
        :title => "Occupational Profile",
        :mime_types => [],
        :content => {
            :organization_uuid => "",
            :organizational_unit => "",
            :organizaional_category => "",
            :department => "",
            :occupational_title => "",
            :occupational_id => "",
            :occupational_type => "",
            :assigned_vehicle => nil,
            :office_name => "",
            :room_number => ""
        }
    }
    # Person
    format_manifest[:person] = {
        :uuid => :"98ef36a3-c5ef-48ba-ad83-c7b81367a750",
        :version => 0.0,
        :ufs => "org.gxg.person",
        :title => "Person",
        :mime_types => [],
        :content => {
            :prefix => "",
            :first_name => "",
            :middle_name => "",
            :last_name => "",
            :suffix => "",
            :initials => "",
            :description => "",
            :avatar => nil,
            :work_email => nil,
            :home_email => nil,
            :work_phone => nil,
            :work_fax => nil,
            :home_phone => nil,
            :home_fax => nil,
            :mobile_phone => nil,
            :work_website => "",
            :home_website => "",
            :occupation => nil,
            :birthday => nil
        }
    }
    # Device
    format_manifest[:device] = {
        :uuid => :"950fdcdb-9b1e-4d31-ae1d-6d0ac5627b8e",
        :version => 0.0,
        :ufs => "org.gxg.device",
        :title => "Device Profile",
        :mime_types => [],
        :content => {
            :hostname => "",
            :ipv4 => "",
            :ipv6 => "",
            :reverse_dns => "",
            :operating_system => "",
            :operating_system_version => "",
            :total_memory => 0,
            :total_storage => 0,
            :location => nil
        }
    }
    # Exchange Service Profile
    # Note : :currency_uuid refers to the exchange currency of record
    # Note : (StoreFront Service??) if used in 'store-front' mode. one member becomes proprieter all others registered customers.
    format_manifest[:exchange] = {
        :uuid => :"16864dba-781d-4930-86e0-9beaf7483e36",
        :version => 0.0,
        :ufs => "org.gxg.exchange",
        :title => "Exchange",
        :mime_types => [],
        :content => {
            :currency_uuid => "",
            :supported_currency_uuids => [],
            :organization => nil
        }
    }
    # Exchange Member Profile
    format_manifest[:exchange_member] = {
        :uuid => :"45db2bf9-5b53-4dae-8e14-82b92bdcd9b7",
        :version => 0.0,
        :ufs => "org.gxg.exchange.member",
        :title => "Exchange Member",
        :mime_types => [],
        :content => {
            :exchange_uuid => "",
            :username => "",
            :password_hash => "",
            :person => nil,
            :billing_address => nil,
            :shipping_address => nil,
            :payment_method_uuids => [],
            :default_payment_method_uuid => "",
            :monthly_billing_day => 1,
            :device_uuids => []
        }
    }
    # Payment Method
    format_manifest[:payment_method] = {
        :uuid => :"85b13ff1-948c-4117-a199-85ac91b13436",
        :version => 0.0,
        :ufs => "org.gxg.payment.method",
        :title => "Payment Method",
        :mime_types => [],
        :content => {
            :exchange_uuid => "",
            :member_uuid => "",
            :mode => "ach",
            :ach_route => "",
            :card_customer_name => "",
            :card_number => "",
            :card_expiration_month => "",
            :card_expiration_year => "",
            :card_ccv => ""
        }
    }
    # Item Option
    format_manifest[:item_option] = {
        :uuid => :"ae2ffc5d-32b9-43cb-a15a-e405bca5833c",
        :version => 0.0,
        :ufs => "org.gxg.exchange.item.option",
        :title => "Item Option",
        :mime_types => [],
        :content => {
            :type => "",
            :name => "",
            :value => ""
        }
    }
    # Item Property
    format_manifest[:item_property] = {
        :uuid => :"529a40c5-c3b0-467c-bc37-19909b21fdd8",
        :version => 0.0,
        :ufs => "org.gxg.exchange.item.property",
        :title => "Item Property",
        :mime_types => [],
        :content => {
            :label => "",
            :name => "",
            :value => ""
        }
    }
    # Currency
    format_manifest[:currency] = {
        :uuid => :"b702f8d9-c3e0-431e-9308-6b815e29030d",
        :version => 0.0,
        :ufs => "org.gxg.exchange.currency",
        :title => "Currency",
        :mime_types => [],
        :content => {
            :political => true,
            :iso => "",
            :iso_number => "",
            :symbol => "",
            :name => "",
            :unit_multiplier => 1,
            :expression_format => ""
        }
    }
    # Currency Amount
    format_manifest[:currency_amount] = {
        :uuid => :"be7e156f-de33-4a9e-8435-724241140948",
        :version => 0.0,
        :ufs => "org.gxg.exchange.amount",
        :title => "Currency Amount",
        :mime_types => [],
        :content => {
            :currency_uuid => "",
            :amount => 0
        }
    }
    # Price Discount
    format_manifest[:price_discount] = {
        :uuid => :"7d7eaaf3-287e-4e71-b9cf-127ce5771893",
        :version => 0.0,
        :ufs => "org.gxg.exchange.discount",
        :title => "Price Discount",
        :mime_types => [],
        :content => {
            :coupon_code => "",
            :coupon_name => "",
            :begins_at => nil,
            :ends_at => nil,
            :quantity_start => 0,
            :quantity_end => 0,
            :discount_percentage => 0.0
        }
    }
    # Quantity Pricing
    format_manifest[:quantity_pricing] = {
        :uuid => :"c68bb1ea-cea5-4e5c-8b9e-4fec175fd76e",
        :version => 0.0,
        :ufs => "org.gxg.exchange.pricing.quantity",
        :title => "Quantity Pricing",
        :mime_types => [],
        :content => {
            :void_if_coupon_code => "",
            :schedule_name => "",
            :begins_at => nil,
            :ends_at => nil,
            :quantity_start => 0,
            :quantity_end => 0,
            :unit_price_amounts => []
        }
    }
    # Product Profile
    format_manifest[:product] = {
        :uuid => :"dffad0a7-40df-49f1-89ec-fe2103a42caf",
        :version => 0.0,
        :ufs => "org.gxg.exchange.product",
        :title => "Product",
        :mime_types => [],
        :content => {
            :vendor_exchange_uuid => "",
            :vendor_member_uuid => "",
            :physical => true,
            :name => "",
            :sku => "",
            :description => "",
            :thumbnail_avatar => nil,
            :product_type => "",
            :categories => [],
            :tax_category => "",
            :brand => "",
            :model => "",
            :version => "",
            :weight => 0.0,
            :unit_of_weight => "ounces",
            :height => 0.0,
            :width => 0.0,
            :depth => 0.0,
            :bytes => 0,
            :unit_of_measure => "inches",
            :count_on_hand => 0,
            :back_orderable => false,
            :available_at => nil,
            :unavailable_at => nil,
            :agreement_uuid => "",
            :license_uuid => "",
            :options => [],
            :properties => [],
            :price_amounts => [],
            :discounts => [],
            :quantity_pricing => []
        }
    }
    # Service Profile
    format_manifest[:service] = {
        :uuid => :"89e280c6-6384-4bc8-8b35-b3f38cc41a0b",
        :version => 0.0,
        :ufs => "org.gxg.exchange.service",
        :title => "Service",
        :mime_types => [],
        :content => {
            :vendor_exchange_uuid => "",
            :vendor_member_uuid => "",
            :name => "",
            :sku => "",
            :description => "",
            :thumbnail_avatar => nil,
            :service_type => "",
            :categories => [],
            :tax_category => "",
            :rate_amounts => [],
            :rate_metric => "monthly",
            :agreement_uuid => "",
            :license_uuid => "",
            :options => [],
            :properties => [],
            :discounts => [],
            :quantity_pricing => []
        }
    }
    # Subscription Profile
    format_manifest[:subscription] = {
        :uuid => :"708b89cf-f621-4056-a734-db30062782fb",
        :version => 0.0,
        :ufs => "org.gxg.exchange.subscription",
        :title => "Subscription",
        :mime_types => [],
        :content => {
            :vendor_exchange_uuid => "",
            :vendor_member_uuid => "",
            :name => "",
            :sku => "",
            :description => "",
            :thumbnail_avatar => nil,
            :service_uuids => [],
            :product_uuids => [],
            :frequency => "monthly"
        }
    }
    # Package Profile
    format_manifest[:package] = {
        :uuid => :"de7c9eea-9fcc-4367-a77d-654de027c640",
        :version => 0.0,
        :ufs => "org.gxg.exchange.package",
        :title => "Package",
        :mime_types => [],
        :content => {
            :vendor_exchange_uuid => "",
            :vendor_member_uuid => "",
            :name => "",
            :sku => "",
            :description => "",
            :thumbnail_avatar => nil,
            :service_uuids => [],
            :product_uuids => [],
            :subscription_uuids => []
        }
    }
    # Order Item
    # ### Packages will be busted out into a series of order items.
    format_manifest[:order] = {
        :uuid => :"d626e116-74dc-4f32-8cc0-5fc5cb7ecf73",
        :version => 0.0,
        :ufs => "org.gxg.exchange.order.item",
        :title => "Order Item",
        :mime_types => [],
        :content => {
            :order_uuid => "",
            :quantity => 0,
            :service_uuid => "",
            :product_uuid => "",
            :subscription_uuid => "",
            :subtotal_amount_uuids => []
        }
    }
    # Order Profile
    format_manifest[:order] = {
        :uuid => :"dcaf0f89-2510-4ad8-8ce1-fc15dd50d22b",
        :version => 0.0,
        :ufs => "org.gxg.exchange.order",
        :title => "Order",
        :mime_types => [],
        :content => {
            :vendor_exchange_uuid => "",
            :vendor_member_uuid => "",
            :buyer_exchange_uuid => "",
            :buyer_member_uuid => "",
            :order_from_ip => "",
            :order_datetime => nil,
            :order_number => "",
            :order_item_uuids => [],
            :order_shipping_amounts => [],
            :order_status => "Composing",
            :order_shipping_tracking_id => "",
            :order_shipping_tracking_url => ""
        }
    }
    # Transaction Profile
    # ### Supports blended trades with multiple currencies
    format_manifest[:transaction] = {
        :uuid => :"00fcb628-8755-42f1-90ae-414287d2302c",
        :version => 0.0,
        :ufs => "org.gxg.exchange.transaction",
        :title => "Transaction",
        :mime_types => [],
        :content => {
            :vendor_exchange_uuid => "",
            :vendor_member_uuid => "",
            :buyer_exchange_uuid => "",
            :buyer_member_uuid => "",
            :occurred_at => nil,
            :order_uuid => "",
            :order_total_uuids => [],
            :payment_fee_uuids => [],
            :payment_id => "",
            :transaction_status => "Composing"
        }
    }
    # Chart of Accounts - Account Profile
    format_manifest[:account] = {
        :uuid => :"b69640db-5b14-453b-87b5-42279a8eba10",
        :version => 0.0,
        :ufs => "org.gxg.accounting.account",
        :title => "Account",
        :mime_types => [],
        :content => {
            :moniker => "",
            :exchange_uuid => "",
            :member_uuid => "",
            :reference_uuid => "",
            :currency_uuid => "",
            :account_code => 0,
            :account_name => "",
            :balance_updated_at => nil,
            :balance => 0
        }
    }
    # Account Entry
    format_manifest[:account_entry] = {
        :uuid => :"95d7ef37-cfbf-49d6-8f42-07c956d02518",
        :version => 0.0,
        :ufs => "org.gxg.accounting.account.entry",
        :title => "Account Entry",
        :mime_types => [],
        :content => {
            :account_uuid => "",
            :occurred_at => nil,
            :reference_uuid => "",
            :description => "",
            :is_debit => false,
            :amount => 0
        }
    }
    # Agreement
    format_manifest[:agreement] = {
        :uuid => :"d3374445-7789-4132-ab04-30df5060a5f7",
        :version => 0.0,
        :ufs => "org.gxg.legal.agreement",
        :title => "Agreement",
        :mime_types => [],
        :content => {
            :locale => "en_US.UTF8",
            :legal_text => "",
            :provides => [],
            :denies => [],
            :requires => [],
            :allows => [],
            :prohibits => []
        }
    }
    # License
    format_manifest[:license] = {
        :uuid => :"c269ecec-bef0-4dbb-8b59-bab7c9bd5c53",
        :version => 0.0,
        :ufs => "org.gxg.legal.license",
        :title => "License",
        :mime_types => [],
        :content => {
            :locale => "en_US.UTF8",
            :legal_text => "",
            :provides => [],
            :denies => [],
            :requires => [],
            :allows => [],
            :prohibits => []
        }
    }
    #
    component_manifest = {
        :header => {:uuid => :"406027b1-bd6a-4303-a62d-84d612d60f4a", :version => 0.0, :ufs => "org.gxg.gui.header", :title => "Header", :mime_types => []},
        :abbreviation => {:uuid => :"e294a968-ba3f-4d8a-bf56-0d42b5a2ba30", :version => 0.0, :ufs => "org.gxg.gui.abbreviation", :title => "Abbreviation", :mime_types => []},
        :address => {:uuid => :"784acacf-67c5-4cc7-aec0-c2716adad675", :version => 0.0, :ufs => "org.gxg.gui.address", :title => "Address", :mime_types => []},
        :area => {:uuid => :"f4ef08c9-470b-4705-a1a5-2e9878379179", :version => 0.0, :ufs => "org.gxg.gui.area", :title => "Area", :mime_types => []},
        :bold => {:uuid => :"b8e13e2a-28ee-4a5e-8047-56b08b9b5ea2", :version => 0.0, :ufs => "org.gxg.gui.bold", :title => "Bold", :mime_types => []},
        :bdi => {:uuid => :"f375664b-3280-4a69-a0d4-ea6b06b089d7", :version => 0.0, :ufs => "org.gxg.gui.bdi", :title => "BDI", :mime_types => []},
        :bdo => {:uuid => :"c6997d73-6c93-4073-a09b-bc0a89845b70", :version => 0.0, :ufs => "org.gxg.gui.bdo", :title => "BDO", :mime_types => []},
        :blockquote => {:uuid => :"90474690-9906-424e-93dc-52e491d8c3b7", :version => 0.0, :ufs => "org.gxg.gui.blockquote", :title => "Block Quote", :mime_types => []},
        :break => {:uuid => :"dcea7d88-c22d-40a2-8a03-c2bd364a60f1", :version => 0.0, :ufs => "org.gxg.gui.break", :title => "Break", :mime_types => []},
        :caption => {:uuid => :"7ec7b25a-bd25-4239-93c9-752084d8f50b", :version => 0.0, :ufs => "org.gxg.gui.caption", :title => "Caption", :mime_types => []},
        :cite => {:uuid => :"7f0ec70e-b6b8-450b-9840-8f59dbce30b6", :version => 0.0, :ufs => "org.gxg.gui.cite", :title => "Citation", :mime_types => []},
        :code => {:uuid => :"88d602f6-cd33-470a-a732-f5f62319d9fb", :version => 0.0, :ufs => "org.gxg.gui.code", :title => "Code", :mime_types => []},
        :column => {:uuid => :"5a179fd7-925d-42cb-902f-e72ebbad496f", :version => 0.0, :ufs => "org.gxg.gui.column", :title => "Column", :mime_types => []},
        :column_group => {:uuid => :"6fea8945-ba17-4bae-8475-abe111546fcf", :version => 0.0, :ufs => "org.gxg.gui.column.group", :title => "Column Group", :mime_types => []},
        :data => {:uuid => :"02800d23-1b94-4d1d-a010-244bc37d340c", :version => 0.0, :ufs => "org.gxg.gui.data", :title => "Data", :mime_types => []},
        :datalist => {:uuid => :"f99435cd-1006-4148-8f7d-eb190365b014", :version => 0.0, :ufs => "org.gxg.gui.data.list", :title => "Data List", :mime_types => []},
        :description => {:uuid => :"e5167c88-b8c9-45e1-85d9-770db8e21026", :version => 0.0, :ufs => "org.gxg.gui.description", :title => "Description", :mime_types => []},
        :deleted => {:uuid => :"d500c245-2397-468e-bbad-c7a28da491fd", :version => 0.0, :ufs => "org.gxg.gui.deleted", :title => "Deleted", :mime_types => []},
        :details => {:uuid => :"e084d219-f07c-4094-80fd-0a0425408c49", :version => 0.0, :ufs => "org.gxg.gui.details", :title => "Details", :mime_types => []},
        :dfn => {:uuid => :"f60b87fd-ca83-4bc2-a300-122d3e35ab29", :version => 0.0, :ufs => "org.gxg.gui.dfn", :title => "DFN", :mime_types => []},
        :dialog => {:uuid => :"c414147f-1849-4fa0-8de9-77d26a6d8603", :version => 0.0, :ufs => "org.gxg.gui.dialog", :title => "Dialog", :mime_types => []},
        :division => {:uuid => :"3c493d9b-216d-452e-a7a2-7ed7ab608b99", :version => 0.0, :ufs => "org.gxg.gui.division", :title => "Division", :mime_types => []},
        :description_list => {:uuid => :"63744c8b-6cdc-40dd-89e4-04c40c6bc1a9", :version => 0.0, :ufs => "org.gxg.gui.description.list", :title => "Description List", :mime_types => []},
        :description_term => {:uuid => :"20a7b2e3-c382-4fc8-82a8-0a993977153f", :version => 0.0, :ufs => "org.gxg.gui.description.item", :title => "Description Item", :mime_types => []},
        :emphasis => {:uuid => :"09337380-8ff1-476a-bd11-7635dcca6247", :version => 0.0, :ufs => "org.gxg.gui.emphasis", :title => "Emphasis", :mime_types => []},
        :figure => {:uuid => :"520e43ba-5435-4e85-97db-c13c1fadb00e", :version => 0.0, :ufs => "org.gxg.gui.figure", :title => "Figure", :mime_types => []},
        :figure_caption => {:uuid => :"69aa54e2-7109-4e2d-984b-4e0a911cf92c", :version => 0.0, :ufs => "org.gxg.gui.figure.caption", :title => "Figure Caption", :mime_types => []},
        :theme_divider => {:uuid => :"4e22cb4f-3c10-49ef-b87f-27a96734c428", :version => 0.0, :ufs => "org.gxg.gui.theme.divider", :title => "Theme Divider", :mime_types => []},
        :italic => {:uuid => :"d088bae1-1c0d-48af-8984-cf386280ae37", :version => 0.0, :ufs => "org.gxg.gui.italic", :title => "Italic", :mime_types => []},
        :inline_frame => {:uuid => :"dde9c69a-1839-4602-8b09-2d05e99cb2bd", :version => 0.0, :ufs => "org.gxg.gui.frame.inline", :title => "Inline Frame", :mime_types => []},
        :Insertion => {:uuid => :"b717af7c-36e0-452d-b663-35baa0f2a43a", :version => 0.0, :ufs => "org.gxg.gui.insertion", :title => "Insertion", :mime_types => []},
        :keyboard_key => {:uuid => :"ca876f84-b08a-43a2-825a-07cd4d37c054", :version => 0.0, :ufs => "org.gxg.gui.keyboard.key", :title => "Keyboard Key", :mime_types => []},
        :map => {:uuid => :"d9f3c30a-1a9b-4c7b-990d-2c3a2b841ce5", :version => 0.0, :ufs => "org.gxg.gui.map", :title => "Map", :mime_types => []},
        :mark => {:uuid => :"8ea5f453-3ce0-40a6-8e4d-e362a7dc0720", :version => 0.0, :ufs => "org.gxg.gui.mark", :title => "Mark", :mime_types => []},
        :meter => {:uuid => :"f45fe29f-ee3f-4f5c-b6d7-471ac1c30adc", :version => 0.0, :ufs => "org.gxg.gui.meter", :title => "Meter", :mime_types => []},
        :noscript => {:uuid => :"a7ebc909-be8b-4f5e-98da-ea4945aff64a", :version => 0.0, :ufs => "org.gxg.gui.noscript", :title => "No Script", :mime_types => []},
        :object => {:uuid => :"248e91ef-23c7-4549-a7fa-97b4031203a6", :version => 0.0, :ufs => "org.gxg.gui.object", :title => "Object", :mime_types => []},
        :option_group => {:uuid => :"18c1a8cc-7e96-46e7-adbf-a296bddfa392", :version => 0.0, :ufs => "org.gxg.gui.option.group", :title => "Option Group", :mime_types => []},
        :parameter => {:uuid => :"0dd45457-c319-4913-95fd-93865e3e881a", :version => 0.0, :ufs => "org.gxg.gui.parameter", :title => "Parameter", :mime_types => []},
        :picture => {:uuid => :"085b2928-e238-4c40-a89f-adfb37a633e2", :version => 0.0, :ufs => "org.gxg.gui.picture", :title => "Picture", :mime_types => []},
        :preformatted => {:uuid => :"0ce27866-4114-40ff-b58d-85ed8c893874", :version => 0.0, :ufs => "org.gxg.gui.preformatted", :title => "Preformatted", :mime_types => []},
        :progress => {:uuid => :"a8f6f076-25d2-4363-b7cb-164ec003e935", :version => 0.0, :ufs => "org.gxg.gui.progress", :title => "Progress", :mime_types => []},
        :quotation => {:uuid => :"998fcc2e-bcea-4848-9410-bf3d96e93c2d", :version => 0.0, :ufs => "org.gxg.gui.quotation", :title => "Quotation", :mime_types => []},
        :strike_through => {:uuid => :"1710d020-10bc-43df-abbd-2b2843d11a84", :version => 0.0, :ufs => "org.gxg.gui.strike.through", :title => "Strike Through", :mime_types => []},
        :sample => {:uuid => :"80de87b3-eb22-42c3-add9-74f31a9266ec", :version => 0.0, :ufs => "org.gxg.gui.sample", :title => "Sample", :mime_types => []},
        :small => {:uuid => :"41678126-77c0-4fb9-8cc1-4cd7bd757864", :version => 0.0, :ufs => "org.gxg.gui.small", :title => "Small", :mime_types => []},
        :source => {:uuid => :"8e32198e-02ad-4c21-b863-32725209f223", :version => 0.0, :ufs => "org.gxg.gui.source", :title => "Source", :mime_types => []},
        :strong => {:uuid => :"f87edac4-4074-4e85-a5fb-1a293ce462a4", :version => 0.0, :ufs => "org.gxg.gui.strong", :title => "Strong", :mime_types => []},
        :style => {:uuid => :"56d16905-1321-4fee-a3f6-c357afbeca1a", :version => 0.0, :ufs => "org.gxg.gui.style", :title => "Style", :mime_types => []},
        :sub_script => {:uuid => :"fbd934e8-bdb7-48dd-84ac-0755a06ff828", :version => 0.0, :ufs => "org.gxg.gui.sub.script", :title => "Sub Script", :mime_types => []},
        :summary => {:uuid => :"44c66f7f-7a85-472b-bfd9-e701ac3dd480", :version => 0.0, :ufs => "org.gxg.gui.summary", :title => "Summary", :mime_types => []},
        :super_script => {:uuid => :"cf859a16-4d12-4efa-8594-c3e09a07f8b1", :version => 0.0, :ufs => "org.gxg.gui.super.script", :title => "Super Script", :mime_types => []},
        :svg => {:uuid => :"a675cedd-d3f5-445d-9515-a77f6090f0b7", :version => 0.0, :ufs => "org.gxg.gui.svg", :title => "SVG", :mime_types => []},
        :template => {:uuid => :"96ba3db9-5536-4f65-8deb-0e7c085ff864", :version => 0.0, :ufs => "org.gxg.gui.template", :title => "Template", :mime_types => []},
        :time => {:uuid => :"ebe4e6df-b022-4cf2-8fee-a01c4ef367c0", :version => 0.0, :ufs => "org.gxg.gui.time", :title => "Time", :mime_types => []},
        :track => {:uuid => :"198ee7dc-76db-4ede-9bb8-76d62bc1f30a", :version => 0.0, :ufs => "org.gxg.gui.track", :title => "Track", :mime_types => []},
        :misspelled => {:uuid => :"08080504-4c16-4276-b9e6-1e6179525db4", :version => 0.0, :ufs => "org.gxg.gui.misspelled", :title => "Misspelled", :mime_types => []},
        :variable => {:uuid => :"4d51159b-e5e4-427c-970a-7454a3135ff0", :version => 0.0, :ufs => "org.gxg.gui.variable", :title => "Variable", :mime_types => []},
        :word_break => {:uuid => :"a59a31e0-23af-4a24-8ddf-37e21db33a3d", :version => 0.0, :ufs => "org.gxg.gui.word.break", :title => "Word Break", :mime_types => []},        
        :navigator => {:uuid => :"52804511-921e-408d-8a47-5ddebdffb6ba", :version => 0.0, :ufs => "org.gxg.gui.navigator", :title => "Navigator", :mime_types => []},
        :section => {:uuid => :"433d8344-41ae-43c0-b9b3-8e3734c51e60", :version => 0.0, :ufs => "org.gxg.gui.section", :title => "Section", :mime_types => []},
        :main => {:uuid => :"d88885bf-eca9-482a-bdd0-e2feab18c2c4", :version => 0.0, :ufs => "org.gxg.gui.main", :title => "Main", :mime_types => []},
        :article => {:uuid => :"18ee5cc8-bd0f-4cb4-98ea-d2512f818502", :version => 0.0, :ufs => "org.gxg.gui.article", :title => "Article", :mime_types => []},
        :aside => {:uuid => :"4a3fa48a-a180-4484-87f7-daada6006996", :version => 0.0, :ufs => "org.gxg.gui.aside", :title => "Aside", :mime_types => []},
        :footer => {:uuid => :"d0f32b6a-b899-4ddc-895c-55012a7111c9", :version => 0.0, :ufs => "org.gxg.gui.footer", :title => "Footer", :mime_types => []},
        :form => {:uuid => :"1f70d20f-2bd3-4181-bf9b-ee175b0102e6", :version => 0.0, :ufs => "org.gxg.gui.form", :title => "Form", :mime_types => []},
        :clickable => {:uuid => :"3d4849b0-f7df-4c2a-8570-32bab0111f48", :version => 0.0, :ufs => "org.gxg.gui.clickable", :title => "Clickable", :mime_types => []},
        :fieldset => {:uuid => :"d35e58e4-0c77-42b8-9e28-bb417d50a3d7", :version => 0.0, :ufs => "org.gxg.gui.fieldset", :title => "Fieldset", :mime_types => []},
        :text_input => {:uuid => :"b950191d-fb36-4a77-9e02-77409d9fbdb7", :version => 0.0, :ufs => "org.gxg.gui.input.text", :title => "Text Input", :mime_types => []},
        :password_input => {:uuid => :"3e12c288-c3e2-4fae-b558-68a57e48cc3b", :version => 0.0, :ufs => "org.gxg.gui.input.password", :title => "Password Input", :mime_types => []},
        :reset_input => {:uuid => :"c0df68b8-ade4-4aa7-8217-084880e38b61", :version => 0.0, :ufs => "org.gxg.gui.input.reset", :title => "Reset Input", :mime_types => []},
        :radio_button => {:uuid => :"9a281d07-fa75-439b-bc7b-1beb8d1ea4b5", :version => 0.0, :ufs => "org.gxg.gui.button.radio", :title => "Radio Button", :mime_types => []},
        :color_picker => {:uuid => :"73bb5304-c737-4654-a782-016f3d93aadf", :version => 0.0, :ufs => "org.gxg.gui.picker.color", :title => "Color Picker", :mime_types => []},
        :date_picker => {:uuid => :"37d3fa2b-af8f-4198-9bf8-86c6342f6b29", :version => 0.0, :ufs => "org.gxg.gui.picker.date", :title => "Date Picker", :mime_types => []},
        :datetime_local => {:uuid => :"19b269ac-6bc2-4c72-b32d-36b9b0180fb1", :version => 0.0, :ufs => "org.gxg.gui.input.datetime.local", :title => "DateTime Local", :mime_types => []},
        :email_input => {:uuid => :"80f96881-f408-4fe6-b15a-f38b9dbdaf29", :version => 0.0, :ufs => "org.gxg.gui.input.email", :title => "Email Input", :mime_types => []},
        :month_picker => {:uuid => :"6935d225-fab1-413b-8536-3eea1adae64d", :version => 0.0, :ufs => "org.gxg.gui.picker.month", :title => "Month Picker", :mime_types => []},
        :number_input => {:uuid => :"cb740651-8abe-40dc-81d6-a2d3e19181f2", :version => 0.0, :ufs => "org.gxg.gui.picker.number", :title => "Number Picker", :mime_types => []},
        :range_input => {:uuid => :"cda9416d-38e5-41e5-becb-f61d00fc6576", :version => 0.0, :ufs => "org.gxg.gui.input.range", :title => "Range Input", :mime_types => []},
        :search_input => {:uuid => :"91d7e811-292b-4d87-9f03-f462035bcab9", :version => 0.0, :ufs => "org.gxg.gui.input.search", :title => "Search Input", :mime_types => []},
        :phone_input => {:uuid => :"9221ded1-bee4-4d7b-9733-b355ac964fce", :version => 0.0, :ufs => "org.gxg.gui.input.phone", :title => "Phone Input", :mime_types => []},
        :time_picker => {:uuid => :"cb54991e-f885-4df0-a40f-b0c73ee5f8be", :version => 0.0, :ufs => "org.gxg.gui.picker.time", :title => "Time Picker", :mime_types => []},
        :url_input => {:uuid => :"89e806b9-b83d-47a8-9c9f-98c7c8ed6a2e", :version => 0.0, :ufs => "org.gxg.gui.input.url", :title => "URL Input", :mime_types => []},
        :week_picker => {:uuid => :"cf68bbf2-85b2-4b48-9363-6d62958e6268", :version => 0.0, :ufs => "org.gxg.gui.picker.week", :title => "Week Picker", :mime_types => []},
        :label => {:uuid => :"38772019-30b8-493b-a18a-4dbe09014d09", :version => 0.0, :ufs => "org.gxg.gui.label", :title => "Label", :mime_types => []},
        :text_area => {:uuid => :"508be60f-0899-4850-ab60-d57ee3998f4f", :version => 0.0, :ufs => "org.gxg.gui.text.area", :title => "Text Area", :mime_types => []},
        :output => {:uuid => :"53a88d40-629c-4471-bf52-94ac92e97aa0", :version => 0.0, :ufs => "org.gxg.gui.output", :title => "Output", :mime_types => []},
        :paragraph => {:uuid => :"eef0207d-deea-4241-915e-bc219f33751c", :version => 0.0, :ufs => "org.gxg.gui.paragraph", :title => "Paragraph", :mime_types => []},
        :header1 => {:uuid => :"cfb841c6-fd68-48a9-8af6-c0ef6e5a2a95", :version => 0.0, :ufs => "org.gxg.gui.header.one", :title => "Header One", :mime_types => []},
        :header2 => {:uuid => :"67a6801e-d7cb-4a33-b970-63d40003e6f0", :version => 0.0, :ufs => "org.gxg.gui.header.two", :title => "Header Two", :mime_types => []},
        :header3 => {:uuid => :"11cbd1fc-b801-428f-a1c1-116200103f17", :version => 0.0, :ufs => "org.gxg.gui.header.three", :title => "Header Three", :mime_types => []},
        :header4 => {:uuid => :"8f13aba3-562a-45fd-b415-37acd6c6c7df", :version => 0.0, :ufs => "org.gxg.gui.header.four", :title => "Header Four", :mime_types => []},
        :header5 => {:uuid => :"c41cd09d-acd0-46e8-8c0f-34efdeb63b75", :version => 0.0, :ufs => "org.gxg.gui.header.five", :title => "Header Five", :mime_types => []},
        :header6 => {:uuid => :"eee3385a-15b2-4b51-a41c-88fd66369a7e", :version => 0.0, :ufs => "org.gxg.gui.header.six", :title => "Header Six", :mime_types => []},
        :button_input => {:uuid => :"9e6e578d-8c13-43da-96ea-52b10f505a57", :version => 0.0, :ufs => "org.gxg.gui.input.button", :title => "Button Input", :mime_types => []},
        :submit_button => {:uuid => :"fabb80b8-6c68-4bc6-830b-8a8128965208", :version => 0.0, :ufs => "org.gxg.gui.input.button.submit", :title => "Submit Button", :mime_types => []},
        :click_block => {:uuid => :"e5d2e610-aa9b-4630-944d-cd3e470e4bae", :version => 0.0, :ufs => "org.gxg.gui.block.click", :title => "Click Block", :mime_types => []},
        :checkbox => {:uuid => :"925a8d6f-5284-48c2-a235-134cbbcb9c6b", :version => 0.0, :ufs => "org.gxg.gui.button.checkbox", :title => "Check Box", :mime_types => []},
        :selector => {:uuid => :"80b4cffc-9cca-461a-9a6c-b0843e57ccd3", :version => 0.0, :ufs => "org.gxg.gui.selector", :title => "Selector", :mime_types => []},
        :block => {:uuid => :"3d6bf1ce-b5df-4ec4-a26e-9d9e25ced8c9", :version => 0.0, :ufs => "org.gxg.gui.block", :title => "Block", :mime_types => []},
        :text => {:uuid => :"5f562410-0149-4c27-953f-0a531a8c695e", :version => 0.0, :ufs => "org.gxg.gui.text", :title => "Text", :mime_types => []},
        :list => {:uuid => :"4afe74f2-e9e7-446b-896a-fdb940c62e8b", :version => 0.0, :ufs => "org.gxg.gui.list", :title => "List", :mime_types => []},
        :ordered_list => {:uuid => :"fbdaba5d-aac0-4f64-8208-cd959f32f0fb", :version => 0.0, :ufs => "org.gxg.gui.list.ordered", :title => "Ordered List", :mime_types => []},
        :list_item => {:uuid => :"58213b45-5d5d-4fad-be5d-dc1dd37c5e2a", :version => 0.0, :ufs => "org.gxg.gui.list.item", :title => "List Item", :mime_types => []},
        :anchor => {:uuid => :"e333fb5f-14ea-41f7-b2a4-fef1b528faec", :version => 0.0, :ufs => "org.gxg.gui.link.anchor", :title => "Link Anchor", :mime_types => []},
        :external_link => {:uuid => :"223f1464-af75-4ffc-b137-0f13a93480b2", :ufs => "org.gxg.gui.link.external", :title => "External Link", :mime_types => []},
        :button => {:uuid => :"1890d372-b8fc-4b78-ba1e-5bd0f33e5c40", :version => 0.0, :ufs => "org.gxg.gui.button", :title => "Button", :mime_types => []},
        :image => {:uuid => :"5a5ae8dc-d09d-47f8-a059-cd147c6d1def", :version => 0.0, :ufs => "org.gxg.gui.image", :title => "Image", :mime_types => []},
        :video => {:uuid => :"72b3b65e-6a41-4c1a-8d9f-ea63aac34fa1", :version => 0.0, :ufs => "org.gxg.gui.video", :title => "Video", :mime_types => []},
        :audio => {:uuid => :"507dc906-67ff-44e0-a18e-650393940e42", :version => 0.0, :ufs => "org.gxg.gui.audio", :title => "Audio", :mime_types => []},
        :canvas => {:uuid => :"fc48597e-a584-40e5-bbb0-738e723b5d8c", :version => 0.0, :ufs => "org.gxg.gui.canvas", :title => "Canvas", :mime_types => []},
        :hidden_input => {:uuid => :"a5e7a64e-eef7-4d7c-bfde-cc3c38651fe1", :version => 0.0, :ufs => "org.gxg.gui.input.hidden", :title => "Hidden Input", :mime_types => []},
        :file_input => {:uuid => :"28e0f4aa-f187-45f4-9ddb-22ad4f6d192c", :version => 0.0, :ufs => "org.gxg.gui.input.file", :title => "File Input", :mime_types => []},
        :script => {:uuid => :"160a19ca-1639-445e-9ad7-ff2a61b38f9a", :version => 0.0, :ufs => "org.gxg.gui.script", :title => "Script", :mime_types => []},
        :application_viewport => {:uuid => :"c0f8e94e-d1ad-41d7-ab42-9d1144a922c0", :version => 0.0, :ufs => "org.gxg.gui.application.viewport", :title => "Application Viewport", :mime_types => []},
        :search_form => {:uuid => :"b9230b9c-fe27-484b-a9ce-6f7c1b540ae9", :version => 0.0, :ufs => "org.gxg.gui.form.search", :title => "Search Form", :mime_types => []},
        :popupmenu => {:uuid => :"7245f529-b121-438a-86f9-5f55e0077cc3", :version => 0.0, :ufs => "org.gxg.gui.menu.popup", :title => "Popup Menu", :mime_types => []},
        :table => {:uuid => :"7c02dd79-a22d-4e66-b33a-cdcce3e97e84", :version => 0.0, :ufs => "org.gxg.gui.table", :title => "Table", :mime_types => []},
        :table_header => {:uuid => :"2f2bd2d4-7727-4068-adf6-0b3fafc7f083", :version => 0.0, :ufs => "org.gxg.gui.table.header", :title => "Table Header", :mime_types => []},
        :table_row => {:uuid => :"4c0659d6-d2d1-41b6-bb9d-a8374dd5ace3", :version => 0.0, :ufs => "org.gxg.gui.table.row", :title => "Table Row", :mime_types => []},
        :table_cell => {:uuid => :"7a43933e-67e1-44d7-9cc6-f59eaf1cf97d", :version => 0.0, :ufs => "org.gxg.gui.table.cell", :title => "Table Data Cell", :mime_types => []},
        :block_table => {:uuid => :"e8c615b2-ced5-4440-b2de-1fc6ea718782", :version => 0.0, :ufs => "org.gxg.gui.block.table", :title => "Block Table", :mime_types => []},
        :block_table_header => {:uuid => :"2b554d56-445d-45cc-a9f6-90150f3009ca", :version => 0.0, :ufs => "org.gxg.gui.block.table.header", :title => "Block Table Header", :mime_types => []},
        :block_table_row => {:uuid => :"b614c7f0-7364-4afd-a61c-b00facd7f6fb", :version => 0.0, :ufs => "org.gxg.gui.block.table.row", :title => "Block Table Row", :mime_types => []},
        :block_table_cell => {:uuid => :"96110e43-28a4-49ff-87e7-71038c0fc5d3", :version => 0.0, :ufs => "org.gxg.gui.block.table.cell", :title => "Block Table Data Cell", :mime_types => []},
        :span => {:uuid => :"7b33daaa-b0a9-4859-bb31-415e873faeae", :version => 0.0, :ufs => "org.gxg.gui.span", :title => "Span", :mime_types => []},
        :select => {:uuid => :"2925f216-12e5-4c59-a094-8c3ab5f873b7", :version => 0.0, :ufs => "org.gxg.gui.select", :title => "Select", :mime_types => []},
        :option => {:uuid => :"5eddff05-27d3-4bcf-b7d6-799550ed7298", :version => 0.0, :ufs => "org.gxg.gui.option", :title => "Option", :mime_types => []},
        :field_set => {:uuid => :"c1bee841-f64a-4ba5-9b0c-681975705ce9", :version => 0.0, :ufs => "org.gxg.gui.field.set", :title => "Field Set", :mime_types => []},
        :legend => {:uuid => :"1f32cf7e-f631-4026-b92c-a5d2ebaedea2", :version => 0.0, :ufs => "org.gxg.gui.legend", :title => "Legend", :mime_types => []},
        :window => {:uuid => :"1dc5966f-448a-40ba-8583-7002f9ffbbbe", :version => 0.0, :ufs => "org.gxg.gui.window", :title => "Window", :mime_types => []},
        :dialog_box => {:uuid => :"ceaf333c-5bda-45d5-a4f0-77eb9b5ca3e3", :version => 0.0, :ufs => "org.gxg.gui.window.dialog", :title => "Dialog Box Window", :mime_types => []},
        :panel => {:uuid => :"df2cf49b-dd44-4174-aad7-b2bd40bf842e", :version => 0.0, :ufs => "org.gxg.gui.panel", :title => "Panel", :mime_types => []},
        :tree => {:uuid => :"961520f2-bb61-4190-bd01-da560701c552", :version => 0.0, :ufs => "org.gxg.gui.tree", :title => "Tree Selector", :mime_types => []},
        :tree_node => {:uuid => :"635737ad-0fc8-45e6-a1d8-7d55685aa98b", :version => 0.0, :ufs => "org.gxg.gui.tree.node", :title => "Tree Selector Node", :mime_types => []},
        :menu_bar => {:uuid => :"c071ebad-7d54-4da6-8b71-6ff9bc7de38f", :version => 0.0, :ufs => "org.gxg.gui.menu.bar", :title => "Menu Bar", :mime_types => []},
        :menu_item => {:uuid => :"898229dd-8c3d-4709-99df-584eb38c2a6b", :version => 0.0, :ufs => "org.gxg.gui.menu.item", :title => "Menu Item", :mime_types => []},
        :grid_container => {:uuid => :"0694a61d-a282-481b-8242-70caa652a781", :version => 0.0, :ufs => "org.gxg.gui.grid.container", :title => "Grid Container", :mime_types => []},
        :grid_x => {:uuid => :"de6bcb5b-e3df-4c4e-9d37-b47ba56f1457", :version => 0.0, :ufs => "org.gxg.gui.grid.x", :title => "Grid X", :mime_types => []},
        :grid_y => {:uuid => :"9b98f09e-e354-48d1-a481-bdf2684a2cae", :version => 0.0, :ufs => "org.gxg.gui.grid.y", :title => "Grid Y", :mime_types => []},
        :accordion => {:uuid => :"95359db4-485b-462a-ac57-635e9f1f131c", :version => 0.0, :ufs => "org.gxg.gui.accordion", :title => "Accordion", :mime_types => []},
        :accordion_item => {:uuid => :"4fa5769c-bb16-4b8b-b45c-010f0b4e2b15", :version => 0.0, :ufs => "org.gxg.gui.accordion.item", :title => "Accordion Item", :mime_types => []},
        :accordion_menu => {:uuid => :"9eb38d28-49b9-4f97-9cf5-7884cfda0bc7", :version => 0.0, :ufs => "org.gxg.gui.accordion.menu", :title => "Accordion Menu", :mime_types => []},
        :accordion_submenu => {:uuid => :"28c6f401-6679-4312-8bab-433aaf8af446", :version => 0.0, :ufs => "org.gxg.gui.accordion.submenu", :title => "Accordion Submenu", :mime_types => []},
        :accordion_menu_item => {:uuid => :"38b7da3a-56fb-42f0-8f3b-46f7f1619a61", :version => 0.0, :ufs => "org.gxg.gui.accordion.menu.item", :title => "Accordion Menu Item", :mime_types => []},
        :anchor_button => {:uuid => :"94792c72-b925-4858-8039-f8d05bcce6f4", :version => 0.0, :ufs => "org.gxg.gui.anchor.button", :title => "Anchor Button", :mime_types => []},
        :badge => {:uuid => :"015f5721-f14a-46a1-9c70-55b22ff70794", :version => 0.0, :ufs => "org.gxg.gui.badge", :title => "Badge", :mime_types => []},
        :breadcrumb => {:uuid => :"69e3c8e4-4490-49b8-99ae-7440a6186ae8", :version => 0.0, :ufs => "org.gxg.gui.breadcrumb", :title => "Breadcrumb", :mime_types => []},
        :breadcrumb_item => {:uuid => :"b41cf65d-5686-4381-84ea-dbfb5ef23392", :version => 0.0, :ufs => "org.gxg.gui.breadcrumb.item", :title => "Breadcrumb Item", :mime_types => []},
        :button_group => {:uuid => :"fc47cf1a-e754-49e7-a433-9cc644f2fb57", :version => 0.0, :ufs => "org.gxg.gui.button.group", :title => "Button Group", :mime_types => []},
        :callout => {:uuid => :"54e8d34a-bfde-4c51-9b01-258f79fc4644", :version => 0.0, :ufs => "org.gxg.gui.callout", :title => "Callout", :mime_types => []},
        :colored_label => {:uuid => :"e6f9eb2f-44e9-4cce-b801-f3f95bb06d85", :version => 0.0, :ufs => "org.gxg.gui.label.colored", :title => "Colored Label", :mime_types => []},
        :drilldown_menu => {:uuid => :"7ed43e15-5773-4202-b3eb-5a48aa5de28b", :version => 0.0, :ufs => "org.gxg.gui.drilldown.menu", :title => "Drilldown Menu", :mime_types => []},
        :drilldown_submenu => {:uuid => :"d7f6d04b-f09f-4a1b-8728-72bbc607b1fe", :version => 0.0, :ufs => "org.gxg.gui.drilldown.submenu", :title => "Drilldown Submenu", :mime_types => []},
        :drilldown_menu_item => {:uuid => :"ce8e036e-dfdf-4b91-854d-3bacab952af9", :version => 0.0, :ufs => "org.gxg.gui.drilldown.menu.item", :title => "Drilldown Menu Item", :mime_types => []},
        :dropdown_menu => {:uuid => :"f4011e39-d572-4188-bebb-7a0ff6e68742", :version => 0.0, :ufs => "org.gxg.gui.dropdown.menu", :title => "Dropdown Menu", :mime_types => []},
        :dropdown_submenu => {:uuid => :"25c78952-a37e-4635-a22e-3da45e2993eb", :version => 0.0, :ufs => "org.gxg.gui.dropdown.submenu", :title => "Dropdown Submenu", :mime_types => []},
        :dropdown_menu_item => {:uuid => :"460b4eab-9020-4d42-8075-e547e914c067", :version => 0.0, :ufs => "org.gxg.gui.dropdown.menu.item", :title => "Dropdown Menu Item", :mime_types => []},
        :equalizer => {:uuid => :"c29bf74e-6104-4572-beab-4d689a138260", :version => 0.0, :ufs => "org.gxg.gui.equalizer", :title => "Equalizer", :mime_types => []},
        :flexgrid_row => {:uuid => :"47c5e626-70aa-42fd-8f79-406d085cbd46", :version => 0.0, :ufs => "org.gxg.gui.flexgrid.row", :title => "Flexgrid Row", :mime_types => []},
        :flexgrid_column => {:uuid => :"cf23977e-4aca-48df-bc20-614d395afa6f", :version => 0.0, :ufs => "org.gxg.gui.flexgrid.column", :title => "Flexgrid Column", :mime_types => []},
        :embed => {:uuid => :"3a086cfe-afdd-4c4c-8370-cf3d0b24ff80", :version => 0.0, :ufs => "org.gxg.gui.embed", :title => "Embed", :mime_types => []},
        :media_object => {:uuid => :"f6933266-3ce4-46b4-b23e-d7d63a578ab7", :version => 0.0, :ufs => "org.gxg.gui.media.object", :title => "Media Object", :mime_types => []},
        :media_object_section => {:uuid => :"2d50d84c-dfd2-4acd-92e9-09a930055136", :version => 0.0, :ufs => "org.gxg.gui.media.object.section", :title => "Media Object Section", :mime_types => []},
        :menu => {:uuid => :"f5fd2f0b-55ab-495c-9e27-6d1494ae646f", :version => 0.0, :ufs => "org.gxg.gui.menu", :title => "Menu", :mime_types => []},
        :offcanvas_wrapper => {:uuid => :"d8e13a5f-820e-4969-9bba-5dac28904fb9", :version => 0.0, :ufs => "org.gxg.gui.offcanvas.wrapper", :title => "Offcanvas Wrapper", :mime_types => []},
        :offcanvas_wrapper_inner => {:uuid => :"4a8f8592-7b81-4b9c-a756-3e008be678e9", :version => 0.0, :ufs => "org.gxg.gui.offcanvas.wrapper.inner", :title => "Offcanvas Wrapper Inner", :mime_types => []},
        :offcanvas_left => {:uuid => :"0f6ef1aa-0f1a-43ab-9ec9-272ab44bef40", :version => 0.0, :ufs => "org.gxg.gui.offcanvas.left", :title => "Offcanvas Left", :mime_types => []},
        :offcanvas_right => {:uuid => :"f26ac4a6-2733-435f-bf3a-9dbf91625d49", :version => 0.0, :ufs => "org.gxg.gui.offcanvas.right", :title => "Offcanvas Right", :mime_types => []},
        :offcanvas_content => {:uuid => :"b38a4e3a-d690-4555-a338-8c89143a82f8", :version => 0.0, :ufs => "org.gxg.gui.offcanvas.content", :title => "Offcanvas Content", :mime_types => []},
        :orbit => {:uuid => :"a077eda6-5797-4fd5-8018-6742cf1ecaac", :version => 0.0, :ufs => "org.gxg.gui.orbit", :title => "Orbit", :mime_types => []},
        :orbit_container => {:uuid => :"c3678beb-a7fd-496b-9d1b-152ffffbb888", :version => 0.0, :ufs => "org.gxg.gui.orbit.container", :title => "Orbit Container", :mime_types => []},
        :orbit_previous => {:uuid => :"c27b623b-4046-4971-8d90-a037b68258f1", :version => 0.0, :ufs => "org.gxg.gui.orbit.previous", :title => "Orbit Previous", :mime_types => []},
        :orbit_next => {:uuid => :"d3cd44cb-5384-42e5-ae53-776b0e7470df", :version => 0.0, :ufs => "org.gxg.gui.orbit.next", :title => "Orbit Next", :mime_types => []},
        :orbit_slide => {:uuid => :"a1c99b0a-0c98-40b9-a891-234024c26afe", :version => 0.0, :ufs => "org.gxg.gui.orbit.slide", :title => "Orbit Slide", :mime_types => []},
        :orbit_navigator => {:uuid => :"705d95f5-5654-444d-8f39-16a9db0564db", :version => 0.0, :ufs => "org.gxg.gui.orbit.navigator", :title => "Orbit Navigator", :mime_types => []},
        :orbit_bullet => {:uuid => :"fcc33147-6222-4ed6-a75e-87966044bfcf", :version => 0.0, :ufs => "org.gxg.gui.orbit.bullet", :title => "Orbit Bullet", :mime_types => []},
        :pagination => {:uuid => :"2ec92a1f-7475-435d-b02d-6392df56aed3", :version => 0.0, :ufs => "org.gxg.gui.pagination", :title => "Pagination", :mime_types => []},
        :pagination_item => {:uuid => :"5db1f95e-4d10-4058-8726-8a5a8cc478a1", :version => 0.0, :ufs => "org.gxg.gui.pagination.item", :title => "Pagination Item", :mime_types => []},
        :progress_bar => {:uuid => :"dc8cec03-5fad-4b02-a9aa-65971d04e6e9", :version => 0.0, :ufs => "org.gxg.gui.progress.bar", :title => "Progress Bar", :mime_types => []},
        :progress_meter => {:uuid => :"cb131b60-9a03-4201-bceb-cb5a2c0f0629", :version => 0.0, :ufs => "org.gxg.gui.progress.meter", :title => "Progress Meter", :mime_types => []},
        :horizontal_slider => {:uuid => :"2f169eaa-5f4f-4a87-a13b-97fc132fc749", :version => 0.0, :ufs => "org.gxg.gui.slider.horizontal", :title => "Horizontal Slider", :mime_types => []},
        :vertical_slider => {:uuid => :"2f169eaa-5f4f-4a87-a13b-97fc132fc749", :version => 0.0, :ufs => "org.gxg.gui.slider.vertical", :title => "Vertical Slider", :mime_types => []},
        :sticky => {:uuid => :"b4919664-673f-4c35-a46f-1e3dd65f1742", :version => 0.0, :ufs => "org.gxg.gui.sticky", :title => "Sticky", :mime_types => []},
        :sticky_container => {:uuid => :"dead9dce-6efc-48c8-903a-bdb4d1b8fc96", :version => 0.0, :ufs => "org.gxg.gui.sticky.container", :title => "Sticky Container", :mime_types => []},
        :switch => {:uuid => :"eb933549-9f36-47e4-972e-2686098f6134", :version => 0.0, :ufs => "org.gxg.gui.switch", :title => "Switch", :mime_types => []},,
        :tab_set => {:uuid => :"49c5a2c6-a972-47c5-b4c9-33cfe3166b36", :version => 0.0, :ufs => "org.gxg.gui.tab.set", :title => "Tab Set", :mime_types => []},
        :tab_content => {:uuid => :"c5181355-0cc9-46fb-b7ed-8efd42a85a80", :version => 0.0, :ufs => "org.gxg.gui.tab.content", :title => "Tab Content", :mime_types => []},
        :thumbnail => {:uuid => :"6459fa8a-6d4a-407d-ad22-a790382091fc", :version => 0.0, :ufs => "org.gxg.gui.thumbnail", :title => "Thumbnail", :mime_types => []},
        :titlebar => {:uuid => :"b51f8029-54c2-4cd8-842e-b74770535d88", :version => 0.0, :ufs => "org.gxg.gui.titlebar", :title => "Titlebar", :mime_types => []},
        :titlebar_left => {:uuid => :"c4f29149-4c2b-473d-9fd6-122df4883b4c", :version => 0.0, :ufs => "org.gxg.gui.titlebar.left", :title => "Titlebar Left", :mime_types => []},
        :titlebar_right => {:uuid => :"a7c2a061-58ed-4b85-9472-413db2061897", :version => 0.0, :ufs => "org.gxg.gui.titlebar.right", :title => "Titlebar Right", :mime_types => []},
        :topbar => {:uuid => :"1e724b93-a940-4fbf-83a0-479c4f511f6d", :version => 0.0, :ufs => "org.gxg.gui.topbar", :title => "Topbar", :mime_types => []},
        :topbar_left => {:uuid => :"a5f1b341-d4dc-49f7-a972-5845c5803bd9", :version => 0.0, :ufs => "org.gxg.gui.topbar.left", :title => "Topbar Left", :mime_types => []},
        :topbar_right => {:uuid => :"3aa96c4e-cca3-4408-a1c8-902083d8536b", :version => 0.0, :ufs => "org.gxg.gui.topbar.right", :title => "Topbar Right", :mime_types => []}
    }
    # ### Create/Update Formats:
    the_format = format_template.clone
    the_format[:uuid] = :"58230f5b-83c9-4569-bb82-8564fffd5d74"
    the_format[:ufs] = "org.gxg.file"
    the_format[:title] = "File"
    the_format[:version] = 0.0001
    the_format[:content] = file_format
    if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
        GxG::DB[:roles][:formats].format_create(the_format)
    else
        existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
        if existing_format
            the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
        end
        GxG::DB[:roles][:formats].format_update(the_format)
    end
    format_manifest.each_pair do |component,stub|
        the_format = format_template.clone
        the_format[:uuid] = stub[:uuid]
        the_format[:ufs] = stub[:ufs]
        the_format[:title] = stub[:title]
        the_format[:version] = 0.0001
        the_format[:mime_types] = stub[:mime_types]
        the_format[:content] = stub[:content]
        if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
            GxG::DB[:roles][:formats].format_create(the_format)
        else
            existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
            if existing_format
                the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
            end
            GxG::DB[:roles][:formats].format_update(the_format)
        end
    end
    #
    the_format = format_template.clone
    the_format[:uuid] = :"cceb380b-fbc7-4dc9-ab75-3bf2c43d697b"
    the_format[:ufs] = "org.gxg.gui.page"
    the_format[:title] = "Page"
    the_format[:version] = 0.0001
    the_format[:content] = page_format
    if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
        GxG::DB[:roles][:formats].format_create(the_format)
    else
        existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
        if existing_format
            the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
        end
        GxG::DB[:roles][:formats].format_update(the_format)
    end
    #
    the_format = format_template.clone
    the_format[:uuid] = :"2884f52a-29fd-4ac6-add7-69f91f805fd3"
    the_format[:ufs] = "org.gxg.component.library"
    the_format[:title] = "Library"
    the_format[:version] = 0.0001
    the_format[:content] = lib_format
    if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
        GxG::DB[:roles][:formats].format_create(the_format)
    else
        existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
        if existing_format
            the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
        end
        GxG::DB[:roles][:formats].format_update(the_format)
    end
    #
    the_format = format_template.clone
    the_format[:uuid] = :"04ce09a6-c6e8-43d9-90e3-69f34d3be0a3"
    the_format[:ufs] = "org.gxg.component.application"
    the_format[:title] = "Application"
    the_format[:version] = 0.0001
    the_format[:content] = app_format
    if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
        GxG::DB[:roles][:formats].format_create(the_format)
    else
        existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
        if existing_format
            the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
        end
        GxG::DB[:roles][:formats].format_update(the_format)
    end
    #
    the_format = format_template.clone
    the_format[:uuid] = :"d2413191-af3a-486f-bb6f-22b43ba6569f"
    the_format[:ufs] = "org.gxg.component.viewer"
    the_format[:title] = "Viewer"
    the_format[:version] = 0.0001.to_d
    the_format[:content] = app_format
    if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
        GxG::DB[:roles][:formats].format_create(the_format)
    else
        existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
        if existing_format
            the_format[:version] = existing_format[:version] += 0.0001
        end
        GxG::DB[:roles][:formats].format_update(the_format)
    end
    #
    the_format = format_template.clone
    the_format[:uuid] = :"c986c0f5-d082-4c29-b66a-ff0cd03dfa65"
    the_format[:ufs] = "org.gxg.component.editor"
    the_format[:title] = "Editor"
    the_format[:version] = 0.0001.to_d
    the_format[:content] = app_format
    if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
        GxG::DB[:roles][:formats].format_create(the_format)
    else
        existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
        if existing_format
            the_format[:version] = existing_format[:version] += 0.0001
        end
        GxG::DB[:roles][:formats].format_update(the_format)
    end
    #
    component_manifest.each_pair do |component,stub|
        the_format = format_template.clone
        the_component_record = component_format.clone
        the_component_record[:component] = stub[:ufs].to_s
        the_format[:uuid] = stub[:uuid]
        the_format[:ufs] = stub[:ufs]
        the_format[:title] = stub[:title]
        the_format[:version] = 0.0001
        case component
        when :table
        end
        the_format[:content] = the_component_record
        if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
            GxG::DB[:roles][:formats].format_create(the_format)
        else
            existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
            if existing_format
                the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
            end
            GxG::DB[:roles][:formats].format_update(the_format)
        end
    end
    #
    true
end
seed_formats