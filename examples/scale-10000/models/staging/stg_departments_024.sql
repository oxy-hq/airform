with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        status
,        location
,        head_count
,        cost_center
,        department_name
,        region
,        budget
    from source
)
select * from renamed
