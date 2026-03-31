with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        head_count
,        budget
,        created_at
,        status
,        cost_center
,        region
    from source
)
select * from renamed
