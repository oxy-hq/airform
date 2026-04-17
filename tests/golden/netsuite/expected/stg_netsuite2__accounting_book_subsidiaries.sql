with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__accounting_book_subsidiaries_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as TEXT) as 
    
    _fivetran_id
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    accountingbook
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as integer) as 
    
    subsidiary
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation, 
        _fivetran_id,
        _fivetran_synced,
        accountingbook as accounting_book_id,
        status,
        subsidiary as subsidiary_id

    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
