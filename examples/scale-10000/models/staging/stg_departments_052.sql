with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        parent_id
,        status
,        department_name
,        region
,        head_count
,        budget
,        cost_center
    from source
)
select * from renamed
