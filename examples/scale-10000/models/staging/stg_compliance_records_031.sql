with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewed_at
,        record_type
,        reviewer_id
,        status
,        risk_level
    from source
)
select * from renamed
