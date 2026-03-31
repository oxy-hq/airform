with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        department_name
,        region
,        head_count
,        cost_center
    from source
)
select * from renamed
