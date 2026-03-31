with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        department_name
,        cost_center
,        region
,        parent_id
    from source
)
select * from renamed
