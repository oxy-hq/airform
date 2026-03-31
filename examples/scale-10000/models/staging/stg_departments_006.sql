with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        location
,        parent_id
,        cost_center
,        status
    from source
)
select * from renamed
