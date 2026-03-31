with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        created_at
,        record_type
,        reviewed_at
,        account_id
,        status
,        notes
    from source
)
select * from renamed
