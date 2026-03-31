with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        campaign_name
,        channel
,        budget
,        spend
    from source
)
select * from renamed
