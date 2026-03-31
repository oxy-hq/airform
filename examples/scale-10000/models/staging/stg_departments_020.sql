with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        head_count
,        parent_id
,        region
,        department_name
,        cost_center
    from source
)
select * from renamed
