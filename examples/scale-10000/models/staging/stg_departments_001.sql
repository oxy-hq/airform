with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        location
,        cost_center
,        region
,        status
,        head_count
    from source
)
select * from renamed
