with report as (

    select *
    from twitter_organic__tweets

), fields as (

    select        
        created_timestamp,
        cast(organic_tweet_id as TEXT) as  post_id,
        cast(tweet_text as TEXT) as post_message,
        cast(account_id as TEXT) as page_id,
        cast(account_name as TEXT) as page_name,
        cast(post_url as TEXT) as post_url,
        source_relation,
        'twitter' as platform,
        coalesce(sum(clicks),0) as clicks,
        coalesce(sum(impressions),0) as impressions,
        coalesce(sum(likes),0) as likes,
        coalesce(sum(retweets),0) as shares,
        coalesce(sum(replies),0) as comments
    from report
    group by 1,2,3,4,5,6,7,8

)

select *
from fields
