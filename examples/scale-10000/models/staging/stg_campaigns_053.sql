with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        budget
,        campaign_name
,        spend
,        goal
    from source
)
select * from renamed
