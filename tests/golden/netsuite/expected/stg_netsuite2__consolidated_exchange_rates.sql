with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__consolidated_exchange_rates_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as float) as 
    
    averagerate
    
 , 
    cast(null as float) as 
    
    currentrate
    
 , 
    cast(null as integer) as 
    
    fromcurrency
    
 , 
    cast(null as integer) as 
    
    fromsubsidiary
    
 , 
    cast(null as float) as 
    
    historicalrate
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    accountingbook
    
 , 
    cast(null as integer) as 
    
    postingperiod
    
 , 
    cast(null as integer) as 
    
    tocurrency
    
 , 
    cast(null as integer) as 
    
    tosubsidiary
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as consolidated_exchange_rate_id,
        postingperiod as accounting_period_id,
        fromcurrency as from_currency_id,
        fromsubsidiary as from_subsidiary_id,
        tocurrency as to_currency_id,
        tosubsidiary as to_subsidiary_id,
        accountingbook as accounting_book_id,
        currentrate as current_rate, 
        averagerate as average_rate,
        historicalrate as historical_rate

        --The below macro adds the fields defined within your consolidated_exchange_rates_pass_through_columns variable into the staging model
        







    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
