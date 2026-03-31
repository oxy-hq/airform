with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),

renamed as (
    select
        id as campaign_id
,        spend
,        campaign_name
,        status
,        goal
,        end_date
,        channel
,        budget
    from source
)

select * from renamed
