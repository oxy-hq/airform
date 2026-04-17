with  __dbt__cte__int_netsuite2__accounting_periods as (


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
), accounting_periods as (
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
