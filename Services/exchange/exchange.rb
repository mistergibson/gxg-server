# ### Exchange Service
module GxG
    module Services
        module Exchange
            class RecordModel
                #
                private
                #
                def add_link(the_pool=nil, the_uuid=nil)
                    result = false
                    if the_pool.is_a?(::Symbol) && ::GxG::valid_uuid?(the_uuid)
                        if @data[(the_pool)].include?(the_uuid.to_s)
                            result = true
                        else
                            if @data[(the_pool)].wait_for_reservation()
                                @data[(the_pool)] << the_uuid.to_s
                                result = true
                            else
                                log_warning("Unable to secure write-reservation for #{the_pool.inspect} UUID list.")
                            end
                        end
                    end
                    result
                end
                #
                def remove_link(the_pool=nil, the_uuid=nil)
                    result = false
                    if the_pool.is_a?(::Symbol) && ::GxG::valid_uuid?(the_uuid)
                        found = @data[(the_pool)].find_index(the_uuid.to_s)
                        if found
                            if @data[(the_pool)].wait_for_reservation()
                                @data[(the_pool)].delete_at(found)
                                result = true
                            else
                                log_warning("Unable to secure write-reservation for #{the_pool.inspect} UUID list.")
                            end
                        else
                            result = true
                        end
                    end
                    result
                end
                #
                def amount_and_currency(the_amount=nil, the_currency=nil)
                    result = nil
                    if the_amount.is_a?(::Integer) && ::GxG::valid_uuid?(the_currency)
                        currency_record = ::GxG::DB[:roles][:reference].retrieve_by_uuid(the_currency, GxG::DB[:administrator])
                        if currency_record
                            record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.amount"})
                            if record
                                if record.wait_for_reservation()
                                    record[:currency_uuid] = the_currency.to_s
                                    record[:amount] = the_amount
                                    record.save
                                    record.release_reservation
                                    result = record
                                else
                                    log_warning("Could not secure a write-reservation for the new Amount record.")
                                end
                            end
                        else
                            log_warning("Currency #{the_currency.inspect} does not exist in this database.")
                        end
                    end
                    result
                end
                #
                #
                public
                #
                def self.delete(the_uuid=nil)
                    result = false
                    if ::GxG::valid_uuid?(product_uuid)
                        record = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_uuid, GxG::DB[:administrator])
                        if record.is_a?(::GxG::Database::PersistedHash)
                            if record.wait_for_reservation()
                                record.destroy
                                result = true
                            end
                        end
                    end
                    result
                end
                #
                def initialize(payload=nil)
                    unless payload.is_a?(::GxG::Database::PersistedHash)
                        raise ArgumentError, "You MUST provide the model with a PersistedHash, not: #{payload.inspect}"
                    end
                    @data = payload
                    self
                end
                #
                def destroy()
                    if @data.destroy()
                        @data = nil
                        true
                    else
                        false
                    end
                end
                #
                def ufs()
                    @data.ufs
                end
                #
                def uuid()
                    @data.uuid()
                end
                #
                def title()
                    @data.title()
                end
                #
                def title=(the_title=nil)
                    if the_title.is_a?(::String)
                        @data.set_title(the_title[0..255])
                        unless @data.title() == the_title[0..255]
                            log_warning("Unable to set title on Product #{@data.uuid.inspect} .")
                        end
                    end
                    the_title
                end
                #
                def open(timeout=nil)
                    @data.wait_for_reservation(timeout)
                end
                #
                def open?()
                    @data.write_reserved?
                end
                #
                def save()
                    @data.save
                end
                #
                def close()
                    @data.release_reservation
                    true
                end
                #
                def keys()
                    @data.keys
                end
                #
                def [](the_property=nil)
                    if the_property.is_a?(::Symbol)
                        @data[(the_property)]
                    else
                        nil
                    end
                end
                #
                def []=(the_property=nil,the_value=nil)
                    if the_property.is_a?(::Symbol)
                        @data[(the_property)] = the_value
                    end
                    the_value
                end
                #
                def update(details={})
                    result = false
                    if details.is_any?(::Hash, ::GxG::Database::PersistedHash)
                        if @data.wait_for_reservation()
                            self.keys.each do |the_key|
                                if details.keys.include?(the_key)
                                    @data[(the_key)] = details[(the_key)]
                                end
                            end
                            @data.save
                            result = true
                        end
                    end
                    result
                end
                #
            end
            # ### Vendable
            class Vendable < ::GxG::Services::Exchange::RecordModel
                private
                #
                def set_price(the_pool=nil, the_amount=nil, the_currency=nil)
                    result = false
                    if the_pool.is_a?(::Symbol) && the_amount.is_a?(::Integer) && ::GxG::valid_uuid?(the_currency)
                        found = nil
                        @data[(the_pool)].each do |price_record|
                            if price_record[:currency_uuid].to_s == the_currency.to_s
                                found = price_record
                                break
                            end
                        end
                        if found
                            if found.wait_for_reservation()
                                found[:amount] = the_amount
                                found.save
                                found.release_reservation
                                result = true
                            else
                                log_warning("Unable to secure a write-reservation for amount #{found.uuid.inspect} in #{the_pool.inspect} of object #{@data.uuid.inspect} .")
                            end
                        else
                            price_record = amount_and_currency(the_amount, the_currency)
                            if price_record
                                if price_record.wait_for_reservation()
                                    @data[(the_pool)] << price_record
                                    price_record.release_reservation
                                    result = true
                                else
                                    log_warning("Unable to secure a write-reservation for amount #{price_record.uuid.inspect} in #{the_pool.inspect} of object #{@data.uuid.inspect} .")
                                end
                            else
                                log_warning("Unable to create amount #{the_amount.inspect} in #{the_pool.inspect} of object #{@data.uuid.inspect} .")
                            end
                        end
                    end
                    result
                end
                #
                public
                #
            end
            # ### Exchange
            # Inventory of supported Currencies
            # Ties products and services to revenue and cost-of-goods accounts in Accounting.
            class Exchange < ::GxG::Services::Exchange::RecordModel
                def self.create(details={})
                    # Organization Details to track:
                    # :organization_type => "",
                    # :description => "",
                    # :logo_avatar_uuid => "",
                    # :website => "",
                    # :main_contact_uuid => "",
                    # :technical_contact_uuid => "",
                    # :development_contact_uuid => "",
                    # :engineering_contact_uuid => "",
                    # :billing_contact_uuid => "",
                    # :shipping_contact_uuid => "",
                    # :sales_contact_uuid => "",
                    # :marketing_contact_uuid => "",
                    # :press_contact_uuid => ""
                    #
                    # xxx
                    # create new product and populate with details
                    the_product = nil
                    record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.product"})
                    if record
                        the_product = ::GxG::Services::Exchange::Product.new(record)
                        the_product.open
                        the_product[:vendor_exchange_uuid] = exchange_uuid.to_s
                        the_product[:vendor_member_uuid] = member_uuid.to_s
                        the_product.save
                        the_product.update(details)
                        the_product.close
                    end
                    the_product
                end
                #
                def self.load(the_uuid=nil)
                    result = nil
                    if ::GxG::valid_uuid?(the_uuid)
                        record = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_uuid, GxG::DB[:administrator])
                        if record.is_a?(::GxG::Database::PersistedHash)
                            if record.ufs().to_s == "org.gxg.exchange.product"
                                result = ::GxG::Services::Exchange::Product.new(record)
                            else
                                log_warning("You attempted to mount a record of ufs #{record.ufs} for class Product.")
                            end
                        end
                    end
                    result
                end
                #
                def self.delete(the_uuid=nil)
                    result = false
                    if ::GxG::valid_uuid?(product_uuid)
                        record = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_uuid, GxG::DB[:administrator])
                        if record.is_a?(::GxG::Database::PersistedHash)
                            if record.wait_for_reservation()
                                # Review : TODO - complete this section in Beta
                                # Delete ALL Products, Services, Orders (& OrderItems), Accounts (& AccountEntry), & Members of Exchange first.
                                # record.destroy
                                result = true
                            end
                        end
                    end
                    result
                end
                #
                def initialize(payload=nil)
                    @data = payload
                    self
                end
                #
                def add_member(details={})
                    # create new member
                    # create chart of accounts (book) in accounting
                end
                #
                def remove_member(member_uuid=nil)
                    # Purges member records:
                    # ensure no member-session is open
                    # remove chart of accounts (book), account entries, products, services, orders (and order items), etc. ?? (keep accounting records for 7 years?)
                    # remove member record.
                end
                #
            end
            # ### Members
            class Member < ::GxG::Services::Exchange::RecordModel
                # :exchange_uuid => "",
                # :username => "",
                # :password_hash => "",
                # :person => nil,
                # :billing_address => nil,
                # :shipping_address => nil,
                # :payment_method_uuids => [],
                # :default_payment_method_uuid => "",
                # :monthly_billing_day => 1,
                # :device_uuids => []
                def add_product(details={})
                    # create new product
                    # allocate new revenue and cost_of_goods_sold accounts for that product/service.
                end
                #
                def remove_product(product_uuid=nil)
                end
                #
                def add_service(details={})
                    # create new service
                    # allocate new revenue and cost_of_goods_sold accounts for that product/service.
                end
                #
                def remove_service(service_uuid=nil)
                end
                #
                def add_subscription(details={})
                    # create new subscription
                    # allocate new revenue and cost_of_goods_sold accounts for that product/service.
                end
                #
                def remove_subscription(product_uuid=nil)
                end
                #
                def add_package(details={})
                    # create new product
                    # allocate new revenue and cost_of_goods_sold accounts for that product/service.
                end
                #
                def remove_package(product_uuid=nil)
                end
                #
            end
            # ### Products
            # :vendor_exchange_uuid => "",
            # :vendor_member_uuid => "",
            # :name => "",
            # :sku => "",
            # :description => "",
            # :thumbnail_avatar => nil,
            # :product_type => "",
            # :categories => [],
            # :tax_category => "",
            # :brand => "",
            # :model => "",
            # :weight => 0.0,
            # :unit_of_weight => "ounces",
            # :height => 0.0,
            # :width => 0.0,
            # :depth => 0.0,
            # :unit_of_measure => "inches",
            # :count_on_hand => 0,
            # :back_orderable => false,
            # :available_at => nil,
            # :unavailable_at => nil,
            # :options => [],
            # :properties => [],
            # :price_amounts => [],
            # :discounts => [],
            # :quantity_pricing => []
            class Product < ::GxG::Services::Exchange::Vendable
                def self.create(exchange_uuid=nil, member_uuid=nil, details={})
                    unless ::GxG::valid_uuid?(exchange_uuid)
                        raise ArgumentError, "Exchange MUST be specified with a valid UUID."
                    end
                    unless ::GxG::valid_uuid?(member_uuid)
                        raise ArgumentError, "Exchange Member MUST be specified with a valid UUID."
                    end
                    # create new product and populate with details
                    the_product = nil
                    record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.product"})
                    if record
                        the_product = ::GxG::Services::Exchange::Product.new(record)
                        the_product.open
                        the_product[:vendor_exchange_uuid] = exchange_uuid.to_s
                        the_product[:vendor_member_uuid] = member_uuid.to_s
                        the_product.save
                        the_product.update(details)
                        the_product.close
                    end
                    the_product
                end
                #
                def self.load(the_uuid=nil)
                    result = nil
                    if ::GxG::valid_uuid?(the_uuid)
                        record = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_uuid, GxG::DB[:administrator])
                        if record.is_a?(::GxG::Database::PersistedHash)
                            if record.ufs().to_s == "org.gxg.exchange.product"
                                result = ::GxG::Services::Exchange::Product.new(record)
                            else
                                log_warning("You attempted to mount a record of ufs #{record.ufs} for class Product.")
                            end
                        end
                    end
                    result
                end
                #
                def initialize(payload=nil)
                    super(payload)
                    self
                end
                #
                # ### item Options
                # :type => "",
                # :name => "",
                # :value => ""
                def options()
                    @data[:options]
                end
                #
                def add_option(the_type=nil, the_name=nil, the_value=nil)
                    result = false
                    if the_type.is_a?(::String) && the_name.is_a?(::String) && the_value.is_a?(::String)
                        record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.item.option"})
                        if record
                            record[:type] = the_type.to_s
                            record[:name] = the_name.to_s
                            record[:value] = the_value.to_s
                            record.save
                            @data[:options] << record
                            result = true
                        end
                    end
                    result
                end
                #
                def remove_option(the_name=nil)
                    result = false
                    if the_name.is_a?(::String)
                        @data[:options].each_with_index do |entry, indexer|
                            if entry[:name].to_s == the_name
                                if entry.wait_for_reservation
                                    @data[:options].delete_at(indexer).destroy
                                    result = true
                                    break
                                else
                                    log_warning("Cannot secure write-reservation to delete option #{the_name} .")
                                    break
                                end
                            end
                        end
                    end
                    result
                end
                # ### Item Properties
                # :label => "",
                # :name => "",
                # :value => ""
                def properties()
                    @data[:properties]
                end
                #
                def add_property(the_label=nil, the_name=nil, the_value=nil)
                    result = false
                    if the_label.is_a?(::String) && the_name.is_a?(::String) && the_value.is_a?(::String)
                        record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.item.property"})
                        if record
                            record[:label] = the_label.to_s
                            record[:name] = the_name.to_s
                            record[:value] = the_value.to_s
                            record.save
                            @data[:properties] << record
                            result = true
                        end
                    end
                    result
                end
                #
                def remove_property(the_name=nil)
                    result = false
                    if the_name.is_a?(::String)
                        @data[:properties].each_with_index do |entry, indexer|
                            if entry[:name].to_s == the_name
                                if entry.wait_for_reservation
                                    @data[:properties].delete_at(indexer).destroy
                                    result = true
                                    break
                                else
                                    log_warning("Cannot secure write-reservation to delete property #{the_name} .")
                                    break
                                end
                            end
                        end
                    end
                    result
                end
                # Product Price
                def set_product_price(the_amount=nil, the_currency=nil)
                    set_price(:price_amounts, the_amount, the_currency)
                end
                # ### Discounts
                # :coupon_code => "",
                # :coupon_name => "",
                # :begins_at => nil,
                # :ends_at => nil,
                # :quantity_start => 0,
                # :quantity_end => 0,
                # :discount_percentage => 0.0
                def discounts()
                    @data[:discounts]
                end
                #
                def add_discount(details=nil)
                    result = false
                    if details.is_any?(::Hash, ::GxG::Database::PersistedHash)
                        record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.discount"})
                        if record
                            record.keys.each do |the_property|
                                if details.keys.include?(the_property)
                                    record[(the_property)] = details[(the_property)]
                                end
                            end
                            record.save
                            record.release_reservation
                            @data[:discounts] << record
                            result = true
                        end
                    end
                    result
                end
                #
                def remove_discount(the_name=nil)
                    result = false
                    if the_name.is_a?(::String)
                        @data[:discounts].each_with_index do |entry, indexer|
                            if entry[:coupon_name].to_s == the_name
                                if entry.wait_for_reservation
                                    @data[:discounts].delete_at(indexer).destroy
                                    result = true
                                    break
                                else
                                    log_warning("Cannot secure write-reservation to delete discount #{the_name} .")
                                    break
                                end
                            end
                        end
                    end
                    result
                end
                # ### Quantity Pricing
                # :void_if_coupon_code => "",
                # :schedule_name => "",
                # :begins_at => nil,
                # :ends_at => nil,
                # :quantity_start => 0,
                # :quantity_end => 0,
                # :unit_price_amounts => []
                def quantity_pricing()
                    @data[:quantity_pricing]
                end
                #
                def add_quantity_pricing(details=nil, amounts=[])
                    result = false
                    if details.is_any?(::Hash, ::GxG::Database::PersistedHash) && amounts.is_any?(::Array, ::GxG::Database::PersistedArray)
                        record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.pricing.quantity"})
                        if record
                            if record.wait_for_reservation()
                                record.keys.each do |the_property|
                                    if details.keys.include?(the_property)
                                        record[(the_property)] = details[(the_property)]
                                    end
                                end
                                amounts.each do |the_amount_record|
                                    record[:unit_price_amounts] << the_amount_record
                                end
                                record.save
                                record.release_reservation
                                @data[:quantity_pricing] << record
                                result = true
                            end
                        end
                    end
                    result
                end
                #
                def remove_quantity_pricing(the_name=nil)
                    result = false
                    if the_name.is_a?(::String)
                        @data[:quantity_pricing].each_with_index do |entry, indexer|
                            if entry[:schedule_name].to_s == the_name
                                if entry.wait_for_reservation
                                    @data[:quantity_pricing].delete_at(indexer).destroy
                                    result = true
                                    break
                                else
                                    log_warning("Cannot secure write-reservation to delete quantity price schedule #{the_name} .")
                                    break
                                end
                            end
                        end
                    end
                    result
                end
                #
            end
            # ### Services
            # :vendor_exchange_uuid => "",
            # :vendor_member_uuid => "",
            # :name => "",
            # :sku => "",
            # :description => "",
            # :thumbnail_avatar => nil,
            # :service_type => "",
            # :categories => [],
            # :tax_category => "",
            # :rate_amounts => [],
            # :rate_metric => "monthly",
            # :options => [],
            # :properties => [],
            # :discounts => [],
            # :quantity_pricing => []
            class Service < ::GxG::Services::Exchange::Vendable
                def self.create(exchange_uuid=nil, member_uuid=nil, details={})
                    unless ::GxG::valid_uuid?(exchange_uuid)
                        raise ArgumentError, "Exchange MUST be specified with a valid UUID."
                    end
                    unless ::GxG::valid_uuid?(member_uuid)
                        raise ArgumentError, "Exchange Member MUST be specified with a valid UUID."
                    end
                    # create new product and populate with details
                    the_service = nil
                    record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.service"})
                    if record
                        the_service = ::GxG::Services::Exchange::Service.new(record)
                        the_service.open
                        the_service[:vendor_exchange_uuid] = exchange_uuid.to_s
                        the_service[:vendor_member_uuid] = member_uuid.to_s
                        the_service.save
                        the_service.update(details)
                        the_service.close
                    end
                    the_service
                end
                #
                def self.load(the_uuid=nil)
                    result = nil
                    if ::GxG::valid_uuid?(the_uuid)
                        record = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_uuid, GxG::DB[:administrator])
                        if record.is_a?(::GxG::Database::PersistedHash)
                            if record.ufs().to_s == "org.gxg.exchange.service"
                                result = ::GxG::Services::Exchange::Service.new(record)
                            else
                                log_warning("You attempted to mount a record of ufs #{record.ufs} for class Service.")
                            end
                        end
                    end
                    result
                end
                #
                def initialize(payload=nil)
                    super(payload)
                    self
                end
                #
                # ### item Options
                # :type => "",
                # :name => "",
                # :value => ""
                def options()
                    @data[:options]
                end
                #
                def add_option(the_type=nil, the_name=nil, the_value=nil)
                    result = false
                    if the_type.is_a?(::String) && the_name.is_a?(::String) && the_value.is_a?(::String)
                        record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.item.option"})
                        if record
                            record[:type] = the_type
                            record[:name] = the_name
                            record[:value] = the_value
                            record.save
                            @data[:options] << record
                            result = true
                        end
                    end
                    result
                end
                #
                def remove_option(the_name=nil)
                    result = false
                    if the_name.is_a?(::String)
                        @data[:options].each_with_index do |entry, indexer|
                            if entry[:name].to_s == the_name
                                if entry.wait_for_reservation
                                    @data[:options].delete_at(indexer).destroy
                                    result = true
                                    break
                                else
                                    log_warning("Cannot secure write-reservation to delete option #{the_name} .")
                                    break
                                end
                            end
                        end
                    end
                    result
                end
                # ### Item Properties
                # :label => "",
                # :name => "",
                # :value => ""
                def properties()
                    @data[:properties]
                end
                #
                def add_property(the_label=nil, the_name=nil, the_value=nil)
                    result = false
                    if the_label.is_a?(::String) && the_name.is_a?(::String) && the_value.is_a?(::String)
                        record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.item.property"})
                        if record
                            record[:label] = the_label
                            record[:name] = the_name
                            record[:value] = the_value
                            record.save
                            @data[:properties] << record
                            result = true
                        end
                    end
                    result
                end
                #
                def remove_property(the_name=nil)
                    result = false
                    if the_name.is_a?(::String)
                        @data[:properties].each_with_index do |entry, indexer|
                            if entry[:name].to_s == the_name
                                if entry.wait_for_reservation
                                    @data[:properties].delete_at(indexer).destroy
                                    result = true
                                    break
                                else
                                    log_warning("Cannot secure write-reservation to delete property #{the_name} .")
                                    break
                                end
                            end
                        end
                    end
                    result
                end
                # ### Service Rate
                def set_service_rate(the_amount=nil, the_currency=nil)
                    set_price(:rate_amounts, the_amount, the_currency)
                end
                # ### Discounts
                # :coupon_code => "",
                # :coupon_name => "",
                # :begins_at => nil,
                # :ends_at => nil,
                # :quantity_start => 0,
                # :quantity_end => 0,
                # :discount_percentage => 0.0
                def discounts()
                    @data[:discounts]
                end
                #
                def add_discount(details=nil)
                    result = false
                    if details.is_any?(::Hash, ::GxG::Database::PersistedHash)
                        record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.discount"})
                        if record
                            record.keys.each do |the_property|
                                if details.keys.include?(the_property)
                                    record[(the_property)] = details[(the_property)]
                                end
                            end
                            record.save
                            record.release_reservation
                            @data[:discounts] << record
                            result = true
                        end
                    end
                    result
                end
                #
                def remove_discount(the_name=nil)
                    result = false
                    if the_name.is_a?(::String)
                        @data[:discounts].each_with_index do |entry, indexer|
                            if entry[:coupon_name].to_s == the_name
                                if entry.wait_for_reservation
                                    @data[:discounts].delete_at(indexer).destroy
                                    result = true
                                    break
                                else
                                    log_warning("Cannot secure write-reservation to delete discount #{the_name} .")
                                    break
                                end
                            end
                        end
                    end
                    result
                end
                #
                # ### Quantity Pricing
                # :void_if_coupon_code => "",
                # :schedule_name => "",
                # :begins_at => nil,
                # :ends_at => nil,
                # :quantity_start => 0,
                # :quantity_end => 0,
                # :unit_price_amounts => []
                def quantity_pricing()
                    @data[:quantity_pricing]
                end
                #
                def add_quantity_pricing(details=nil, amounts=[])
                    result = false
                    if details.is_any?(::Hash, ::GxG::Database::PersistedHash) && amounts.is_any?(::Array, ::GxG::Database::PersistedArray)
                        record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.pricing.quantity"})
                        if record
                            if record.wait_for_reservation()
                                record.keys.each do |the_property|
                                    if details.keys.include?(the_property)
                                        record[(the_property)] = details[(the_property)]
                                    end
                                end
                                amounts.each do |the_amount_record|
                                    record[:unit_price_amounts] << the_amount_record
                                end
                                record.save
                                record.release_reservation
                                @data[:quantity_pricing] << record
                                result = true
                            end
                        end
                    end
                    result
                end
                #
                def remove_quantity_pricing(the_name=nil)
                    result = false
                    if the_name.is_a?(::String)
                        @data[:quantity_pricing].each_with_index do |entry, indexer|
                            if entry[:schedule_name].to_s == the_name
                                if entry.wait_for_reservation
                                    @data[:quantity_pricing].delete_at(indexer).destroy
                                    result = true
                                    break
                                else
                                    log_warning("Cannot secure write-reservation to delete quantity price schedule #{the_name} .")
                                    break
                                end
                            end
                        end
                    end
                    result
                end
                #
            end
            # ### Subscriptions
            # :vendor_exchange_uuid => "",
            # :vendor_member_uuid => "",
            # :name => "",
            # :sku => "",
            # :description => "",
            # :thumbnail_avatar => nil,
            # :service_uuids => [],
            # :product_uuids => [],
            # :frequency => "monthly"
            class Subscription < ::GxG::Services::Exchange::RecordModel
                def self.create(exchange_uuid=nil, member_uuid=nil, details={})
                    unless ::GxG::valid_uuid?(exchange_uuid)
                        raise ArgumentError, "Exchange MUST be specified with a valid UUID."
                    end
                    unless ::GxG::valid_uuid?(member_uuid)
                        raise ArgumentError, "Exchange Member MUST be specified with a valid UUID."
                    end
                    # create new product and populate with details
                    the_subscription = nil
                    record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.subscription"})
                    if record
                        the_subscription = ::GxG::Services::Exchange::Subscription.new(record)
                        the_subscription.open
                        the_subscription[:vendor_exchange_uuid] = exchange_uuid.to_s
                        the_subscription[:vendor_member_uuid] = member_uuid.to_s
                        the_subscription.save
                        the_subscription.update(details)
                        the_subscription.close
                    end
                    the_subscription
                end
                #
                def self.load(the_uuid=nil)
                    result = nil
                    if ::GxG::valid_uuid?(the_uuid)
                        record = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_uuid, GxG::DB[:administrator])
                        if record.is_a?(::GxG::Database::PersistedHash)
                            if record.ufs().to_s == "org.gxg.exchange.subscription"
                                result = ::GxG::Services::Exchange::Subscription.new(record)
                            else
                                log_warning("You attempted to mount a record of ufs #{record.ufs} for class Subscription.")
                            end
                        end
                    end
                    result
                end
                #
                def initialize(payload=nil)
                    super(payload)
                    self
                end
                #
                def add_service_link(the_uuid=nil)
                    add_link(:service_uuids, the_uuid)
                end
                #
                def remove_service_link(the_uuid=nil)
                    remove_link(:service_uuids, the_uuid)
                end
                #
                def add_product_link(the_uuid=nil)
                    add_link(:product_uuids, the_uuid)
                end
                #
                def remove_product_link(the_uuid=nil)
                    remove_link(:product_uuids, the_uuid)
                end
                #
            end
            # ### Packages
            # :vendor_exchange_uuid => "",
            # :vendor_member_uuid => "",
            # :name => "",
            # :sku => "",
            # :description => "",
            # :thumbnail_avatar => nil,
            # :service_uuids => [],
            # :product_uuids => [],
            # :subscription_uuids => []
            class Package < ::GxG::Services::Exchange::RecordModel
                def self.create(exchange_uuid=nil, member_uuid=nil, details={})
                    unless ::GxG::valid_uuid?(exchange_uuid)
                        raise ArgumentError, "Exchange MUST be specified with a valid UUID."
                    end
                    unless ::GxG::valid_uuid?(member_uuid)
                        raise ArgumentError, "Exchange Member MUST be specified with a valid UUID."
                    end
                    # create new product and populate with details
                    the_package = nil
                    record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.package"})
                    if record
                        the_package = ::GxG::Services::Exchange::Package.new(record)
                        the_package.open
                        the_package[:vendor_exchange_uuid] = exchange_uuid.to_s
                        the_package[:vendor_member_uuid] = member_uuid.to_s
                        the_package.save
                        the_package.update(details)
                        the_package.close
                    end
                    the_package
                end
                #
                def self.load(the_uuid=nil)
                    result = nil
                    if ::GxG::valid_uuid?(the_uuid)
                        record = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_uuid, GxG::DB[:administrator])
                        if record.is_a?(::GxG::Database::PersistedHash)
                            if record.ufs().to_s == "org.gxg.exchange.package"
                                result = ::GxG::Services::Exchange::Package.new(record)
                            else
                                log_warning("You attempted to mount a record of ufs #{record.ufs} for class Package.")
                            end
                        end
                    end
                    result
                end
                #
                def initialize(payload=nil)
                    super(payload)
                    self
                end
                #
                def add_service_link(the_uuid=nil)
                    add_link(:service_uuids, the_uuid)
                end
                #
                def remove_service_link(the_uuid=nil)
                    remove_link(:service_uuids, the_uuid)
                end
                #
                def add_product_link(the_uuid=nil)
                    add_link(:product_uuids, the_uuid)
                end
                #
                def remove_product_link(the_uuid=nil)
                    remove_link(:product_uuids, the_uuid)
                end
                #
                def add_subscription_link(the_uuid=nil)
                    add_link(:subscription_uuids, the_uuid)
                end
                #
                def remove_subscription_link(the_uuid=nil)
                    remove_link(:subscription_uuids, the_uuid)
                end
                #
            end
            # ### Orders
            # :vendor_exchange_uuid => "",
            # :vendor_member_uuid => "",
            # :buyer_exchange_uuid => "",
            # :buyer_member_uuid => "",
            # :order_from_ip => "",
            # :order_datetime => nil,
            # :order_number => "",
            # :order_item_uuids => [],
            # :order_shipping_amounts => [],
            # :order_status => "Composing",
            # :order_shipping_tracking_id => "",
            # :order_shipping_tracking_url => ""
            class Order < ::GxG::Services::Exchange::RecordModel
                def self.create(exchange_uuid=nil, member_uuid=nil, details={})
                    unless ::GxG::valid_uuid?(exchange_uuid)
                        raise ArgumentError, "Exchange MUST be specified with a valid UUID."
                    end
                    unless ::GxG::valid_uuid?(member_uuid)
                        raise ArgumentError, "Exchange Member MUST be specified with a valid UUID."
                    end
                    # create new product and populate with details
                    the_order = nil
                    record = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.exchange.order"})
                    if record
                        the_order = ::GxG::Services::Exchange::Order.new(record)
                        the_order.open
                        the_order[:vendor_exchange_uuid] = exchange_uuid.to_s
                        the_order[:vendor_member_uuid] = member_uuid.to_s
                        the_order.save
                        the_order.update(details)
                        the_order.close
                    end
                    the_order
                end
                #
                def self.load(the_uuid=nil)
                    result = nil
                    if ::GxG::valid_uuid?(the_uuid)
                        record = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_uuid, GxG::DB[:administrator])
                        if record.is_a?(::GxG::Database::PersistedHash)
                            if record.ufs().to_s == "org.gxg.exchange.order"
                                result = ::GxG::Services::Exchange::Order.new(record)
                            else
                                log_warning("You attempted to mount a record of ufs #{record.ufs} for class Order.")
                            end
                        end
                    end
                    result
                end
                #
                def initialize(payload=nil)
                    super(payload)
                    self
                end
                #
            end
            # ### Order Items
        end
    end
end
# ### Startup
exchange_service = ::GxG::Services::Service.new(:exchange)
exchange_service.require_service(:accounting)
# ### Define Public Command Interface:
exchange_service.on(:start, {:description => "Exchange Service Start", :usage => "{ :start => nil }"}) do
  ::GxG::SERVICES[:exchange].start
  ::GxG::SERVICES[:exchange].publish_api
end
exchange_service.on(:stop, {:description => "Exchange Service Stop", :usage => "{ :stop => nil }"}) do
  ::GxG::SERVICES[:exchange].stop
  ::GxG::SERVICES[:exchange].unpublish_api
end
exchange_service.on(:restart, {:description => "Exchange Service Restart", :usage => "{ :restart => nil }"}) do
  ::GxG::SERVICES[:exchange].restart
end
exchange_service.on(:pause, {:description => "Exchange Service Pause", :usage => "{ :pause => nil }"}) do
  ::GxG::SERVICES[:exchange].pause
  ::GxG::SERVICES[:exchange].unpublish_api
end
exchange_service.on(:resume, {:description => "Exchange Service Resume", :usage => "{ :resume => nil }"}) do
  ::GxG::SERVICES[:exchange].resume
  ::GxG::SERVICES[:exchange].publish_api
end
# ### Define Internal Service Control Events:
exchange_service.on(:at_start, {:description => "Exchange Startup", :usage => "{ :at_start => (service-object) }"}) do |service|
    {:result => true}
end
# ### Service Installation
unless ::GxG::Services::service_available?(:exchange)
    ::GxG::Services::install_service(:exchange)
    ::GxG::Services::enable_service(:exchange)
end
#