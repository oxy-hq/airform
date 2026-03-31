with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        created_at
,        parent_id
,        cost_center
,        department_name
    from source
)
select * from renamed
