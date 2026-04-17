with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__item_relationship_base"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as TEXT) as 
    
    child_asin
    
 , 
    cast(null as TEXT) as 
    
    parent_asin
    
 , 
    cast(null as TEXT) as 
    
    type
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        cast(child_asin as TEXT) as child_asin,
        cast(parent_asin as TEXT) as parent_asin,
        upper(type) as type
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
