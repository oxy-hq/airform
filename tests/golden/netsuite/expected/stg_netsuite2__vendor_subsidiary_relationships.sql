with base as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__vendor_subsidiary_relationships_tmp"
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
    
    balance
    
 , 
    cast(null as float) as 
    
    balancebase
    
 , 
    cast(null as float) as 
    
    balancecurrency
    
 , 
    cast(null as float) as 
    
    creditlimit
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as integer) as 
    
    entity
    
 , 
    cast(null as TEXT) as 
    
    externalid
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    isprimarysub
    
 , 
    cast(null as timestamp) as 
    
    lastmodifieddate
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as float) as 
    
    prepaymentbalance
    
 , 
    cast(null as float) as 
    
    prepaymentbalancebase
    
 , 
    cast(null as integer) as 
    
    primarycurrency
    
 , 
    cast(null as integer) as 
    
    subsidiary
    
 , 
    cast(null as float) as 
    
    unbilledorders
    
 , 
    cast(null as float) as 
    
    unbilledordersbase
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

        from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as vendor_subsidiary_relationship_id,
        entity as vendor_id,
        isprimarysub as is_primary_sub,
        primarycurrency as primary_currency_id,
        subsidiary as subsidiary_id
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
