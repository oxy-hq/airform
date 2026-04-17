with  __dbt__cte__int_netsuite__transaction_lines_w_accounting_period as (


with transactions as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__transactions"
), 

transaction_lines as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__transaction_lines"
),

transaction_lines_w_accounting_period as ( -- transaction line totals, by accounts, accounting period and subsidiary
  select
    transaction_lines.transaction_id,
    transaction_lines.transaction_line_id,
    transaction_lines.subsidiary_id,
    transaction_lines.account_id,
    transactions.accounting_period_id as transaction_accounting_period_id,
    coalesce(transaction_lines.amount, 0) as unconverted_amount
  from transaction_lines

  join transactions on transactions.transaction_id = transaction_lines.transaction_id

  where lower(transactions.transaction_type) != 'revenue arrangement'
    and lower(non_posting_line) != 'yes'
)

select * 
from transaction_lines_w_accounting_period
),  __dbt__cte__int_netsuite__accountxperiod_exchange_rate_map as (


with accounts as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__accounts"
), 

accounting_books as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__accounting_books"
), 

subsidiaries as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__subsidiaries"
),

consolidated_exchange_rates as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__consolidated_exchange_rates"
),

period_exchange_rate_map as ( -- exchange rates used, by accounting period, to convert to parent subsidiary
  select
    consolidated_exchange_rates.accounting_period_id,
    consolidated_exchange_rates.average_rate,
    consolidated_exchange_rates.current_rate,
    consolidated_exchange_rates.historical_rate,
    consolidated_exchange_rates.from_subsidiary_id,
    consolidated_exchange_rates.to_subsidiary_id
  from consolidated_exchange_rates

  where consolidated_exchange_rates.to_subsidiary_id in (select subsidiary_id from subsidiaries where parent_id is null)  -- constrait - only the primary subsidiary has no parent
    and consolidated_exchange_rates.accounting_book_id in (select accounting_book_id from accounting_books where lower(is_primary) = 'yes')
), 

accountxperiod_exchange_rate_map as ( -- account table with exchange rate details by accounting period
  select
    period_exchange_rate_map.accounting_period_id,
    period_exchange_rate_map.from_subsidiary_id,
    period_exchange_rate_map.to_subsidiary_id,
    accounts.account_id,
    case 
      when lower(accounts.general_rate_type) = 'historical' then period_exchange_rate_map.historical_rate
      when lower(accounts.general_rate_type) = 'current' then period_exchange_rate_map.current_rate
      when lower(accounts.general_rate_type) = 'average' then period_exchange_rate_map.average_rate
      else null
        end as exchange_rate
  from accounts
  
  cross join period_exchange_rate_map
)

select * 
from accountxperiod_exchange_rate_map
),  __dbt__cte__int_netsuite__transaction_and_reporting_periods as (


with accounting_periods as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__accounting_periods"
),

subsidiaries as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__subsidiaries"
),

transaction_and_reporting_periods as ( 
  select
    base.accounting_period_id as accounting_period_id,
    multiplier.accounting_period_id as reporting_accounting_period_id
  from accounting_periods as base

  join accounting_periods as multiplier
    on multiplier.starting_at >= base.starting_at
      and multiplier.quarter = base.quarter
      and multiplier.year_0 = base.year_0
      and multiplier.fiscal_calendar_id = base.fiscal_calendar_id
      and cast(multiplier.starting_at as timestamp) <= now() 

  where lower(base.quarter) = 'no'
    and lower(base.year_0) = 'no'
    and base.fiscal_calendar_id = (select fiscal_calendar_id from subsidiaries where parent_id is null) -- fiscal calendar will align with parent subsidiary's default calendar
)

select * 
from transaction_and_reporting_periods
),  __dbt__cte__int_netsuite__transactions_with_converted_amounts as (


with transaction_lines_w_accounting_period as (
    select * 
    from __dbt__cte__int_netsuite__transaction_lines_w_accounting_period
), 

accountxperiod_exchange_rate_map as (
    select * 
    from __dbt__cte__int_netsuite__accountxperiod_exchange_rate_map
), 

transaction_and_reporting_periods as (
    select * 
    from __dbt__cte__int_netsuite__transaction_and_reporting_periods
), 

accounts as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__accounts"
),

transactions_in_every_calculation_period_w_exchange_rates as (
  select
    transaction_lines_w_accounting_period.*,
    reporting_accounting_period_id,
    exchange_reporting_period.exchange_rate as exchange_rate_reporting_period,
    exchange_transaction_period.exchange_rate as exchange_rate_transaction_period
  from transaction_lines_w_accounting_period

  join transaction_and_reporting_periods 
    on transaction_and_reporting_periods.accounting_period_id = transaction_lines_w_accounting_period.transaction_accounting_period_id 

  join accountxperiod_exchange_rate_map as exchange_reporting_period
    on exchange_reporting_period.accounting_period_id = transaction_and_reporting_periods.reporting_accounting_period_id
      and exchange_reporting_period.account_id = transaction_lines_w_accounting_period.account_id
      and exchange_reporting_period.from_subsidiary_id = transaction_lines_w_accounting_period.subsidiary_id
      
  join accountxperiod_exchange_rate_map as exchange_transaction_period
    on exchange_transaction_period.accounting_period_id = transaction_and_reporting_periods.accounting_period_id
      and exchange_transaction_period.account_id = transaction_lines_w_accounting_period.account_id
      and exchange_transaction_period.from_subsidiary_id = transaction_lines_w_accounting_period.subsidiary_id
), 

transactions_with_converted_amounts as (
  select
    transactions_in_every_calculation_period_w_exchange_rates.*,
    unconverted_amount * exchange_rate_transaction_period as converted_amount_using_transaction_accounting_period,
    unconverted_amount * exchange_rate_reporting_period as converted_amount_using_reporting_month,
    case
      when lower(accounts.type_name) in ('income','other income','expense','other expense','other income','cost of goods sold') then true
      else false 
        end as is_income_statement,
    case
      when lower(accounts.type_name) in ('accounts receivable', 'bank', 'deferred expense', 'fixed asset', 'other asset', 'other current asset', 'unbilled receivable', 'prepaid expense') then 'Asset'
      when lower(accounts.type_name) in ('cost of goods sold', 'expense', 'other expense') then 'Expense'
      when lower(accounts.type_name) in ('income', 'other income') then 'Income'
      when lower(accounts.type_name) in ('accounts payable', 'credit card', 'deferred revenue', 'long term liability', 'other current liability') then 'Liability'
      when lower(accounts.type_name) in ('equity', 'retained earnings', 'net income') then 'Equity'
      when lower(accounts.type_name) in ('non posting', 'statistical') then 'Other'
      else null 
        end as account_category
  from transactions_in_every_calculation_period_w_exchange_rates

  left join accounts 
    on accounts.account_id = transactions_in_every_calculation_period_w_exchange_rates.account_id 
)

select * 
from transactions_with_converted_amounts
), transactions_with_converted_amounts as (
    select * 
    from __dbt__cte__int_netsuite__transactions_with_converted_amounts
),

accounts as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__accounts"
),

accounting_periods as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__accounting_periods"
),

subsidiaries as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__subsidiaries"
),

transaction_lines as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__transaction_lines"
),

transactions as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__transactions"
),

income_accounts as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__income_accounts"
),

expense_accounts as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__expense_accounts"
),

customers as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__customers"
),

items as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__items"
),

locations as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__locations"
),

vendors as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__vendors"
),

vendor_types as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__vendor_types"
),

departments as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__departments"
),

currencies as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__currencies"
),

classes as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite__classes"
),

transaction_details as (
  select
    transaction_lines.transaction_line_id,
    transaction_lines.memo as transaction_memo,
    lower(transaction_lines.non_posting_line) = 'yes' as is_transaction_non_posting,
    transactions.transaction_id,
    transactions.status as transaction_status,
    transactions.transaction_date,
    transactions.due_date_at as transaction_due_date,
    transactions.transaction_type as transaction_type,
    (lower(transactions.is_advanced_intercompany) = 'yes' or lower(transactions.is_intercompany) = 'yes') as is_transaction_intercompany

    --The below script allows for transactions table pass through columns.
    



    

    --The below script allows for transaction lines table pass through columns.
    



,

    accounting_periods.ending_at as accounting_period_ending,
    accounting_periods.full_name as accounting_period_full_name,
    accounting_periods.name as accounting_period_name,
    lower(accounting_periods.is_adjustment) = 'yes' as is_accounting_period_adjustment,
    lower(accounting_periods.is_closed) = 'yes' as is_accounting_period_closed,
    accounts.name as account_name,
    accounts.type_name as account_type_name,
    accounts.account_id as account_id,
    accounts.account_number

    --The below script allows for accounts table pass through columns.
    



,

    lower(accounts.is_leftside) = 't' as is_account_leftside,
    lower(accounts.type_name) like 'accounts payable%' as is_accounts_payable,
    lower(accounts.type_name) like 'accounts receivable%' as is_accounts_receivable,
    lower(accounts.name) like '%intercompany%' as is_account_intercompany,
    coalesce(parent_account.name, accounts.name) as parent_account_name,
    income_accounts.income_account_id is not null as is_income_account,
    expense_accounts.expense_account_id is not null as is_expense_account,
    customers.company_name,
    customers.city as customer_city,
    customers.state as customer_state,
    customers.zipcode as customer_zipcode,
    customers.country as customer_country,
    customers.date_first_order_at as customer_date_first_order,
    customers.customer_external_id,
    classes.full_name as class_full_name,
    items.name as item_name,
    items.type_name as item_type_name,
    items.sales_description,
    locations.name as location_name,
    locations.city as location_city,
    locations.country as location_country,
    vendor_types.name as vendor_type_name,
    vendors.company_name as vendor_name,
    vendors.create_date_at as vendor_create_date,
    currencies.name as currency_name,
    currencies.symbol as currency_symbol,
    departments.name as department_name

    --The below script allows for departments table pass through columns.
    



,

    subsidiaries.name as subsidiary_name,
    case
      when lower(accounts.type_name) = 'income' or lower(accounts.type_name) = 'other income' then -converted_amount_using_transaction_accounting_period
      else converted_amount_using_transaction_accounting_period
        end as converted_amount,
    case
      when lower(accounts.type_name) = 'income' or lower(accounts.type_name) = 'other income' then -transaction_lines.amount
      else transaction_lines.amount
        end as transaction_amount
  from transaction_lines

  join transactions
    on transactions.transaction_id = transaction_lines.transaction_id

  left join transactions_with_converted_amounts as transactions_with_converted_amounts
    on transactions_with_converted_amounts.transaction_line_id = transaction_lines.transaction_line_id
      and transactions_with_converted_amounts.transaction_id = transaction_lines.transaction_id
      and transactions_with_converted_amounts.transaction_accounting_period_id = transactions_with_converted_amounts.reporting_accounting_period_id

  left join accounts 
    on accounts.account_id = transaction_lines.account_id

  left join accounts as parent_account 
    on parent_account.account_id = accounts.parent_id

  left join accounting_periods 
    on accounting_periods.accounting_period_id = transactions.accounting_period_id
  left join income_accounts 
    on income_accounts.income_account_id = accounts.account_id

  left join expense_accounts 
    on expense_accounts.expense_account_id = accounts.account_id

  left join customers 
    on customers.customer_id = transaction_lines.company_id
  
  left join classes
    on classes.class_id = transaction_lines.class_id

  left join items 
    on items.item_id = transaction_lines.item_id

  left join locations 
    on locations.location_id = transaction_lines.location_id

  left join vendors 
    on vendors.vendor_id = transaction_lines.company_id

  left join vendor_types 
    on vendor_types.vendor_type_id = vendors.vendor_type_id

  left join currencies 
    on currencies.currency_id = transactions.currency_id

  left join departments 
    on departments.department_id = transaction_lines.department_id

  join subsidiaries 
    on subsidiaries.subsidiary_id = transaction_lines.subsidiary_id
    
  where (accounting_periods.fiscal_calendar_id is null
    or accounting_periods.fiscal_calendar_id  = (select fiscal_calendar_id from subsidiaries where parent_id is null))
)

select *
from transaction_details
