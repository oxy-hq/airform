with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        status
,        spend
,        campaign_name
,        goal
    from source
)
select * from renamed
