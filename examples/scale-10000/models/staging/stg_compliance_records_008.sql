with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        category
,        notes
,        risk_level
    from source
)
select * from renamed
