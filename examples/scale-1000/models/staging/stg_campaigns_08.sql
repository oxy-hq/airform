with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),

renamed as (
    select
        id as campaign_id
,        status
,        start_date
,        budget
,        channel
,        spend
,        goal
,        campaign_name
    from source
)

select * from renamed
