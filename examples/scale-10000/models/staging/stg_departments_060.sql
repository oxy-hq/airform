with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        head_count
,        parent_id
,        created_at
,        budget
,        region
    from source
)
select * from renamed
