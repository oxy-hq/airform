with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        head_count
,        status
,        cost_center
,        department_name
    from source
)
select * from renamed
