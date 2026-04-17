with base as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__usage_record_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    account_id
    
 , 
    cast(null as timestamp) as 
    
    as_of
    
 , 
    cast(null as TEXT) as 
    
    category
    
 , 
    cast(null as TEXT) as 
    
    count
    
 , 
    cast(null as TEXT) as 
    
    count_unit
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as date) as 
    
    end_date
    
 , 
    cast(null as TEXT) as 
    
    price
    
 , 
    cast(null as TEXT) as 
    
    price_unit
    
 , 
    cast(null as date) as 
    
    start_date
    
 , 
    cast(null as TEXT) as 
    
    usage
    
 , 
    cast(null as TEXT) as 
    
    usage_unit
    
 


        
, 'twilio' || '.'|| 'twilio_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        account_id,
        as_of,
        category,
        cast( 
    REGEXP_REPLACE(cast (count as TEXT), '[^0-9.-]', '')
 as float) as count,
        count_unit,
        description,
        end_date,
        cast( 
    REGEXP_REPLACE(cast (price as TEXT), '[^0-9.-]', '')
 as float) as price,
        price_unit,
        start_date,
        cast( 
    REGEXP_REPLACE(cast (usage as TEXT), '[^0-9.-]', '')
 as float) as usage,
        usage_unit
    from fields
)

select *
from final
