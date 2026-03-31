with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        target_audience
,        spend
,        start_date
,        status
,        campaign_name
,        budget
,        channel
    from source
)
select * from renamed
