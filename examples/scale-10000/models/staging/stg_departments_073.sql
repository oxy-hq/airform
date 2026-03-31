with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        region
,        budget
,        cost_center
,        head_count
,        parent_id
,        location
,        created_at
    from source
)
select * from renamed
