with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        channel
,        target_audience
,        campaign_name
,        goal
,        start_date
,        spend
    from source
)
select * from renamed
