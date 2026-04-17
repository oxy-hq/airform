with general_ledger_by_period as (
    select *
    from "sage_intacct"."main_sage_intacct"."sage_intacct__general_ledger_by_period"
    where account_type = 'balancesheet'
), 

retained_earnings as (
    select *
    from "sage_intacct"."main_sage_intacct"."int_sage_intacct__retained_earnings"
),

combine_retained_earnings as (
    select
        source_relation,
        period_first_day,
        account_no,
        account_title,
        account_type,
        book_id,
        category,
        classification,
        currency,
        entry_state,
        period_ending_amount as amount
    from general_ledger_by_period

    union all

    select *
    from retained_earnings
),

final as (
    select
        source_relation,
        cast (date_trunc('month', period_first_day) as date) as period_date,
        account_no,
        account_title,
        account_type,
        book_id,
        category,
        classification,
        currency,
        entry_state,
        round(cast(amount as numeric(28,6)),2) as amount
    from combine_retained_earnings
)

select *
from final
