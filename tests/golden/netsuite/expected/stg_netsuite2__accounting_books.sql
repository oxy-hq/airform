with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__accounting_books_tmp"
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
    
    basebook
    
 , 
    cast(null as TEXT) as 
    
    contingentrevenuehandling
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as integer) as 
    
    effectiveperiod
    
 , 
    cast(null as TEXT) as 
    
    externalid
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    isadjustmentonly
    
 , 
    cast(null as TEXT) as 
    
    isconsolidated
    
 , 
    cast(null as TEXT) as 
    
    isprimary
    
 , 
    cast(null as timestamp) as 
    
    lastmodifieddate
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    subsidiariesstring
    
 , 
    cast(null as TEXT) as 
    
    twosteprevenueallocation
    
 , 
    cast(null as TEXT) as 
    
    unbilledreceivablegrouping
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as accounting_book_id,
        name as accounting_book_name,
        basebook as base_book_id,
        effectiveperiod as effective_period_id,
        isadjustmentonly = 'T' as is_adjustment_only,
        isconsolidated = 'T' as is_consolidated,
        contingentrevenuehandling as is_contingent_revenue_handling,
        isprimary = 'T' as is_primary,
        twosteprevenueallocation as is_two_step_revenue_allocation
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
