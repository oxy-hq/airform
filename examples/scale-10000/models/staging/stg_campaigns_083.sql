with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        goal
,        campaign_name
,        status
,        spend
,        channel
    from source
)
select * from renamed
