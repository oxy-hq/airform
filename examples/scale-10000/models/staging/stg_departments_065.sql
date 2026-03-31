with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        status
,        parent_id
,        location
,        created_at
,        cost_center
,        head_count
    from source
)
select * from renamed
