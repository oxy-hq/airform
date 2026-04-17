with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__item_summary_base"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as boolean) as 
    
    adult_product
    
 , 
    cast(null as TEXT) as 
    
    asin
    
 , 
    cast(null as boolean) as 
    
    autographed
    
 , 
    cast(null as TEXT) as 
    
    brand
    
 , 
    cast(null as integer) as 
    
    classification_id
    
 , 
    cast(null as TEXT) as 
    
    color
    
 , 
    cast(null as integer) as 
    
    contributors
    
 , 
    cast(null as TEXT) as 
    
    display_name
    
 , 
    cast(null as TEXT) as 
    
    item_classification
    
 , 
    cast(null as TEXT) as 
    
    item_name
    
 , 
    cast(null as TEXT) as 
    
    manufacturer
    
 , 
    cast(null as TEXT) as 
    
    marketplace_id
    
 , 
    cast(null as boolean) as 
    
    memorabilia
    
 , 
    cast(null as TEXT) as 
    
    model_number
    
 , 
    cast(null as integer) as 
    
    package_quantity
    
 , 
    cast(null as TEXT) as 
    
    part_number
    
 , 
    cast(null as date) as 
    
    release_date
    
 , 
    cast(null as TEXT) as 
    
    size
    
 , 
    cast(null as TEXT) as 
    
    style
    
 , 
    cast(null as boolean) as 
    
    trade_in_eligible
    
 , 
    cast(null as TEXT) as 
    
    website_display_group
    
 , 
    cast(null as TEXT) as 
    
    website_display_group_name
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        adult_product as is_adult_product,
        cast(asin as TEXT) as asin,
        autographed as is_autographed,
        brand,
        classification_id,
        color,
        contributors,
        display_name,
        item_classification,
        item_name,
        manufacturer,
        marketplace_id,
        memorabilia as is_memorabilia,
        model_number,
        package_quantity,
        part_number,
        release_date,
        size,
        style,
        trade_in_eligible as is_trade_in_eligible,
        website_display_group,
        website_display_group_name
    from fields
)

select *
from final
