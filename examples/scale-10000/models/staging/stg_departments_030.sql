with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        cost_center
,        department_name
,        budget
,        head_count
,        parent_id
,        status
,        region
    from source
)
select * from renamed
