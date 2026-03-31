with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        record_type
,        notes
,        reviewer_id
,        account_id
,        status
,        category
    from source
)
select * from renamed
