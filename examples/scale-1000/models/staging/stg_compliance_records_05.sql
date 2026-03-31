with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),

renamed as (
    select
        id as compliance_record_id
,        account_id
,        risk_level
,        created_at
,        reviewed_at
,        status
,        reviewer_id
,        record_type
    from source
)

select * from renamed
