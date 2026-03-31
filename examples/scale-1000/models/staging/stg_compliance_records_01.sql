with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),

renamed as (
    select
        id as compliance_record_id
,        risk_level
,        status
,        record_type
,        account_id
,        reviewer_id
    from source
)

select * from renamed
