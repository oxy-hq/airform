with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__item_classification_sales_rank_base"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    asin
    
 , 
    cast(null as integer) as 
    
    classification_id
    
 , 
    cast(null as TEXT) as 
    
    link
    
 , 
    cast(null as integer) as 
    
    rank
    
 , 
    cast(null as TEXT) as 
    
    title
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        cast(asin as TEXT) as asin,
        classification_id,
        link,
        rank,
        title
    from fields
)

select *
from final
