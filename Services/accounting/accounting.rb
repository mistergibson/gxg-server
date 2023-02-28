# Accounting Support Toolbox
module GxG
    module Services
        module Accounting
            # ### Accounts
            class Account
                #
                private
                #
                def post_entry(amount=0, description="", is_debit=false, reference=nil)
                    result = false
                    new_entry = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.accounting.account.entry"})
                    if new_entry.is_a?(::GxG::Database::PersistedHash)
                        new_entry.get_reservation
                        if new_entry.write_reserved?
                            new_entry[:account_uuid] = @account.uuid.to_s
                            new_entry[:occurred_at] = DateTime.now
                            new_entry[:reference_uuid] = reference.to_s
                            new_entry[:description] = description.to_s
                            new_entry[:is_debit] = is_debit
                            new_entry[:amount] = amount
                            new_entry.save
                            new_entry.release_reservation
                            new_entry.deactivate
                            result = true
                        else
                            # Review : raise Exception here instead??
                            log_warning("Unable to secure a write-reservation on Account Entry #{new_entry.uuid.inspect} .")
                        end
                    end
                    result
                end
                #
                public
                # ### <account_profile>,<currency_profile>
                def initialize(account_profile=nil, currency_profile=nil)
                    unless account_profile.is_a?(::GxG::Database::PersistedHash)
                        raise ArgumentError, "Account Profile MUST be a GxG::Database::PersistedHash."
                    end
                    unless currency_profile.is_a?(::GxG::Database::PersistedHash)
                        raise ArgumentError, "Currency Profile MUST be a GxG::Database::PersistedHash."
                    end
                    #
                    @account = account_profile
                    @currency = currency_profile
                    #
                    self
                end
                #
                def uuid()
                    @account.uuid
                end
                #
                def post_credit(amount=0, description="", reference=nil)
                    result = false
                    unless amount.is_a?(::Integer)
                        raise ArgumentError, "You MUST provide the amount as an Integer."
                    end
                    unless description.is_a?(::String)
                        raise ArgumentError, "You MUST provide a description as a String."
                    end
                    @account.get_reservation
                    if @account.write_reserved?
                        if post_entry(amount, description, false, reference)
                            @account[:balance] += amount
                            @account[:balance_updated_at] = DateTime.now
                            @account.save
                            @account.release_reservation
                            result = true
                        else
                            # Review : raise Exception here instead??
                            log_warning("Unable to post Entry for Account #{@account.uuid.inspect} .")
                        end
                    else
                        # Review : raise Exception here instead??
                        log_warning("Unable to secure a write-reservation on Account #{@account.uuid.inspect} .")
                    end
                    result
                end
                #
                def post_debit(amount=0, description="", reference=nil)
                    result = false
                    unless amount.is_a?(::Integer)
                        raise ArgumentError, "You MUST provide the amount as an Integer."
                    end
                    unless description.is_a?(::String)
                        raise ArgumentError, "You MUST provide a description as a String."
                    end
                    @account.get_reservation
                    if @account.write_reserved?
                        if post_entry(amount, description, true, reference)
                            @account[:balance] -= amount
                            @account[:balance_updated_at] = DateTime.now
                            @account.save
                            @account.release_reservation
                            result = true
                        else
                            # Review : raise Exception here instead??
                            log_warning("Unable to post Entry for Account #{@account.uuid.inspect} .")
                        end
                    else
                        # Review : raise Exception here instead??
                        log_warning("Unable to secure a write-reservation on Account #{@account.uuid.inspect} .")
                    end
                    result
                end
                #
                def search_entries(criteria=nil, sort_with=:occurred_at)
                    # Example Criteria : {:occurred_at => {:between => (DateTIme.now..DateTime.now)}}
                    # Returns : unpersisted data (a copy) disconnected from Database records (Account Entries are largely immutable)
                    result = []
                    presorted = []
                    unless [:occurred_at, :amount].include?(sort_with)
                        sort_with = :occurred_at
                    end
                    properties = [{:account_uuid => {:equals => @account.uuid.to_s}}]
                    if criteria.is_a?(::Hash)
                        properties << criteria
                    else
                        if criteria.is_a?(::Array)
                            criteria.each do |the_property|
                                properties << the_property
                            end
                        end
                    end
                    ::GxG::DB[:roles][:data].search_database(GxG::DB[:administrator], {:properties => properties}).each do |entry|
                        presorted << entry.unpersist
                    end
                    result = presorted.sort_by {|entry| entry[(sort_with)]}
                    #
                    result
                end
                #
            end
            # ### Financial Books (Chart of Accounts)
            class Book
                #
                # ### Chart of Accounts Supports
                # Note : Busines Logic - for each Service or Product create a :revenue and :cost_of_goods_sold account. (assigned in each member's service/product/subscription record)
                def self.default_accounts_reference()
                    # Standard Accounts
                    accounts = {
                        :asset => {
                            :asset_operating_account => "Operating Account",
                            :asset_debitors => "Debitors",
                            :asset_petty_cash => "Petty Cash"
                        },
                        :receivable => {
                            :receivable_trade => "Trade",
                            :receivable_trade_notes => "Trade Notes",
                            :receivable_installment => "Installment Receivables",
                            :receivable_retainage_withheld => "Retainage Withheld",
                            :receivable_allowance_for_uncollectable => "Allowance for Uncollectable Accounts"
                        },
                        :inventory => {
                            :inventory_reserved => "Reserved",
                            :inventory_work_in_progress => "Work In Progress",
                            :inventory_finished_goods => "Finished Goods",
                            :inventory_unbilled_costs => "Unbilled Costs and Fees",
                            :inventory_obsolescence_reserve => "Reserve for Obsolescence"
                        },
                        :prepaid_expense => {
                            :prepaid_insurance => "insurance",
                            :prepaid_real_estate_taxes => "Real Estate Taxes",
                            :prepaid_repairs_and_maintenance => "Repairs and Maintenance",
                            :prepaid_rent => "Rent",
                            :prepaid_deposits => "Deposits"
                        },
                        :equipment => {
                            :equipment_buildings => "Buildings",
                            :equipment_machinery => "Machinery and Equipment",
                            :equipment_vehicles => "Vehicles",
                            :equipment_computers => "Computer Equipment",
                            :equipment_furniture => "Furniture and Fixtures",
                            :equipment_improvements => "Leasehold Improvements"
                        },
                        :depreciation => {
                            :depreciation_building => "Building Depreciation",
                            :depreciation_equipment => "Machinery and Equipment Depreciation",
                            :depreciation_vehicle => "Vehicle Depreciation",
                            :depreciation_computer_equipment => "Computer Equipment Depreciation",
                            :depreciation_furniture => "Furniture and Fixture Depreciation",
                            :depreciation_improvement => "Leasehold Improvement Depreciation"
                        },
                        :non_current_receivable => {
                            :ncr_notes_receivable => "Notes Receivable",
                            :ncr_installment_receivable => "Installment Receivables",
                            :ncr_retainage_withheld => "Retainage Withheld"
                        },
                        :intercompany_receivable => {
                            :intercompany_receivables => "Intercompany Receivables"
                        },
                        :non_current_asset => {
                            :nca_organization_costs => "Organization Costs",
                            :nca_patents_and_licenses => "Patents and Licenses",
                            :nca_intangible_assets => "Intangible Assets - Capitalized Software Costs"
                        },
                        :liability => {
                            :liability_general => "General Liabilities"
                        },
                        :payable => {
                            :payable_trade => "Trade Payable",
                            :payable_accrued => "Accrued Accounts Payable",
                            :payable_retained_withheld => "Payable Retained Withheld",
                            :payable_maturities_long_term_debt => "Current Maturities of Long-Term Debt",
                            :payable_bank_notes => "Bank Notes Payable",
                            :payable_construction_loans => "Construction Loans Payable"
                        },
                        :accrued_compensation => {
                            :accrued_payroll => "Payroll",
                            :accrued_commissions => "Commissions",
                            :accrued_fica => "FICA",
                            :accrued_unemployment_taxes => "Unemployment Taxes",
                            :accrued_workmen_compensation => "Workmen's Compensation",
                            :accrued_medical_benefits => "Medical Benefits",
                            :accrued_retirement_company_match => "401 K Company Match",
                            :accrued_esop_company_match => "ESOP Company Match",
                            :accrued_eot_company_match => "EOT Company Match",
                            :accrued_withheld_fica => "Withheld FICA",
                            :accrued_withheld_medical_benefits => "Withheld Medical Benefits",
                            :accrued_withheld_retirement_contributions => "401 K Employee Contributions",
                            :accrued_withheld_esop_contributions => "ESOP Employee Contributions",
                            :accrued_withheld_eot_contributions => "EOT Employee Contributions"
                        },
                        :accrued_expense => {
                            :accrued_expense_rent => "Rent",
                            :accrued_expense_interest => "Interest",
                            :accrued_expense_property_taxes => "Property Taxes",
                            :accrued_expense_warranty => "Warranty Expense"
                        },
                        :accrued_tax => {
                            :accrued_federal_income_taxes => "Federal Income Taxes",
                            :accrued_state_income_taxes => "State Income Taxes",
                            :accrued_county_income_taxes => "County Income Taxes",
                            :accrued_city_income_taxes => "Municipal Income Taxes",
                            :accrued_franchise_taxes => "Franchise Taxes",
                            :accrued_sales_taxes => "Sales Taxes",
                            :accrued_deferred_fit_current => "Deferred Federal Income Taxes Current",
                            :accrued_deferred_sit_current => "Deferred State Income Taxes Current",
                            :accrued_deferred_sales_taxes_current => "Deferred State Sales Taxes Current",
                            :accrued_deferred_cit_current => "Deferred County Income Taxes Current",
                            :accrued_deferred_mit_current => "Deferred Municipal Income Taxes Current"
                        },
                        :deferred_tax => {
                            :deferred_fit_non_current => "Deferred Federal Income Taxes Noncurrent",
                            :deferred_sit_non_current => "Deferred State Income Taxes Noncurrent",
                            :deferred_sales_tax_non_current => "Deferred State Sales Taxes Noncurrent",
                            :deferred_cit_non_current => "Deferred County Income Taxes Noncurrent",
                            :deferred_mit_non_current => "Deferred Municipal Income Taxes Noncurrent"
                        },
                        :long_term_debt => {
                            :long_term_notes_payable => "Long Term Debt Notes Payable",
                            :long_term_mortgages_payable => "Long Term Mortgages Payable",
                            :long_term_installment_notes_payable => "Long Term Installment Notes Payable"
                        },
                        :intercompany_payable => {
                            :intercompany_payables => "Intercompany Payables"
                        },
                        :non_current_liability => {
                            :non_current_liabilities => "Non Current Liabilities"
                        },
                        :owner_equity => {
                            :owner_common_stock => "Owner's Common Stock",
                            :owner_preferred_stock => "Owner's Preferred Stock",
                            :owner_paid_capital => "Owner Paid in Capital",
                            :owner_member_contributions => "Owner Member Contributions",
                            :owner_retained_earnings => "Owner's Retained Earnings"
                        },
                        :revenue => {
                            :revenue_interest_income => "Interest Income",
                            :revenue_other_income => "Other Income",
                            :revenue_finance_charge_income => "Finance Charge Income",
                            :revenue_sales_returns_allowances => "Sales Returns and Allowances",
                            :revenue_sales_discounts => "Sales Discounts"
                        },
                        :cost_of_goods_sold => {
                            :cogs_freight => "Freight",
                            :cogs_inventory_adjustment => "Inventory Adjustment",
                            :cogs_purchase_returns => "Purchase Returns and Allowances",
                            :cogs_reserved => "Reserved"
                        },
                        :operating_expense => {
                            :expense_advertising => "Advertising Expense",
                            :expense_amortization => "Amortization Expense",
                            :expense_vehicle => "Vehicle Expense",
                            :expense_bad_debt => "Bad Debt Expense",
                            :expense_bank_charges => "Bank Charges",
                            :expense_payment_clearing_charges => "Payment Clearing Charges",
                            :expense_cash_over_short => "Cash Over and Short",
                            :expense_commissions => "Commissions Expense",
                            :expense_depreciation => "Depreciation Expense",
                            :expense_employee_benefit_program => "Employee Benefit Program",
                            :expense_freight => "Freight Expense",
                            :expense_gifts => "Gifts Expense",
                            :expense_insurance_general => "Insurance - General",
                            :expense_interest => "Interest Expense",
                            :expense_professional_fees => "Professional Fees",
                            :expense_licenses => "License Expense",
                            :expense_maintenance => "Maintenance Expense",
                            :expense_meals_entertainment => "Meals and Entertainment Expense",
                            :expense_office => "Office Expense",
                            :expense_payroll => "Payroll Expense",
                            :expense_printing => "Printing Expense",
                            :expense_postage => "Postage Expense",
                            :expense_rent => "Rent",
                            :expense_repairs => "Repairs",
                            :expense_salaries => "Salaries",
                            :expense_supplies => "Supplies",
                            :expense_federal_income_tax => "Federal Income Tax",
                            :expense_state_income_tax => "State Income Tax",
                            :expense_county_income_tax => "County Income Tax",
                            :expense_city_income_tax => "Municipal Income Tax",
                            :expense_utilities => "Utilities Expense",
                            :expense_gain_loss_asset_sale => "Gain/Loss on Sale of Assets",
                            :expense_currency_conversion => "Currency Conversion Costs"
                        }
                    }
                    # Assets: 10000-19999
                    # Receivables: 20000-29999
                    # Inventories: 30000-39999
                    # PREPAID EXPENSES & OTHER CURRENT ASSETS: 40000-49999
                    # PROPERTY PLANT & EQUIPMENT: 50000-59999
                    # ACCUMULATED DEPRECIATION & AMORTIZATION: 60000-69999
                    # NON – CURRENT RECEIVABLES: 70000-79999
                    # INTERCOMPANY RECEIVABLES: 80000-89999
                    # OTHER NON-CURRENT ASSETS: 90000-99999
                    # LIABILITIES: 100000-109999
                    # PAYABLES: 110000-119999
                    # ACCRUED COMPENSATION & RELATED ITEMS: 120000-129999
                    # OTHER ACCRUED EXPENSES: 130000-139999
                    # ACCRUED TAXES: 140000-149999
                    # DEFERRED TAXES: 150000-159999
                    # LONG-TERM DEBT: 160000-169999
                    # INTERCOMPANY PAYABLES: 170000-179999
                    # OTHER NON CURRENT LIABILITIES: 180000-189999
                    # OWNERS EQUITIES: 190000-199999
                    # REVENUE: 200000-209999
                    # COST OF GOODS SOLD: 210000-219999
                    # OPERATING EXPENSES: 220000-229999
                    type_codes = {
                        :asset => (10000..19999),
                        :receivable => (20000..29999),
                        :inventory => (30000..39999),
                        :prepaid_expense => (40000..49999),
                        :equipment => (50000..59999),
                        :depreciation => (60000..69999),
                        :non_current_receivable => (70000..79999),
                        :intercompany_receivable => (80000..89999),
                        :non_current_asset => (90000..99999),
                        :liability => (100000..109999),
                        :payable => (110000..119999),
                        :accrued_compensation => (120000..129999),
                        :accrued_expense => (130000..139999),
                        :accrued_tax => (140000..149999),
                        :deferred_tax => (150000..159999),
                        :long_term_debt => (160000..169999),
                        :intercompany_payable => (170000..179999),
                        :non_current_liability => (180000..189999),
                        :owner_equity => (190000..199999),
                        :revenue => (200000..209999),
                        :cost_of_goods_sold => (210000..219999),
                        :operating_expense => (220000..229999)
                    }
                    #
                    type_mnemonics = {
                        :asset => "CASH",
                        :receivable => "AREC",
                        :inventory => "INV",
                        :prepaid_expense => "PREPAID",
                        :equipment => "PPE",
                        :depreciation => "ACCUM DEPR",
                        :non_current_receivable => "NCR",
                        :intercompany_receivable => "IREC",
                        :non_current_asset => "OTHER NCA",
                        :liability => "LIAB",
                        :payable => "APAY",
                        :accrued_compensation => "ACCRU COMP",
                        :accrued_expense => "ACCRU EXP",
                        :accrued_tax => "ACCRU TAX",
                        :deferred_tax => "DEFR TAX",
                        :long_term_debt => "LONG DEBT",
                        :intercompany_payable => "IPAY",
                        :non_current_liability => "NONCUR LIAB",
                        :owner_equity => "OWNER EQTY",
                        :revenue => "REV",
                        :cost_of_goods_sold => "COGS",
                        :operating_expense => "OEXP"
                    }
                    #
                    {:categories => type_codes, :mnemonics => type_mnemonics, :accounts => accounts}
                end
                #
                def self.next_account_code(exchange_uuid=nil, member_uuid=nil, category=nil, category_increment=10)
                    result = nil
                    if ::GxG::valid_uuid?(exchange_uuid) && ::GxG::valid_uuid?(member_uuid) && category.is_any?(::String, ::Symbol)
                        # determine new code number
                        valid_range = ::GxG::Services::Accounting::default_accounts_reference()[:categories][(category.to_s.to_sym)]
                        if valid_range
                            codes_in_use = []
                            accounts = []
                            ::GxG::DB[:roles][:data].search_database(::GxG::DB[:administrator], {:ufs => "org.gxg.accounting.account", :properties => [{:exchange_uuid => {:equals => exchange_uuid.to_s}},{:member_uuid => {:equals => member_uuid.to_s}}]}).each do |header|
                                if header
                                    record = ::GxG::DB[:roles][:data].retrieve_by_uuid(header[:uuid], ::GxG::DB[:administrator])
                                    if record
                                        accounts << record
                                    end
                                end
                            end
                            accounts.each do |the_account|
                                if valid_range.include?(the_account[:account_code])
                                    codes_in_use << the_account[:account_code]
                                end
                            end
                            unless category_increment.is_a?(::Integer)
                                category_increment = 10
                            end
                            if codes_in_use.size > 0
                                account_code = codes_in_use.max + category_increment
                            else
                                account_code = valid_range.first + category_increment
                            end
                            if account_code > valid_range.last
                                codes_in_use.each do |the_code|
                                    unless codes_in_use.include?(the_code + 1)
                                        account_code = the_code + 1
                                        break
                                    end
                                end
                            end
                            result = account_code
                        end
                    end
                    result
                end
                #
                def self.valid_account_moniker(account_code=0, account_name=nil)
                    # Review : Experimental : <the-string>.downcase.match(/\A[a-z0-9\s]+\Z/i).to_s.gsub(" ","_")
                    new_moniker = ""
                    mnemonic = "CASH"
                    reference_data = ::GxG::Services::Accounting::Book::default_accounts_reference()
                    reference_data[:categories].each_pair do |the_category, the_code_range|
                        if the_code_range.include?(account_code)
                            mnemonic = (reference_data[:mnemonics][(the_category)] || "CASH")
                            break
                        end
                    end
                    (mnemonic + "_" + account_name.to_s).downcase.gsub(" ","_").chars.each do |the_character|
                        the_valid_char = the_character.match(/^[a-z0-9\_]$/)
                        if the_valid_char
                            new_moniker << the_valid_char.to_s
                        end
                    end
                    new_moniker[0..255].to_sym
                end
                #
                def self.account_uuid_by_moniker(exchange_uuid=nil, member_uuid=nil, moniker=nil)
                    result = nil
                    if ::GxG::valid_uuid?(exchange_uuid) && ::GxG::valid_uuid?(member_uuid) && moniker.is_any(::String, ::Symbol)                        
                        found = ::GxG::DB[:roles][:data].search_database(::GxG::DB[:administrator], {:ufs => "org.gxg.accounting.account", :properties => [{:exchange_uuid => {:equals => exchange_uuid.to_s}},{:member_uuid => {:equals => member_uuid.to_s}},{:moniker => {:equals => moniker.to_s}}]}).first
                        #
                        if found
                            result = found[:uuid].to_s.to_sym
                        end
                    end
                    result
                end
                # ### Initialize
                def initialize(exchange_uuid=nil, member_uuid=nil)
                    unless ::GxG::valid_uuid?(exchange_uuid)
                        raise ArgumentError, "Exchange MUST be specified with a valid UUID."
                    end
                    unless ::GxG::valid_uuid?(member_uuid)
                        raise ArgumentError, "Exchange Member MUST be specified with a valid UUID."
                    end
                    #
                    @exchange = ::GxG::DB[:roles][:data].retrieve_by_uuid(exchange_uuid, GxG::DB[:administrator])
                    unless @exchange.is_a?(::GxG::Database::PersistedHash)
                        raise ArgumentError, "Exchange #{exchange_uuid.inspect} is missing: Could not retrieve its profile."
                    end
                    @member = ::GxG::DB[:roles][:data].retrieve_by_uuid(member_uuid, GxG::DB[:administrator])
                    unless @member.is_a?(::GxG::Database::PersistedHash)
                        raise ArgumentError, "Exchange Member #{member_uuid.inspect} is missing: Could not retrieve thier profile."
                    end
                    #
                    @accounts = {}
                    @thread_safety = ::Mutex.new
                    #
                    self
                end
                #
                def mount_account(the_account=nil)
                    if the_account.is_a?(::GxG::Services::Accounting::Account)
                        @thread_safety.synchronize {
                            @accounts[(the_account[:moniker].to_s.to_sym)] = the_account
                            @accounts = @accounts.sort_by {|the_moniker, account| account[:account_code]}.to_h
                        }
                    end
                end
                #
                def accounts_available()
                    @thread_safety.synchronize { @accounts.keys }
                end
                #
                def [](the_account_moniker=nil)
                    @thread_safety.synchronize { @accounts[(the_account_moniker.to_s.to_sym)] }
                end
                #
                def create_account(category=nil, moniker=nil, account_name=nil, reference_uuid=nil, category_increment=10, alternate_currency=nil)
                    result = false
                    # determine new code number
                    valid_range = ::GxG::Services::Accounting::default_accounts_reference()[:categories][(category.to_s.to_sym)]
                    if valid_range
                        codes_in_use = []
                        @thread_safety.synchronize {
                            @accounts.each_pair do |the_moniker, the_account|
                                if valid_range.include?(the_account[:account_code])
                                    codes_in_use << the_account[:account_code]
                                end
                            end
                        }
                        unless category_increment.is_a?(::Integer)
                            category_increment = 10
                        end
                        if codes_in_use.size > 0
                            account_code = codes_in_use.max + category_increment
                        else
                            account_code = valid_range.first + category_increment
                        end
                        if account_code > valid_range.last
                            codes_in_use.each do |the_code|
                                unless codes_in_use.include?(the_code + 1)
                                    account_code = the_code + 1
                                    break
                                end
                            end
                        end
                        if ::GxG::valid_uuid?(alternate_currency)
                            currency = alternate_currency.to_s.to_sym
                        else
                            currency = @exchange[:currency_uuid].to_s.to_sym
                        end
                        # Review : auto-set account monker based upon account_code and name:
                        unless moniker
                            moniker = ::GxG::Accounting::Book::valid_account_moniker(account_code, account_name).to_s.to_sym
                        end
                        new_account = ::GxG::Services::Accounting::create_account(moniker, @exchange.uuid, @member.uuid, currency, account_code, account_name, reference_uuid)
                        if new_account
                            new_account.post_credit(0,"Open Account")
                            @thread_safety.synchronize {
                                @accounts[(new_account[:moniker].to_s.to_sym)] = new_account
                                @accounts = @accounts.sort_by {|the_moniker, account| account[:account_code]}.to_h
                            }
                            result = true
                        else
                            log_warning("Could not create Account #{moniker.inspect} .")
                        end
                    else
                        log_warning("Category #{category.inspect} not found.")
                    end
                    #
                    result
                end
            end
            #
            def self.create_book(exchange_uuid=nil, member_uuid=nil)
                unless ::GxG::valid_uuid?(exchange_uuid)
                    raise ArgumentError, "Exchange MUST be specified with a valid UUID."
                end
                unless ::GxG::valid_uuid?(member_uuid)
                    raise ArgumentError, "Exchange Member MUST be specified with a valid UUID."
                end
                the_exchange = ::GxG::DB[:roles][:data].retrieve_by_uuid(exchange_uuid, GxG::DB[:administrator])
                unless the_exchange.is_a?(::GxG::Database::PersistedHash)
                    raise ArgumentError, "Exchange #{exchange_uuid.inspect} is missing: Could not retrieve its profile."
                end
                currency_uuid = the_exchange[:currency_uuid]
                the_member = ::GxG::DB[:roles][:data].retrieve_by_uuid(member_uuid, GxG::DB[:administrator])
                unless the_member.is_a?(::GxG::Database::PersistedHash)
                    raise ArgumentError, "Exchange Member #{member_uuid.inspect} is missing: Could not retrieve thier profile."
                end
                # Note : {:categories => type_codes, :mnemonics => type_mnemonics, :accounts => accounts}
                defaults = ::GxG::Services::Accounting::Book::default_accounts_reference()
                # Build Accounts
                cleanup_list = []
                prior_code = 0
                begin
                    defaults[:accounts].keys.each do |the_category|
                        prior_code = defaults[:categories][(the_category)].first
                        defaults[:accounts][(the_category)].each_pair do |the_account_moniker, the_account_title|
                            prior_code += 10
                            new_account = ::GxG::Services::Accounting::create_account(the_account_moniker, exchange_uuid, member_uuid, currency_uuid, prior_code, the_account_title)
                            if new_account
                                cleanup_list << new_account
                            end
                        end
                    end
                rescue Exception => the_error
                    # delete orphaned accounts
                    while cleanup_list.size > 0 do
                        ::GxG::Services::Accounting::delete_account(cleanup_list.shift.uuid)
                    end
                    ::GxG::DB[:roles][:data].empty_trash()
                    raise the_error
                end
                #
                cleanup_list.each do |the_account|
                    the_account.post_credit(0, "Open Account")
                end
                true
            end
            #
            def self.load_book(exchange_uuid=nil, member_uuid=nil)
                result = nil
                unless ::GxG::valid_uuid?(exchange_uuid)
                    raise ArgumentError, "Exchange MUST be specified with a valid UUID."
                end
                unless ::GxG::valid_uuid?(member_uuid)
                    raise ArgumentError, "Exchange Member MUST be specified with a valid UUID."
                end
                # create chart of accounts if missing, otherwise load manifest of accounts.
                search_criteria = {:ufs => "org.gxg.accounting.account", :properties => []}
                search_criteria[:properties] << {:exchange_uuid => {:equals => exchange_uuid.to_s}}
                search_criteria[:properties] << {:member_uuid => {:equals => member_uuid.to_s}}
                accounts_manifest =  ::GxG::DB[:roles][:data].search_database(GxG::DB[:administrator], search_criteria)
                unless accounts_manifest.size > 0
                    if GxG::Services::Accounting::Book::create_book(exchange_uuid, member_uuid)
                        accounts_manifest =  ::GxG::DB[:roles][:data].search_database(GxG::DB[:administrator], search_criteria)
                    else
                        accounts_manifest = []
                    end
                end
                if accounts_manifest.size > 0
                    # mount accounts in book
                    begin
                        the_book = ::GxG::Services::Accounting::Book.new(exchange_uuid, member_uuid)
                        if the_book
                            #
                            accounts = []
                            accounts_manifest.each do |the_header|
                                the_account = ::GxG::Services::Accounting::load_account(the_header[:uuid])
                                if the_account
                                    accounts << the_account
                                end
                            end
                            accounts = accounts.sort_by {|entry| entry[:account_code]}
                            accounts.each do |the_account|
                                the_book.mount_account(the_account)
                            end
                            #
                            if accounts.size > 0
                                result = the_book
                            end
                        end
                    rescue Exception => the_error
                        log_error({:error => the_error, :parameters => {:exchange => exchange_uuid, :member => member_uuid}})
                    end
                else
                    log_warning("Unable to load or create Accounts while opening a Chart of Accounts for Member #{member_uuid.inspect} of Exchange #{exchange_uuid.inspect} .")
                end
                result
            end
            #
            def self.delete_book(exchange_uuid=nil, member_uuid=nil)
                search_criteria = {:ufs => "org.gxg.accounting.account", :properties => []}
                search_criteria[:properties] << {:exchange_uuid => {:equals => exchange_uuid.to_s}}
                search_criteria[:properties] << {:member_uuid => {:equals => member_uuid.to_s}}
                accounts_manifest =  ::GxG::DB[:roles][:data].search_database(GxG::DB[:administrator], search_criteria)
                accounts_manifest.each do |the_header|
                    entries_manifest = ::GxG::DB[:roles][:data].search_database(GxG::DB[:administrator], {:ufs => "org.gxg.accounting.account.entry", :properties => [{:account_uuid => {:equals => the_header[:uuid].to_s}}]})
                    entries_manifest.each do |the_entry_header|
                        ::GxG::DB[:roles][:data].destroy_by_uuid(GxG::DB[:administrator], the_entry_header[:uuid])
                    end
                    ::GxG::DB[:roles][:data].destroy_by_uuid(GxG::DB[:administrator], the_header[:uuid])
                end
                true
            end
            #
            def self.create_account(moniker=nil, exchange_uuid=nil, member_uuid=nil, currency_uuid=nil, account_code=nil, account_name=nil, reference_uuid=nil)
                result = nil
                unless moniker.is_any?(::String, ::Symbol)
                    raise ArgumentError, "Account Moniker is invalid, please provide a String or Symbol - not: #{moniker.inspect} ."
                end
                unless ::GxG::valid_uuid?(exchange_uuid)
                    raise ArgumentError, "Exchange UUID is invalid: #{exchange_uuid.inspect} ."
                end
                unless ::GxG::valid_uuid?(member_uuid)
                    raise ArgumentError, "Exchange Member UUID is invalid: #{member_uuid.inspect} ."
                end
                unless ::GxG::valid_uuid?(currency_uuid)
                    raise ArgumentError, "Currenty UUID is invalid: #{currency_uuid.inspect} ."
                end
                currency_profile = ::GxG::DB[:roles][:reference].retrieve_by_uuid(currency_uuid, GxG::DB[:administrator])
                unless currency_profile.is_a?(::GxG::Database::PersistedHash)
                    raise ArgumentError, "Currenty #{currency_uuid.inspect} is missing: Could not retrieve its profile."
                end
                unless account_code.is_a?(::Numeric)
                    raise ArgumentError, "Account Code #{account_code.inspect} is invalid: Needs to be a Numeric."
                end
                unless account_name.is_a?(::String)
                    raise ArgumentError, "Account Name #{account_name.inspect} is invalid: Needs to be a String."
                end
                # ### ensure account moniker is unique for this exchange and member
                unique_criteria = {:ufs => "org.gxg.accounting.account", :properties => []}
                unique_criteria[:properties] << {:moniker => {:equals => moniker.to_s}}
                unique_criteria[:properties] << {:exchange_uuid => {:equals => exchange_uuid.to_s}}
                unique_criteria[:properties] << {:member_uuid => {:equals => member_uuid.to_s}}
                if ::GxG::DB[:roles][:data].search_database(GxG::DB[:administrator], unique_criteria).size > 0
                    raise ArgumentError, "Account Moniker is NOT UNIQUE for this Exchange & Member, please provide a UNIQUE one - not: #{moniker.inspect} ."
                end
                # ### create db record
                new_account = ::GxG::DB[:roles][:data].new_structure_from_format(GxG::DB[:administrator],{:ufs => "org.gxg.accounting.account"})
                if new_account.is_a?(::GxG::Database::PersistedHash)
                    new_account.get_reservation
                    new_account[:moniker] = moniker.to_s
                    new_account[:exchange_uuid] = exchange_uuid.to_s
                    new_account[:member_uuid] = member_uuid.to_s
                    if ::GxG::valid_uuid?(reference_uuid)
                        new_account[:reference_uuid] = reference_uuid.to_s
                    end
                    new_account[:currency_uuid] = currency_uuid.to_s
                    new_account[:account_code] = account_code.to_i
                    new_account[:account_name] = account_name.to_s
                    new_account[:balance_updated_at] = DateTime.now
                    new_account.title = account_name.to_s
                    new_account.save
                    new_account.release_reservation
                    # ### mount db record
                    result = ::GxG::Services::Accounting::Account.new(new_account, currency_profile)
                else
                    raise Exception, "Could not create the account: #{account_name} ."
                end
                #
                result
            end
            #
            def self.load_account(account_uuid=nil)
                result = nil
                if ::GxG::valid_uuid?(account_uuid)
                    account = ::GxG::DB[:roles][:data].retrieve_by_uuid(account_uuid, GxG::DB[:administrator])
                    if account.is_a?(::GxG::Database::PersistedHash)
                        currency_uuid = account[:currency_uuid].to_s.to_sym
                        currency_profile = ::GxG::DB[:roles][:reference].retrieve_by_uuid(currency_uuid, GxG::DB[:administrator])
                        if currency_profile.is_a?(::GxG::Database::PersistedHash)
                            result = ::GxG::Services::Accounting::Account.new(account, currency_profile)
                        end
                    end
                end
                result
            end
            #
            def self.delete_account(account_uuid=nil)
                result = false
                if ::GxG::valid_uuid?(account_uuid)
                    account = ::GxG::DB[:roles][:data].retrieve_by_uuid(account_uuid, GxG::DB[:administrator])
                    if account.is_a?(::GxG::Database::PersistedHash)
                        account.get_reservation
                        # Review : allow for branch if cannot secure write reservation
                        if account.write_reserved?()
                            remove_list = []
                            available_list = ::GxG::DB[:roles][:data].search_database(GxG::DB[:administrator], {:properties => [{:account_uuid => {:equals => account.uuid.to_s}}]})
                            available_list.each do |header|
                                account_entry =  ::GxG::DB[:roles][:data].retrieve_by_uuid(header[:uuid], GxG::DB[:administrator])
                                if account_entry
                                    account_entry.get_reservation
                                    if account_entry.write_reserved?
                                        remove_list << account_entry
                                    else
                                        remove_list = []
                                        break
                                    end
                                end
                            end
                            #
                            if available_list.size > 0
                                if remove_list.size > 0
                                    remove_list.each do |entry_object|
                                        entry_object.destroy
                                    end
                                    #
                                    account.destroy
                                    result = true
                                else
                                    raise Exception, "Cannot secure a write-reservation on an Account Entry (aborting)."
                                end
                            else
                                account.destroy
                                result = true
                            end
                        else
                            raise Exception, "Cannot secure a write-reservation on Account #{account.uuid.to_s}."
                        end
                    end
                end
                result
            end
            #
        end
    end
end
# ### Reference
# # Chart of Accounts - Account Profile
# format_manifest[:account] = {
#     :uuid => :"b69640db-5b14-453b-87b5-42279a8eba10",
#     :version => 0.0,
#     :ufs => "org.gxg.accounting.account",
#     :title => "Account",
#     :mime_types => [],
#     :content => {
#         :exchange_uuid => "",
#         :member_uuid => "",
#         :currency_uuid => "",
#         :account_code => 0,
#         :account_name => "",
#         :balance_updated_at => nil,
#         :balance => 0
#     }
# }
# # Account Entry
# format_manifest[:account_entry] = {
#     :uuid => :"95d7ef37-cfbf-49d6-8f42-07c956d02518",
#     :version => 0.0,
#     :ufs => "org.gxg.accounting.account.entry",
#     :title => "Account Entry",
#     :mime_types => [],
#     :content => {
#         :account_uuid => "",
#         :occurred_at => nil,
#         :description => "",
#         :is_debit => false,
#         :amount => 0
#     }
# }
# ### Setup
accounting_service = ::GxG::Services::Service.new(:accounting)
# ### Define Public Command Interface:
accounting_service.on(:start, {:description => "Accounting Service Start", :usage => "{ :start => nil }"}) do
  ::GxG::SERVICES[:accounting].start
  ::GxG::SERVICES[:accounting].publish_api
end
accounting_service.on(:stop, {:description => "Accounting Service Stop", :usage => "{ :stop => nil }"}) do
  ::GxG::SERVICES[:accounting].stop
  ::GxG::SERVICES[:accounting].unpublish_api
end
accounting_service.on(:restart, {:description => "Accounting Service Restart", :usage => "{ :restart => nil }"}) do
  ::GxG::SERVICES[:accounting].restart
end
accounting_service.on(:pause, {:description => "Accounting Service Pause", :usage => "{ :pause => nil }"}) do
  ::GxG::SERVICES[:accounting].pause
  ::GxG::SERVICES[:accounting].unpublish_api
end
accounting_service.on(:resume, {:description => "Accounting Service Resume", :usage => "{ :resume => nil }"}) do
  ::GxG::SERVICES[:accounting].resume
  ::GxG::SERVICES[:accounting].publish_api
end
# ### Define Internal Service Control Events:
accounting_service.on(:at_start, {:description => "Accounting Startup", :usage => "{ :at_start => (service-object) }"}) do |service, credential|
    {:result => true}
end
accounting_service.on(:open_book, {:description => "Open Account Book", :usage => "{ :open_book => {:exchange_uuid => <UUID>, :member_uuid => <UUID>} }"}) do |details, credential|
    begin
        unless ::GxG::valid_uuid?(details[:exchange_uuid])
            raise ArgumentError, "You MUST provide a valid UUID specifying the Exchange in question."
        end
        unless ::GxG::valid_uuid?(details[:member_uuid])
            raise ArgumentError, "You MUST provide a valid UUID specifying the Exchange Member in question."
        end
        unless ::GxG::SERVICES[:accounting]
            raise Exception, "Accounting Service not yet started."
        end
        #
        the_book = ::GxG::Services::Accounting::load_book(details[:exchange_uuid].to_s.to_sym, details[:member_uuid].to_s.to_sym)
        if the_book
            ::GxG::SERVICES[:accounting][(details[:member_uuid].to_s.to_sym)] = the_book
            {:result => true}
        else
            {:result => nil, :error => "Could not load the book for Exchange Member #{details[:member_uuid].to_s.to_sym.inspect}."}
        end
        #
    rescue Exception => the_error
        {:result => nil, :error => the_error.to_s}
    end
end
# ### Service Installation
unless ::GxG::Services::service_available?(:accounting)
    ::GxG::Services::install_service(:accounting)
    ::GxG::Services::enable_service(:accounting)
end
#