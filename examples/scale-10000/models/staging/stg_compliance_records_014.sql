with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewer_id
,        account_id
,        created_at
,        status
,        record_type
    from source
)
select * from renamed
