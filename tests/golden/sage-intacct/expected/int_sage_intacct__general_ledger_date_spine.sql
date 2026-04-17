with spine as (

    

    





with rawdata as (

    

    

    with p as (
        select 0 as generated_number union all select 1
    ), unioned as (

    select

    
    p0.generated_number * power(2, 0)
    
    
    + 1
    as generated_number

    from

    
    p as p0
    
    

    )

    select *
    from unioned
    where generated_number <= 2
    order by generated_number



),

all_periods as (

    select (
        

    date_add(cast('2026-03-16' as date), interval (row_number() over (order by generated_number) - 1) month)


    ) as date_month
    from rawdata

),

filtered as (

    select *
    from all_periods
    where date_month <= 

    date_add(cast('2026-04-16' as date), interval (1) month)



)

select * from filtered


),

general_ledger as (
    select *
    from "sage_intacct"."main_sage_intacct"."sage_intacct__general_ledger"
),

date_spine as (
    select
        cast(date_trunc('year', date_month) as date) as date_year,
        cast(date_trunc('month', date_month) as date) as period_first_day,
        cast(
        

    date_add(

    date_add(date_trunc('month', date_month), interval (1) month)

, interval (-1) day)


        as date) as period_last_day,
        row_number() over (order by cast(date_trunc('month', date_month) as date)) as period_index
    from spine
),

unique_gl_accounts as (
    select distinct
        source_relation,
        account_no,
        account_title,
        account_type,
        book_id,
        category,
        classification,
        currency,
        entry_state
    from general_ledger
),

final as (
    select
        unique_gl_accounts.source_relation,
        unique_gl_accounts.account_no,
        unique_gl_accounts.account_title,
        unique_gl_accounts.account_type,
        unique_gl_accounts.book_id,
        unique_gl_accounts.category,
        unique_gl_accounts.classification,
        unique_gl_accounts.currency,
        unique_gl_accounts.entry_state,
        date_spine.date_year,
        date_spine.period_first_day,
        date_spine.period_last_day,
        date_spine.period_index
    from unique_gl_accounts

    cross join date_spine
)

select *
from final
