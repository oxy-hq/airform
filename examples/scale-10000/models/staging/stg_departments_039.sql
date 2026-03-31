with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        status
,        region
,        department_name
,        cost_center
    from source
)
select * from renamed
