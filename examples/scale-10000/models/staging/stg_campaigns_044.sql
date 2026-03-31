with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        start_date
,        status
,        target_audience
,        channel
,        goal
,        end_date
,        spend
    from source
)
select * from renamed
