with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__item_display_group_sales_rank_base"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    asin
    
 , 
    cast(null as TEXT) as 
    
    link
    
 , 
    cast(null as integer) as 
    
    rank
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as TEXT) as 
    
    website_display_group
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        cast(asin as TEXT) as asin,
        link,
        rank,
        title,
        website_display_group
    from fields
)

select *
from final
