--To disable this model, set the using_twilio_messaging_service variable within your dbt_project.yml file to False.







    -- ** Values passed to adapter.get_relation:
    -- full-identifier_var: twilio_messaging_service_identifier
    -- database: twilio                            
    -- schema: twilio_integration_tests
    -- identifier: twilio_messaging_service_data


    
        

        select
            cast(null as TEXT) as _dbt_source_relation
        limit 0
