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
), transactions_with_converted_amounts as (
    select * 
    from __dbt__cte__int_netsuite2__tran_with_converted_amounts

    
), 

--Below is only used if income statement transaction detail columns are specified dbt_project.yml file.


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

currencies as (
    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__currencies"
),

transaction_lines as (
    select * 
    from __dbt__cte__int_netsuite2__transaction_lines
),

classes as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__classes"
),

locations as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__locations"
),

departments as (
    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__departments"
),

primary_subsidiary_calendar as (
    select 
        fiscal_calendar_id, 
        source_relation 
    from subsidiaries 
    where parent_id is null
),

income_statement as (
    select
        transactions_with_converted_amounts.source_relation,
        transactions_with_converted_amounts.transaction_id,
        transactions_with_converted_amounts.transaction_line_id,
        transactions_with_converted_amounts._fivetran_synced_date,

        

        

        reporting_accounting_periods.accounting_period_id as accounting_period_id,
        reporting_accounting_periods.ending_at as accounting_period_ending,
        reporting_accounting_periods.accounting_period_full_name,
        reporting_accounting_periods.name as accounting_period_name,
        reporting_accounting_periods.is_adjustment as is_accounting_period_adjustment,
        reporting_accounting_periods.is_closed as is_accounting_period_closed,
        accounts.name as account_name,
        accounts.display_name as account_display_name,
        accounts.type_name as account_type_name,
        accounts.account_type_id,
        accounts.account_id as account_id,
        accounts.account_number,
        subsidiaries.subsidiary_id,
        subsidiaries.full_name as subsidiary_full_name,
        subsidiaries.name as subsidiary_name,
        subsidiaries_currencies.symbol as subsidiary_currency_symbol

        --The below script allows for accounts table pass through columns.
        



,

        accounts.account_number || '-' || accounts.name as account_number_and_name,
        classes.class_id,
        classes.full_name as class_full_name

        --The below script allows for accounts table pass through columns.
        



,

        locations.location_id,
        locations.full_name as location_full_name,
        departments.department_id,
        departments.full_name as department_full_name

        --The below script allows for departments table pass through columns.
        



,

        transactions_with_converted_amounts.account_category as account_category,
        case when lower(accounts.account_type_id) = 'income' then 1
            when lower(accounts.account_type_id) = 'cogs' then 2
            when lower(accounts.account_type_id) = 'expense' then 3
            when lower(accounts.account_type_id) = 'othincome' then 4
            when lower(accounts.account_type_id) = 'othexpense' then 5
            else null
            end as income_statement_sort_helper

        --Below is only used if income statement transaction detail columns are specified dbt_project.yml file.
        

        , -converted_amount_using_transaction_accounting_period as converted_amount,

        -unconverted_amount as transaction_amount
        
    from transactions_with_converted_amounts

    join transaction_lines as transaction_lines
        on transaction_lines.transaction_line_id = transactions_with_converted_amounts.transaction_line_id
            and transaction_lines.transaction_id = transactions_with_converted_amounts.transaction_id
            and transaction_lines.source_relation = transactions_with_converted_amounts.source_relation

            

    left join departments
        on departments.department_id = transaction_lines.department_id
        and departments.source_relation = transaction_lines.source_relation
    
    left join accounts
        on accounts.account_id = transactions_with_converted_amounts.account_id
        and accounts.source_relation = transactions_with_converted_amounts.source_relation

    left join locations
        on locations.location_id = transaction_lines.location_id
        and locations.source_relation = transaction_lines.source_relation

    left join classes
        on classes.class_id = transaction_lines.class_id
        and classes.source_relation = transaction_lines.source_relation

    left join accounting_periods as reporting_accounting_periods
        on reporting_accounting_periods.accounting_period_id = transactions_with_converted_amounts.reporting_accounting_period_id
        and reporting_accounting_periods.source_relation = transactions_with_converted_amounts.source_relation
    
    left join subsidiaries
        on transactions_with_converted_amounts.subsidiary_id = subsidiaries.subsidiary_id
        and transactions_with_converted_amounts.source_relation = subsidiaries.source_relation

    left join currencies subsidiaries_currencies
        on subsidiaries_currencies.currency_id = subsidiaries.currency_id
        and subsidiaries_currencies.source_relation = subsidiaries.source_relation

    --Below is only used if income statement transaction detail columns are specified dbt_project.yml file.
    

    join primary_subsidiary_calendar 
        on reporting_accounting_periods.fiscal_calendar_id = primary_subsidiary_calendar.fiscal_calendar_id
        and reporting_accounting_periods.source_relation = primary_subsidiary_calendar.source_relation

    where transactions_with_converted_amounts.transaction_accounting_period_id = transactions_with_converted_amounts.reporting_accounting_period_id
        and transactions_with_converted_amounts.is_income_statement
),

surrogate_key as ( 
    
    
    

    select 
        *,
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(transaction_line_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(transaction_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(accounting_period_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(account_name as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as income_statement_id

    from income_statement
)

select *
from surrogate_key
