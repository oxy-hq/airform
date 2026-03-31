with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        goal
,        channel
,        start_date
,        spend
,        budget
    from source
)
select * from renamed
