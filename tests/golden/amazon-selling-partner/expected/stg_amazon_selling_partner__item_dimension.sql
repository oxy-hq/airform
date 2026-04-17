with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__item_dimension_base"
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
    
    item_height_unit
    
 , 
    cast(null as integer) as 
    
    item_height_value
    
 , 
    cast(null as TEXT) as 
    
    item_length_unit
    
 , 
    cast(null as integer) as 
    
    item_length_value
    
 , 
    cast(null as TEXT) as 
    
    item_weight_unit
    
 , 
    cast(null as integer) as 
    
    item_weight_value
    
 , 
    cast(null as TEXT) as 
    
    item_width_unit
    
 , 
    cast(null as integer) as 
    
    item_width_value
    
 , 
    cast(null as TEXT) as 
    
    marketplace_id
    
 , 
    cast(null as TEXT) as 
    
    package_height_unit
    
 , 
    cast(null as integer) as 
    
    package_height_value
    
 , 
    cast(null as TEXT) as 
    
    package_length_unit
    
 , 
    cast(null as integer) as 
    
    package_length_value
    
 , 
    cast(null as TEXT) as 
    
    package_weight_unit
    
 , 
    cast(null as integer) as 
    
    package_weight_value
    
 , 
    cast(null as TEXT) as 
    
    package_width_unit
    
 , 
    cast(null as integer) as 
    
    package_width_value
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        cast(asin as TEXT) as asin,
        marketplace_id,
        item_height_unit,
        item_height_value,
        item_length_unit,
        item_length_value,
        item_weight_unit,
        item_weight_value,
        item_width_unit,
        item_width_value,
        package_height_unit,
        package_height_value,
        package_length_unit,
        package_length_value,
        package_weight_unit,
        package_weight_value,
        package_width_unit,
        package_width_value
    from fields
)

select *
from final
