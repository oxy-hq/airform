with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        risk_level
,        account_id
,        notes
,        category
,        status
,        record_type
    from source
)
select * from renamed
