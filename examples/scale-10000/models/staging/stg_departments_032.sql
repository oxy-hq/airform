with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        location
,        head_count
,        department_name
,        created_at
,        parent_id
    from source
)
select * from renamed
