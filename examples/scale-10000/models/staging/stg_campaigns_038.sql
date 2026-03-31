with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        start_date
,        budget
,        status
,        channel
    from source
)
select * from renamed
