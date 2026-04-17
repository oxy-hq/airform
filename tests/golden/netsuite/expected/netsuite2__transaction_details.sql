with  __dbt__cte__int_netsuite2__transaction_lines as (


with transaction_lines as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__transaction_lines"
),

transaction_accounting_lines as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__transaction_accounting_lines"
),



joined as (

    select 
        transaction_lines.*,
        transaction_accounting_lines.account_id,

        
        
        transaction_accounting_lines.exchange_rate,
        transaction_accounting_lines.amount,
        transaction_accounting_lines.credit_amount,
        transaction_accounting_lines.debit_amount,
        transaction_accounting_lines.paid_amount,
        transaction_accounting_lines.unpaid_amount,
        transaction_accounting_lines.is_posting

    from transaction_lines
    left join transaction_accounting_lines
        on transaction_lines.transaction_line_id = transaction_accounting_lines.transaction_line_id
        and transaction_lines.transaction_id = transaction_accounting_lines.transaction_id
        and transaction_lines.source_relation = transaction_accounting_lines.source_relation
        
    

)

select *
from joined
),  __dbt__cte__int_netsuite2__tran_lines_w_accounting_period as (


with transactions as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__transactions"
), 

transaction_lines as (
    select * 
    from __dbt__cte__int_netsuite2__transaction_lines
),

transaction_lines_w_accounting_period as ( -- transaction line totals, by accounts, accounting period and subsidiary
  select
    transaction_lines.source_relation,
    transaction_lines.transaction_id,
    transaction_lines.transaction_line_id,
    transaction_lines.subsidiary_id,
    transaction_lines.account_id,

    
    
    transactions.accounting_period_id as transaction_accounting_period_id,
    coalesce(transaction_lines.amount, 0) as unconverted_amount,
    transactions._fivetran_synced_date
  from transaction_lines

  join transactions 
    on transactions.transaction_id = transaction_lines.transaction_id
    and transactions.source_relation = transaction_lines.source_relation

  where lower(transactions.transaction_type) != 'revenue arrangement'
    and transaction_lines.is_posting
)

select * 
from transaction_lines_w_accounting_period
),  __dbt__cte__int_netsuite2__accounts as (


with accounts as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__accounts"
),

account_types as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__account_types"
),

joined as (

    select
        accounts.*,
        account_types.type_name,
        account_types.is_balancesheet,
        account_types.is_leftside
    from accounts
    left join account_types
        on accounts.account_type_id = account_types.account_type_id
        and accounts.source_relation = account_types.source_relation
)

select *
from joined
),  __dbt__cte__int_netsuite2__acctxperiod_exchange_rate_map as (


with accounts as (
    select * 
    from __dbt__cte__int_netsuite2__accounts
), 



subsidiaries as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__subsidiaries"
),

consolidated_exchange_rates as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__consolidated_exchange_rates"
),

currencies as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__currencies"
),


primary_subsidiaries as (
  select 
    subsidiary_id,
    source_relation
  from subsidiaries where parent_id is null
),


period_exchange_rate_map as ( -- exchange rates used, by accounting period, to convert to parent subsidiary
  select
    consolidated_exchange_rates.source_relation,
    consolidated_exchange_rates.accounting_period_id,

    

    consolidated_exchange_rates.average_rate,
    consolidated_exchange_rates.current_rate,
    consolidated_exchange_rates.historical_rate,
    consolidated_exchange_rates.from_subsidiary_id,
    consolidated_exchange_rates.to_subsidiary_id,
    to_subsidiaries.name as to_subsidiary_name,
    currencies.symbol as to_subsidiary_currency_symbol
  from consolidated_exchange_rates
  
  left join subsidiaries as to_subsidiaries
    on consolidated_exchange_rates.to_subsidiary_id = to_subsidiaries.subsidiary_id
    and consolidated_exchange_rates.source_relation = to_subsidiaries.source_relation

  left join currencies
    on currencies.currency_id = to_subsidiaries.currency_id
    and currencies.source_relation = to_subsidiaries.source_relation

  
  join primary_subsidiaries
    on consolidated_exchange_rates.to_subsidiary_id = primary_subsidiaries.subsidiary_id
    and consolidated_exchange_rates.source_relation = primary_subsidiaries.source_relation
  
), 

accountxperiod_exchange_rate_map as ( -- account table with exchange rate details by accounting period
  select
    accounts.source_relation,
    period_exchange_rate_map.accounting_period_id,

    
    
    period_exchange_rate_map.from_subsidiary_id,
    period_exchange_rate_map.to_subsidiary_id,
    period_exchange_rate_map.to_subsidiary_name,
    period_exchange_rate_map.to_subsidiary_currency_symbol,
    accounts.account_id,
    case 
      when lower(accounts.general_rate_type) = 'historical' then period_exchange_rate_map.historical_rate
      when lower(accounts.general_rate_type) = 'current' then period_exchange_rate_map.current_rate
      when lower(accounts.general_rate_type) = 'average' then period_exchange_rate_map.average_rate
      else null
        end as exchange_rate
  from accounts
  
  join period_exchange_rate_map
    on accounts.source_relation = period_exchange_rate_map.source_relation
)

select *
from accountxperiod_exchange_rate_map
),  __dbt__cte__int_netsuite2__accounting_periods as (


with accounting_periods as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__accounting_periods"
),

accounting_period_fiscal_calendars as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__accounting_period_fiscal_cal"
),



final as (

    select
        accounting_periods.*,
        accounting_period_fiscal_calendars.fiscal_calendar_id,
        accounting_period_fiscal_calendars.accounting_period_full_name,
        cast(date_trunc('year', accounting_periods.starting_at) as date) as fiscal_year_trunc
    from accounting_periods

    left join accounting_period_fiscal_calendars
        on accounting_periods.accounting_period_id = accounting_period_fiscal_calendars.accounting_period_id
        and accounting_periods.source_relation = accounting_period_fiscal_calendars.source_relation
)


select *
from final
),  __dbt__cte__int_netsuite2__tran_and_reporting_periods as (


with accounting_periods as (
    select * 
    from __dbt__cte__int_netsuite2__accounting_periods
),

subsidiaries as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__subsidiaries"
),

primary_subsidiary_calendar as (
    select 
      fiscal_calendar_id, 
      source_relation 
    from subsidiaries 
    where parent_id is null
),

transaction_and_reporting_periods as ( 
  select
    base.source_relation,
    base.accounting_period_id as accounting_period_id,
    multiplier.accounting_period_id as reporting_accounting_period_id
  from accounting_periods as base

  join accounting_periods as multiplier
    on multiplier.starting_at >= base.starting_at
      and multiplier.is_quarter = base.is_quarter
      and multiplier.is_year = base.is_year -- this was year_0 in netsuite1
      and multiplier.fiscal_calendar_id = base.fiscal_calendar_id
      and cast(multiplier.starting_at as timestamp) <= now()
      and multiplier.source_relation = base.source_relation 

  join primary_subsidiary_calendar
    on base.fiscal_calendar_id = primary_subsidiary_calendar.fiscal_calendar_id
    and base.source_relation = primary_subsidiary_calendar.source_relation

  where not base.is_quarter
    and not base.is_year
)

select * 
from transaction_and_reporting_periods
),  __dbt__cte__int_netsuite2__tran_with_converted_amounts as (


with transaction_lines_w_accounting_period as (
  select * 
  from __dbt__cte__int_netsuite2__tran_lines_w_accounting_period
), 


accountxperiod_exchange_rate_map as (
  select * 
  from __dbt__cte__int_netsuite2__acctxperiod_exchange_rate_map
), 


transaction_and_reporting_periods as (
  select * 
  from __dbt__cte__int_netsuite2__tran_and_reporting_periods
), 

accounts as (
  select * 
  from __dbt__cte__int_netsuite2__accounts
),

transactions_in_every_calculation_period_w_exchange_rates as (
  select
    transaction_lines_w_accounting_period.*,
    transaction_and_reporting_periods.reporting_accounting_period_id
    
    
    , exchange_reporting_period.exchange_rate as exchange_rate_reporting_period
    , exchange_transaction_period.exchange_rate as exchange_rate_transaction_period
    

    

  from transaction_lines_w_accounting_period

  left join transaction_and_reporting_periods
    on transaction_and_reporting_periods.accounting_period_id = transaction_lines_w_accounting_period.transaction_accounting_period_id
      and transaction_and_reporting_periods.source_relation = transaction_lines_w_accounting_period.source_relation 

  
  left join accountxperiod_exchange_rate_map as exchange_reporting_period
    on exchange_reporting_period.accounting_period_id = transaction_and_reporting_periods.reporting_accounting_period_id
      and exchange_reporting_period.source_relation = transaction_and_reporting_periods.source_relation

      and exchange_reporting_period.account_id = transaction_lines_w_accounting_period.account_id
      and exchange_reporting_period.from_subsidiary_id = transaction_lines_w_accounting_period.subsidiary_id
      and exchange_reporting_period.source_relation = transaction_lines_w_accounting_period.source_relation

      
      
  left join accountxperiod_exchange_rate_map as exchange_transaction_period
    on exchange_transaction_period.accounting_period_id = transaction_and_reporting_periods.accounting_period_id
      and exchange_transaction_period.source_relation = transaction_and_reporting_periods.source_relation

      and exchange_transaction_period.account_id = transaction_lines_w_accounting_period.account_id
      and exchange_transaction_period.from_subsidiary_id = transaction_lines_w_accounting_period.subsidiary_id
      and exchange_transaction_period.source_relation = transaction_lines_w_accounting_period.source_relation
      
      

      
  
), 

transactions_with_converted_amounts as (
  select
    transactions_in_every_calculation_period_w_exchange_rates.*,
    
    unconverted_amount * exchange_rate_transaction_period as converted_amount_using_transaction_accounting_period,
    unconverted_amount * exchange_rate_reporting_period as converted_amount_using_reporting_month,
    
    case
      when lower(accounts.account_type_id) in ('income','othincome','expense','othexpense','cogs') then true
      else false 
        end as is_income_statement,
    case
      when lower(accounts.account_type_id) in ('acctrec', 'bank', 'deferexpense', 'fixedasset', 'othasset', 'othcurrasset', 'unbilledrec') then 'Asset'
      when lower(accounts.account_type_id) in ('cogs', 'expense', 'othexpense') then 'Expense'
      when lower(accounts.account_type_id) in ('income', 'othincome') then 'Income'
      when lower(accounts.account_type_id) in ('acctpay', 'credcard', 'deferrevenue', 'longtermliab', 'othcurrliab') then 'Liability'
      when lower(accounts.account_type_id) in ('equity', 'retained_earnings', 'net_income') then 'Equity'
      when lower(accounts.account_type_id) in ('nonposting', 'stat') then 'Other'
      else null 
        end as account_category
  from transactions_in_every_calculation_period_w_exchange_rates

  left join accounts
    on accounts.account_id = transactions_in_every_calculation_period_w_exchange_rates.account_id
    and accounts.source_relation = transactions_in_every_calculation_period_w_exchange_rates.source_relation 
),

surrogate_key as ( 
   -- add 'source_relation' when combining with union schema
  
  

  select 
    *,
    md5(cast(coalesce(cast(transaction_line_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(transaction_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(account_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(reporting_accounting_period_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as tran_with_converted_amounts_id
  from transactions_with_converted_amounts
)

select * 
from surrogate_key
),  __dbt__cte__int_netsuite2__customers as (


with customers as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__customers"
),

entity_address as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__entity_address"
),

joined as (

    select
        customers.*,
        entity_address.city,
        entity_address.state,
        entity_address.zipcode,
        entity_address.country
    from customers
    left join entity_address
        on coalesce(customers.default_billing_address_id, customers.default_shipping_address_id) = entity_address.nkey
        and customers.source_relation = entity_address.source_relation
)

select *
from joined
),  __dbt__cte__int_netsuite2__locations as (


with locations as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__locations"
),

location_main_address as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__location_main_address"
),

joined as (

    select
        locations.*,
        location_main_address.city,
        location_main_address.state,
        location_main_address.zipcode,
        location_main_address.country
    from locations
    left join location_main_address
        on locations.main_address_id = location_main_address.nkey
        and locations.source_relation = location_main_address.source_relation
)

select *
from joined
), transaction_lines as (
    select 
      *,
      cast(_fivetran_synced as date) as transaction_line_fivetran_synced_date

    from __dbt__cte__int_netsuite2__transaction_lines

    
),

transactions_with_converted_amounts as (
    select * 
    from __dbt__cte__int_netsuite2__tran_with_converted_amounts
),

accounts as (
    select * 
    from __dbt__cte__int_netsuite2__accounts
),

accounting_periods as (
    select * 
    from __dbt__cte__int_netsuite2__accounting_periods
),

subsidiaries as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__subsidiaries"
),

transactions as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__transactions"
),

customers as (
    select * 
    from __dbt__cte__int_netsuite2__customers
),

items as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__items"
),

locations as (
    select * 
    from __dbt__cte__int_netsuite2__locations
),

nexuses as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__nexuses"
),

vendors as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__vendors"
),


vendor_categories as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__vendor_categories"
),


departments as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__departments"
),

currencies as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__currencies"
),

classes as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__classes"
),

primary_subsidiary_calendar as (
    select 
      fiscal_calendar_id, 
      source_relation 
    from subsidiaries 
    where parent_id is null
),

transaction_details as (
  select

    

    

    transaction_lines.source_relation,
    transaction_lines.transaction_line_id,
    transaction_lines.memo as transaction_memo,
    not transaction_lines.is_posting as is_transaction_non_posting,
    transaction_lines.is_main_line,
    transaction_lines.is_tax_line,
    transaction_lines.is_closed,
    transactions.transaction_id,
    transactions.status as transaction_status,
    transactions.transaction_date,
    transactions.due_date_at as transaction_due_date,
    transactions.transaction_type as transaction_type,
    transactions.nexus_id,
    nexuses.country as nexus_country,
    nexuses.state as nexus_state,
    nexuses.tax_agency_id,
    vendors__nexuses.alt_name as tax_agency_alt_name,
    transactions.is_nexus_override,
    transactions.is_tax_details_override,
    transactions.tax_point_date,
    transactions.is_tax_point_date_override,
    transaction_lines.transaction_line_fivetran_synced_date,
    transactions.transaction_number,
    coalesce(transaction_lines.entity_id, transactions.entity_id) as entity_id,
    transactions.is_intercompany_adjustment as is_transaction_intercompany_adjustment,
    transactions.is_reversal,
    transactions.reversal_transaction_id,
    transactions.reversal_date,
    transactions.is_reversal_defer

    --The below script allows for transactions table pass through columns.
    
    





    --The below script allows for transaction lines table pass through columns.
    
    



,

    accounting_periods.ending_at as accounting_period_ending,
    accounting_periods.accounting_period_full_name,
    accounting_periods.name as accounting_period_name,
    accounting_periods.accounting_period_id as accounting_period_id,
    accounting_periods.is_adjustment as is_accounting_period_adjustment,
    accounting_periods.is_closed as is_accounting_period_closed,
    accounts.name as account_name,
    accounts.display_name as account_display_name,
    accounts.type_name as account_type_name,
    accounts.account_type_id,
    accounts.account_id as account_id,
    accounts.account_number

    --The below script allows for accounts table pass through columns.
    



,

    accounts.is_leftside as is_account_leftside,
    lower(accounts.account_type_id) = 'acctpay' as is_accounts_payable,
    lower(accounts.account_type_id) = 'acctrec' as is_accounts_receivable,
    accounts.is_eliminate as is_account_intercompany,
    transaction_lines.is_eliminate,
    coalesce(parent_account.account_id, accounts.account_id) as parent_account_id,
    coalesce(parent_account.name, accounts.name) as parent_account_name,
    lower(accounts.account_type_id) in ('expense', 'othexpense', 'deferexpense') as is_expense_account,
    lower(accounts.account_type_id) in ('income', 'othincome') as is_income_account,
    case 
      when lower(transactions.transaction_type) in ('custinvc', 'custcred') then customers__transactions.customer_id
      else customers__transaction_lines.customer_id
        end as customer_id,
    case 
      when lower(transactions.transaction_type) in ('custinvc', 'custcred') then customers__transactions.alt_name
      else customers__transaction_lines.alt_name
        end as customer_alt_name,
    case 
      when lower(transactions.transaction_type) in ('custinvc', 'custcred') then customers__transactions.company_name
      else customers__transaction_lines.company_name
        end as company_name,
    case 
      when lower(transactions.transaction_type) in ('custinvc', 'custcred') then customers__transactions.city
      else customers__transaction_lines.city
        end as customer_city,
    case 
      when lower(transactions.transaction_type) in ('custinvc', 'custcred') then customers__transactions.state
      else customers__transaction_lines.state
        end as customer_state,
    case 
      when lower(transactions.transaction_type) in ('custinvc', 'custcred') then customers__transactions.zipcode
      else customers__transaction_lines.zipcode
        end as customer_zipcode,
    case 
      when lower(transactions.transaction_type) in ('custinvc', 'custcred') then customers__transactions.country
      else customers__transaction_lines.country
        end as customer_country,
    case 
      when lower(transactions.transaction_type) in ('custinvc', 'custcred') then customers__transactions.date_first_order_at
      else customers__transaction_lines.date_first_order_at
        end as customer_date_first_order,
    case 
      when lower(transactions.transaction_type) in ('custinvc', 'custcred') then customers__transactions.customer_external_id
      else customers__transaction_lines.customer_external_id
        end as customer_external_id,
    classes.class_id,
    classes.full_name as class_full_name,
    transaction_lines.item_id,
    items.name as item_name,
    items.type_name as item_type_name,
    items.sales_description,
    locations.location_id,
    locations.name as location_name,
    locations.city as location_city,
    locations.country as location_country

    -- The below script allows for locations table pass through columns.
    



,

    
    case 
      when lower(transactions.transaction_type) in ('vendbill', 'vendcred') then vendor_categories__transactions.vendor_category_id
      else vendor_categories__transaction_lines.vendor_category_id
        end as vendor_category_id,
    case 
      when lower(transactions.transaction_type) in ('vendbill', 'vendcred') then vendor_categories__transactions.name
      else vendor_categories__transaction_lines.name
        end as vendor_category_name,
    

    case 
      when lower(transactions.transaction_type) in ('vendbill', 'vendcred') then vendors__transactions.vendor_id
      else vendors__transaction_lines.vendor_id
        end as vendor_id,
    case 
      when lower(transactions.transaction_type) in ('vendbill', 'vendcred') then vendors__transactions.alt_name
      else vendors__transaction_lines.alt_name
        end as vendor_alt_name,
    case 
      when lower(transactions.transaction_type) in ('vendbill', 'vendcred') then vendors__transactions.company_name
      else vendors__transaction_lines.company_name
        end as vendor_name,
    case 
      when lower(transactions.transaction_type) in ('vendbill', 'vendcred') then vendors__transactions.create_date_at
      else vendors__transaction_lines.create_date_at
        end as vendor_create_date,
    currencies.currency_id,
    currencies.name as currency_name,
    currencies.symbol as currency_symbol,
    transaction_lines.department_id,
    transaction_lines.exchange_rate,
    departments.full_name as department_full_name,
    departments.name as department_name

    --The below script allows for departments table pass through columns.
    



,

    subsidiaries.subsidiary_id,
    subsidiaries.full_name as subsidiary_full_name,
    subsidiaries.name as subsidiary_name,
    subsidiaries_currencies.symbol as subsidiary_currency_symbol

    --The below script allows for subsidiaries table pass through columns.
    



,

    case
      when lower(accounts.account_type_id) in ('income', 'othincome') then -transactions_with_converted_amounts.converted_amount_using_transaction_accounting_period
      else transactions_with_converted_amounts.converted_amount_using_transaction_accounting_period
        end as converted_amount,
    case
      when lower(accounts.account_type_id) in ('income', 'othincome') then -transaction_lines.amount
      else transaction_lines.amount
        end as transaction_amount,
    case
      when lower(accounts.account_type_id) in ('income', 'othincome') then -transaction_lines.netamount
      else transaction_lines.netamount
        end as transaction_line_amount,

    transactions_with_converted_amounts.converted_amount_using_transaction_accounting_period as converted_amount_raw,
    transaction_lines.amount as transaction_amount_raw,
    transaction_lines.netamount as transaction_line_amount_raw
  from transaction_lines

  join transactions
    on transactions.transaction_id = transaction_lines.transaction_id
    and transactions.source_relation = transaction_lines.source_relation

  left join transactions_with_converted_amounts
    on transactions_with_converted_amounts.transaction_line_id = transaction_lines.transaction_line_id
      and transactions_with_converted_amounts.transaction_id = transaction_lines.transaction_id
      and transactions_with_converted_amounts.source_relation = transaction_lines.source_relation

      and transactions_with_converted_amounts.transaction_accounting_period_id = transactions_with_converted_amounts.reporting_accounting_period_id
      and transactions_with_converted_amounts.source_relation = transactions_with_converted_amounts.source_relation

      

  left join accounts
    on accounts.account_id = transaction_lines.account_id
    and accounts.source_relation = transaction_lines.source_relation

  left join accounts as parent_account
    on parent_account.account_id = accounts.parent_id
    and parent_account.source_relation = accounts.source_relation

  left join accounting_periods
    on accounting_periods.accounting_period_id = transactions.accounting_period_id
    and accounting_periods.source_relation = transactions.source_relation

  left join customers customers__transactions
    on customers__transactions.customer_id = transactions.entity_id
    and customers__transactions.source_relation = transactions.source_relation

  left join customers customers__transaction_lines
    on customers__transaction_lines.customer_id = transaction_lines.entity_id
    and customers__transaction_lines.source_relation = transaction_lines.source_relation

  left join classes
    on classes.class_id = transaction_lines.class_id
    and classes.source_relation = transaction_lines.source_relation

  left join items
    on items.item_id = transaction_lines.item_id
    and items.source_relation = transaction_lines.source_relation

  left join locations
    on locations.location_id = transaction_lines.location_id
    and locations.source_relation = transaction_lines.source_relation

  left join nexuses
    on nexuses.nexus_id = transactions.nexus_id
    and nexuses.source_relation = transactions.source_relation

  left join vendors vendors__nexuses
    on vendors__nexuses.vendor_id = nexuses.tax_agency_id
    and vendors__nexuses.source_relation = nexuses.source_relation

  left join vendors vendors__transactions
    on vendors__transactions.vendor_id = transactions.entity_id
    and vendors__transactions.source_relation = transactions.source_relation

  left join vendors vendors__transaction_lines
    on vendors__transaction_lines.vendor_id = transaction_lines.entity_id
    and vendors__transaction_lines.source_relation = transaction_lines.source_relation

  
  left join vendor_categories vendor_categories__transactions
    on vendor_categories__transactions.vendor_category_id = vendors__transactions.vendor_category_id
    and vendor_categories__transactions.source_relation = vendors__transactions.source_relation

  left join vendor_categories vendor_categories__transaction_lines
    on vendor_categories__transaction_lines.vendor_category_id = vendors__transaction_lines.vendor_category_id
    and vendor_categories__transaction_lines.source_relation = vendors__transaction_lines.source_relation
  

  left join currencies
    on currencies.currency_id = transactions.currency_id
    and currencies.source_relation = transactions.source_relation

  left join departments
    on departments.department_id = transaction_lines.department_id
    and departments.source_relation = transaction_lines.source_relation

  join subsidiaries
    on subsidiaries.subsidiary_id = transaction_lines.subsidiary_id
    and subsidiaries.source_relation = transaction_lines.source_relation

  left join currencies subsidiaries_currencies
    on subsidiaries_currencies.currency_id = subsidiaries.currency_id
    and subsidiaries_currencies.source_relation = subsidiaries.source_relation
  
  left join primary_subsidiary_calendar
    on accounting_periods.fiscal_calendar_id = primary_subsidiary_calendar.fiscal_calendar_id
    and accounting_periods.source_relation = primary_subsidiary_calendar.source_relation
    
  where accounting_periods.fiscal_calendar_id is null
    or primary_subsidiary_calendar.fiscal_calendar_id is not null
),

surrogate_key as ( 
    
    
    

    select 
        *,
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(transaction_line_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(transaction_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as transaction_details_id

    from transaction_details
)

select *
from surrogate_key
