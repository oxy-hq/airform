with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        department_name
,        cost_center
,        parent_id
,        location
,        created_at
    from source
)
select * from renamed
