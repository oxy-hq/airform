with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        location
,        budget
,        cost_center
,        head_count
,        department_name
,        status
    from source
)
select * from renamed
