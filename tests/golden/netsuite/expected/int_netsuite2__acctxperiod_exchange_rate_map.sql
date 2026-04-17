with  __dbt__cte__int_netsuite2__accounts as (


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
), accounts as (
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
