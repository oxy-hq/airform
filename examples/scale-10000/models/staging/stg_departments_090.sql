with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        region
,        budget
,        created_at
,        head_count
,        parent_id
,        location
    from source
)
select * from renamed
