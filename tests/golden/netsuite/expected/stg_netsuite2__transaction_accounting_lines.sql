with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__transaction_accounting_lines_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    account
    
 , 
    cast(null as integer) as 
    
    accountingbook
    
 , 
    cast(null as float) as 
    
    amount
    
 , 
    cast(null as float) as 
    
    amountpaid
    
 , 
    cast(null as float) as 
    
    amountunpaid
    
 , 
    cast(null as float) as 
    
    credit
    
 , 
    cast(null as float) as 
    
    debit
    
 , 
    cast(null as float) as 
    
    exchangerate
    
 , 
    cast(null as float) as 
    
    netamount
    
 , 
    cast(null as TEXT) as 
    
    posting
    
 , 
    cast(null as integer) as 
    
    transaction
    
 , 
    cast(null as integer) as 
    
    transactionline
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation, 
        _fivetran_deleted,
        _fivetran_synced,
        transaction as transaction_id,
        transactionline as transaction_line_id,
        accountingbook as accounting_book_id,
        account as account_id,
        posting = 'T' as is_posting,
        exchangerate as exchange_rate,
        amount,
        credit as credit_amount,
        debit as debit_amount,
        netamount as net_amount,
        amountpaid as paid_amount,
        amountunpaid as unpaid_amount
    from fields
)

select *
from final
