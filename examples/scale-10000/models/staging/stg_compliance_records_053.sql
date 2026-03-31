with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        status
,        reviewer_id
,        account_id
,        risk_level
,        record_type
    from source
)
select * from renamed
