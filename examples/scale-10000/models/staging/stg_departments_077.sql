with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        region
,        cost_center
,        head_count
,        parent_id
,        location
,        budget
,        department_name
    from source
)
select * from renamed
