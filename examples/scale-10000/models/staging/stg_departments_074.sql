with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        region
,        created_at
,        cost_center
,        parent_id
    from source
)
select * from renamed
