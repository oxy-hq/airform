with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        cost_center
,        department_name
,        parent_id
,        created_at
,        region
,        location
    from source
)
select * from renamed
