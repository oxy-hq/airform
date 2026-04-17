with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__vendors_tmp"

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_salesforce_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_salesforce_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    account_owner
    
 , 
    cast(null as TEXT) as 
    
    accountnumber
    
 , 
    cast(null as TEXT) as 
    
    accounts_email
    
 , 
    cast(null as float) as 
    
    annual_revenue
    
 , 
    cast(null as TEXT) as 
    
    auto_renewals
    
 , 
    cast(null as TEXT) as 
    
    auto_send_statements
    
 , 
    cast(null as TEXT) as 
    
    billaddress
    
 , 
    cast(null as float) as 
    
    billing_class_id
    
 , 
    cast(null as TEXT) as 
    
    city
    
 , 
    cast(null as TEXT) as 
    
    comments
    
 , 
    cast(null as TEXT) as 
    
    companyname
    
 , 
    cast(null as TEXT) as 
    
    country
    
 , 
    cast(null as timestamp) as 
    
    create_date
    
 , 
    cast(null as float) as 
    
    creditlimit
    
 , 
    cast(null as float) as 
    
    currency_id
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as timestamp) as 
    
    date_last_modified
    
 , 
    cast(null as TEXT) as 
    
    dic
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as TEXT) as 
    
    email_bill_payment_vouchers
    
 , 
    cast(null as TEXT) as 
    
    email_cash_sales
    
 , 
    cast(null as TEXT) as 
    
    email_credit_notes
    
 , 
    cast(null as TEXT) as 
    
    email_invoices
    
 , 
    cast(null as TEXT) as 
    
    email_item_fulfilments
    
 , 
    cast(null as TEXT) as 
    
    email_purchase_orders
    
 , 
    cast(null as TEXT) as 
    
    email_quotes
    
 , 
    cast(null as TEXT) as 
    
    email_sales_orders
    
 , 
    cast(null as TEXT) as 
    
    email_statements
    
 , 
    cast(null as TEXT) as 
    
    employee_number
    
 , 
    cast(null as TEXT) as 
    
    exemption_certificate_no
    
 , 
    cast(null as float) as 
    
    expense_account_id
    
 , 
    cast(null as TEXT) as 
    
    fax
    
 , 
    cast(null as TEXT) as 
    
    full_name
    
 , 
    cast(null as TEXT) as 
    
    home_phone
    
 , 
    cast(null as TEXT) as 
    
    hris_id
    
 , 
    cast(null as TEXT) as 
    
    ico
    
 , 
    cast(null as TEXT) as 
    
    id_number_in_the_country_of_r
    
 , 
    cast(null as float) as 
    
    id_type_in_the_country_of_r_id
    
 , 
    cast(null as float) as 
    
    in_transit_balance
    
 , 
    cast(null as TEXT) as 
    
    incoterm
    
 , 
    cast(null as float) as 
    
    industry_id
    
 , 
    cast(null as TEXT) as 
    
    invoice_via_procurement_syste
    
 , 
    cast(null as TEXT) as 
    
    invoicing_details
    
 , 
    cast(null as TEXT) as 
    
    is1099eligible
    
 , 
    cast(null as TEXT) as 
    
    is_partner
    
 , 
    cast(null as TEXT) as 
    
    is_person
    
 , 
    cast(null as TEXT) as 
    
    isemailhtml
    
 , 
    cast(null as TEXT) as 
    
    isemailpdf
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as float) as 
    
    labor_cost
    
 , 
    cast(null as timestamp) as 
    
    last_modified_date
    
 , 
    cast(null as timestamp) as 
    
    last_sales_activity
    
 , 
    cast(null as TEXT) as 
    
    line1
    
 , 
    cast(null as TEXT) as 
    
    line2
    
 , 
    cast(null as TEXT) as 
    
    line3
    
 , 
    cast(null as TEXT) as 
    
    loginaccess
    
 , 
    cast(null as TEXT) as 
    
    lsa_link
    
 , 
    cast(null as TEXT) as 
    
    lsa_link_name
    
 , 
    cast(null as TEXT) as 
    
    mobile_phone
    
 , 
    cast(null as timestamp) as 
    
    msa_effective_date
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as float) as 
    
    no__of_employees
    
 , 
    cast(null as float) as 
    
    openbalance
    
 , 
    cast(null as float) as 
    
    openbalance_foreign
    
 , 
    cast(null as float) as 
    
    payables_account_id
    
 , 
    cast(null as float) as 
    
    payment_terms_id
    
 , 
    cast(null as TEXT) as 
    
    phone
    
 , 
    cast(null as float) as 
    
    prepayment_balance
    
 , 
    cast(null as TEXT) as 
    
    printoncheckas
    
 , 
    cast(null as float) as 
    
    purchaseorderamount
    
 , 
    cast(null as float) as 
    
    purchaseorderquantity
    
 , 
    cast(null as float) as 
    
    purchaseorderquantitydiff
    
 , 
    cast(null as TEXT) as 
    
    purchases_email
    
 , 
    cast(null as float) as 
    
    receiptamount
    
 , 
    cast(null as float) as 
    
    receiptquantity
    
 , 
    cast(null as float) as 
    
    receiptquantitydiff
    
 , 
    cast(null as float) as 
    
    represents_subsidiary_id
    
 , 
    cast(null as TEXT) as 
    
    restrict_access_to_expensify
    
 , 
    cast(null as TEXT) as 
    
    salesforce_id
    
 , 
    cast(null as TEXT) as 
    
    shipaddress
    
 , 
    cast(null as TEXT) as 
    
    shipping_email
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as float) as 
    
    subsidiary
    
 , 
    cast(null as TEXT) as 
    
    tax_contact_first_name
    
 , 
    cast(null as float) as 
    
    tax_contact_id
    
 , 
    cast(null as TEXT) as 
    
    tax_contact_last_name
    
 , 
    cast(null as TEXT) as 
    
    tax_contact_middle_name
    
 , 
    cast(null as TEXT) as 
    
    tax_number
    
 , 
    cast(null as TEXT) as 
    
    taxidnum
    
 , 
    cast(null as float) as 
    
    time_approver_id
    
 , 
    cast(null as TEXT) as 
    
    transactions_need_approval
    
 , 
    cast(null as TEXT) as 
    
    uen
    
 , 
    cast(null as float) as 
    
    unbilled_orders
    
 , 
    cast(null as float) as 
    
    unbilled_orders_foreign
    
 , 
    cast(null as TEXT) as 
    
    url
    
 , 
    cast(null as TEXT) as 
    
    vat_registration_no
    
 , 
    cast(null as TEXT) as 
    
    vendor_extid
    
 , 
    cast(null as float) as 
    
    vendor_id
    
 , 
    cast(null as float) as 
    
    vendor_type_id
    
 , 
    cast(null as TEXT) as 
    
    zipcode
    
 


        
    from base
),

final as (
    
    select 
        vendor_id,
        companyname as company_name,
        create_date as create_date_at,
        vendor_type_id,
        _fivetran_deleted

        --The below macro adds the fields defined within your vendors_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
