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
), transactions as (
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
