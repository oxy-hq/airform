with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        department_name
,        parent_id
,        location
,        created_at
,        cost_center
    from source
)
select * from renamed
