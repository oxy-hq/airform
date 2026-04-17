with locations as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__locations"
),

location_main_address as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__location_main_address"
),

joined as (

    select
        locations.*,
        location_main_address.city,
        location_main_address.state,
        location_main_address.zipcode,
        location_main_address.country
    from locations
    left join location_main_address
        on locations.main_address_id = location_main_address.nkey
        and locations.source_relation = location_main_address.source_relation
)

select *
from joined
