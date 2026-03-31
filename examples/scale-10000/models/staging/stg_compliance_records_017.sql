with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        risk_level
,        reviewed_at
,        record_type
,        account_id
,        reviewer_id
,        notes
,        category
    from source
)
select * from renamed
