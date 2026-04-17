select
    vendor_type_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__vendor_types"
where vendor_type_id is not null
group by vendor_type_id
having count(*) > 1
