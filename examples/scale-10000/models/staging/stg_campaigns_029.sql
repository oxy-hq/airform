with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        goal
,        channel
,        status
,        target_audience
,        campaign_name
,        spend
,        start_date
    from source
)
select * from renamed
