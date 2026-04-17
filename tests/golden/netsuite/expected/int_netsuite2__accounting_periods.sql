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
