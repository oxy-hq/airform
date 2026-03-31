with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        parent_id
,        created_at
,        head_count
,        location
    from source
)
select * from renamed
