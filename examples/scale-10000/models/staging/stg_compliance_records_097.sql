with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        status
,        reviewed_at
,        risk_level
,        category
,        record_type
    from source
)
select * from renamed
