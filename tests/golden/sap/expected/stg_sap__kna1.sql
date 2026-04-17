with base as (

    select 
    from "sap"."main_sap"."stg_sap__kna1_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as numeric(28,6)) as 
    
    _fivetran_rowid
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_sap_archived
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    abrvw
    
 , 
    cast(null as TEXT) as 
    
    adrnr
    
 , 
    cast(null as TEXT) as 
    
    alc
    
 , 
    cast(null as TEXT) as 
    
    anred
    
 , 
    cast(null as TEXT) as 
    
    aufsd
    
 , 
    cast(null as TEXT) as 
    
    bahne
    
 , 
    cast(null as TEXT) as 
    
    bahns
    
 , 
    cast(null as TEXT) as 
    
    bbbnr
    
 , 
    cast(null as TEXT) as 
    
    bbsnr
    
 , 
    cast(null as TEXT) as 
    
    begru
    
 , 
    cast(null as TEXT) as 
    
    bran1
    
 , 
    cast(null as TEXT) as 
    
    bran2
    
 , 
    cast(null as TEXT) as 
    
    bran3
    
 , 
    cast(null as TEXT) as 
    
    bran4
    
 , 
    cast(null as TEXT) as 
    
    bran5
    
 , 
    cast(null as TEXT) as 
    
    brsch
    
 , 
    cast(null as TEXT) as 
    
    bubkz
    
 , 
    cast(null as TEXT) as 
    
    cassd
    
 , 
    cast(null as TEXT) as 
    
    ccc01
    
 , 
    cast(null as TEXT) as 
    
    ccc02
    
 , 
    cast(null as TEXT) as 
    
    ccc03
    
 , 
    cast(null as TEXT) as 
    
    ccc04
    
 , 
    cast(null as TEXT) as 
    
    cfopc
    
 , 
    cast(null as TEXT) as 
    
    cityc
    
 , 
    cast(null as TEXT) as 
    
    civve
    
 , 
    cast(null as TEXT) as 
    
    cnae
    
 , 
    cast(null as TEXT) as 
    
    comsize
    
 , 
    cast(null as TEXT) as 
    
    confs
    
 , 
    cast(null as TEXT) as 
    
    counc
    
 , 
    cast(null as TEXT) as 
    
    crtn
    
 , 
    cast(null as TEXT) as 
    
    cvp_xblck
    
 , 
    cast(null as TEXT) as 
    
    datlt
    
 , 
    cast(null as TEXT) as 
    
    dear1
    
 , 
    cast(null as TEXT) as 
    
    dear2
    
 , 
    cast(null as TEXT) as 
    
    dear3
    
 , 
    cast(null as TEXT) as 
    
    dear4
    
 , 
    cast(null as TEXT) as 
    
    dear5
    
 , 
    cast(null as TEXT) as 
    
    dear6
    
 , 
    cast(null as TEXT) as 
    
    decregpc
    
 , 
    cast(null as TEXT) as 
    
    dtams
    
 , 
    cast(null as TEXT) as 
    
    dtaws
    
 , 
    cast(null as TEXT) as 
    
    duefl
    
 , 
    cast(null as TEXT) as 
    
    duns
    
 , 
    cast(null as TEXT) as 
    
    duns4
    
 , 
    cast(null as TEXT) as 
    
    ekont
    
 , 
    cast(null as TEXT) as 
    
    erdat
    
 , 
    cast(null as TEXT) as 
    
    ernam
    
 , 
    cast(null as TEXT) as 
    
    etikg
    
 , 
    cast(null as TEXT) as 
    
    exabl
    
 , 
    cast(null as TEXT) as 
    
    exp
    
 , 
    cast(null as TEXT) as 
    
    faksd
    
 , 
    cast(null as TEXT) as 
    
    fee_schedule
    
 , 
    cast(null as TEXT) as 
    
    fiskn
    
 , 
    cast(null as TEXT) as 
    
    fityp
    
 , 
    cast(null as TEXT) as 
    
    gform
    
 , 
    cast(null as TEXT) as 
    
    hzuor
    
 , 
    cast(null as TEXT) as 
    
    icmstaxpay
    
 , 
    cast(null as TEXT) as 
    
    indtyp
    
 , 
    cast(null as TEXT) as 
    
    inspatdebi
    
 , 
    cast(null as TEXT) as 
    
    inspbydebi
    
 , 
    cast(null as TEXT) as 
    
    j_1kfrepre
    
 , 
    cast(null as TEXT) as 
    
    j_1kftbus
    
 , 
    cast(null as TEXT) as 
    
    j_1kftind
    
 , 
    cast(null as TEXT) as 
    
    jmjah
    
 , 
    cast(null as TEXT) as 
    
    jmzah
    
 , 
    cast(null as TEXT) as 
    
    katr1
    
 , 
    cast(null as TEXT) as 
    
    katr10
    
 , 
    cast(null as TEXT) as 
    
    katr2
    
 , 
    cast(null as TEXT) as 
    
    katr3
    
 , 
    cast(null as TEXT) as 
    
    katr4
    
 , 
    cast(null as TEXT) as 
    
    katr5
    
 , 
    cast(null as TEXT) as 
    
    katr6
    
 , 
    cast(null as TEXT) as 
    
    katr7
    
 , 
    cast(null as TEXT) as 
    
    katr8
    
 , 
    cast(null as TEXT) as 
    
    katr9
    
 , 
    cast(null as TEXT) as 
    
    kdkg1
    
 , 
    cast(null as TEXT) as 
    
    kdkg2
    
 , 
    cast(null as TEXT) as 
    
    kdkg3
    
 , 
    cast(null as TEXT) as 
    
    kdkg4
    
 , 
    cast(null as TEXT) as 
    
    kdkg5
    
 , 
    cast(null as TEXT) as 
    
    knazk
    
 , 
    cast(null as TEXT) as 
    
    knrza
    
 , 
    cast(null as TEXT) as 
    
    knurl
    
 , 
    cast(null as TEXT) as 
    
    konzs
    
 , 
    cast(null as TEXT) as 
    
    ktocd
    
 , 
    cast(null as TEXT) as 
    
    ktokd
    
 , 
    cast(null as TEXT) as 
    
    kukla
    
 , 
    cast(null as TEXT) as 
    
    kunnr
    
 , 
    cast(null as TEXT) as 
    
    land1
    
 , 
    cast(null as TEXT) as 
    
    legalnat
    
 , 
    cast(null as TEXT) as 
    
    lifnr
    
 , 
    cast(null as TEXT) as 
    
    lifsd
    
 , 
    cast(null as TEXT) as 
    
    locco
    
 , 
    cast(null as TEXT) as 
    
    loevm
    
 , 
    cast(null as TEXT) as 
    
    lzone
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mcod1
    
 , 
    cast(null as TEXT) as 
    
    mcod2
    
 , 
    cast(null as TEXT) as 
    
    mcod3
    
 , 
    cast(null as TEXT) as 
    
    milve
    
 , 
    cast(null as TEXT) as 
    
    name1
    
 , 
    cast(null as TEXT) as 
    
    name2
    
 , 
    cast(null as TEXT) as 
    
    name3
    
 , 
    cast(null as TEXT) as 
    
    name4
    
 , 
    cast(null as TEXT) as 
    
    niels
    
 , 
    cast(null as TEXT) as 
    
    nodel
    
 , 
    cast(null as TEXT) as 
    
    oid_poreqd
    
 , 
    cast(null as TEXT) as 
    
    oidrc
    
 , 
    cast(null as TEXT) as 
    
    oipbl
    
 , 
    cast(null as TEXT) as 
    
    ort01
    
 , 
    cast(null as TEXT) as 
    
    ort02
    
 , 
    cast(null as TEXT) as 
    
    periv
    
 , 
    cast(null as TEXT) as 
    
    pfach
    
 , 
    cast(null as TEXT) as 
    
    pfort
    
 , 
    cast(null as TEXT) as 
    
    pmt_office
    
 , 
    cast(null as TEXT) as 
    
    psofg
    
 , 
    cast(null as TEXT) as 
    
    psohs
    
 , 
    cast(null as TEXT) as 
    
    psois
    
 , 
    cast(null as TEXT) as 
    
    pson1
    
 , 
    cast(null as TEXT) as 
    
    pson2
    
 , 
    cast(null as TEXT) as 
    
    pson3
    
 , 
    cast(null as TEXT) as 
    
    psoo1
    
 , 
    cast(null as TEXT) as 
    
    psoo2
    
 , 
    cast(null as TEXT) as 
    
    psoo3
    
 , 
    cast(null as TEXT) as 
    
    psoo4
    
 , 
    cast(null as TEXT) as 
    
    psoo5
    
 , 
    cast(null as TEXT) as 
    
    psost
    
 , 
    cast(null as TEXT) as 
    
    psotl
    
 , 
    cast(null as TEXT) as 
    
    psovn
    
 , 
    cast(null as TEXT) as 
    
    pstl2
    
 , 
    cast(null as TEXT) as 
    
    pstlz
    
 , 
    cast(null as TEXT) as 
    
    regio
    
 , 
    cast(null as TEXT) as 
    
    rg
    
 , 
    cast(null as TEXT) as 
    
    rgdate
    
 , 
    cast(null as TEXT) as 
    
    ric
    
 , 
    cast(null as TEXT) as 
    
    rne
    
 , 
    cast(null as TEXT) as 
    
    rnedate
    
 , 
    cast(null as TEXT) as 
    
    rpmkr
    
 , 
    cast(null as TEXT) as 
    
    sortl
    
 , 
    cast(null as TEXT) as 
    
    sperr
    
 , 
    cast(null as TEXT) as 
    
    sperz
    
 , 
    cast(null as TEXT) as 
    
    spras
    
 , 
    cast(null as TEXT) as 
    
    stcd1
    
 , 
    cast(null as TEXT) as 
    
    stcd2
    
 , 
    cast(null as TEXT) as 
    
    stcd3
    
 , 
    cast(null as TEXT) as 
    
    stcd4
    
 , 
    cast(null as TEXT) as 
    
    stcd5
    
 , 
    cast(null as TEXT) as 
    
    stcdt
    
 , 
    cast(null as TEXT) as 
    
    stceg
    
 , 
    cast(null as TEXT) as 
    
    stkza
    
 , 
    cast(null as TEXT) as 
    
    stkzn
    
 , 
    cast(null as TEXT) as 
    
    stkzu
    
 , 
    cast(null as TEXT) as 
    
    stras
    
 , 
    cast(null as TEXT) as 
    
    suframa
    
 , 
    cast(null as TEXT) as 
    
    tdt
    
 , 
    cast(null as TEXT) as 
    
    telbx
    
 , 
    cast(null as TEXT) as 
    
    telf1
    
 , 
    cast(null as TEXT) as 
    
    telf2
    
 , 
    cast(null as TEXT) as 
    
    telfx
    
 , 
    cast(null as TEXT) as 
    
    teltx
    
 , 
    cast(null as TEXT) as 
    
    telx1
    
 , 
    cast(null as TEXT) as 
    
    txjcd
    
 , 
    cast(null as TEXT) as 
    
    txlw1
    
 , 
    cast(null as TEXT) as 
    
    txlw2
    
 , 
    cast(null as TEXT) as 
    
    uf
    
 , 
    cast(null as TEXT) as 
    
    umjah
    
 , 
    cast(null as numeric(28,6)) as 
    
    umsa1
    
 , 
    cast(null as numeric(28,6)) as 
    
    umsat
    
 , 
    cast(null as TEXT) as 
    
    updat
    
 , 
    cast(null as TEXT) as 
    
    uptim
    
 , 
    cast(null as TEXT) as 
    
    uwaer
    
 , 
    cast(null as TEXT) as 
    
    vbund
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 , 
    cast(null as TEXT) as 
    
    xcpdk
    
 , 
    cast(null as TEXT) as 
    
    xicms
    
 , 
    cast(null as TEXT) as 
    
    xknza
    
 , 
    cast(null as TEXT) as 
    
    xsubt
    
 , 
    cast(null as TEXT) as 
    
    xxipi
    
 , 
    cast(null as TEXT) as 
    
    xzemp
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_dpoint
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_i_no_lyr
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_load_pref
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_matpal
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_one_mat
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_one_sort
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_pal_ul
    
 , 
    cast(null as numeric(28,6)) as 
    
    _vso_r_palhgt
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_pk_mat
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_uld_side
    
 , 
    cast(null as TEXT) as 
    
    _xlso_client
    
 , 
    cast(null as TEXT) as 
    
    _xlso_customer
    
 , 
    cast(null as TEXT) as 
    
    _xlso_partner
    
 , 
    cast(null as TEXT) as 
    
    _xlso_pref_pay
    
 , 
    cast(null as TEXT) as 
    
    _xlso_sysid
    
 


    from base
),

final as (

    select
        _vso_r_dpoint,
        _vso_r_i_no_lyr,
        _vso_r_load_pref,
        _vso_r_matpal,
        _vso_r_one_mat,
        _vso_r_one_sort,
        _vso_r_pal_ul,
        _vso_r_palhgt,
        _vso_r_pk_mat,
        _vso_r_uld_side,
        _xlso_client,
        _xlso_customer,
        _xlso_partner,
        _xlso_pref_pay,
        _xlso_sysid,
        cast(mandt as TEXT) as mandt,
        cast(kunnr as TEXT) as kunnr,
        pmt_office,
        brsch,
        katr9,
        uwaer,
        kdkg1,
        pson3,
        bran4,
        ort02,
        fiskn,
        konzs,
        etikg,
        psoo2,
        sperz,
        katr4,
        telx1,
        crtn,
        dtaws,
        pstl2,
        datlt,
        rne,
        name4,
        xzemp,
        kukla,
        name2,
        bahne,
        psohs,
        duns4,
        kdkg2,
        oidrc,
        bran5,
        umsat,
        stcd3,
        uf,
        txlw1,
        psoo3,
        rnedate,
        begru,
        katr5,
        stcdt,
        duns,
        updat,
        katr10,
        dear1,
        inspatdebi,
        periv,
        kdkg3,
        abrvw,
        rg,
        stcd4,
        loevm,
        txlw2,
        lifnr,
        psoo4,
        counc,
        telfx,
        stcd2,
        inspbydebi,
        dear2,
        stcd1,
        ort01,
        oid_poreqd,
        kdkg4,
        cvp_xblck,
        faksd,
        ktokd,
        telbx,
        legalnat,
        stras,
        ccc01,
        dtams,
        psoo5,
        j_1kftind,
        stkzn,
        exp,
        psotl,
        dear3,
        xxipi,
        niels,
        umsa1,
        bahns,
        bubkz,
        kdkg5,
        knurl,
        xknza,
        dear6,
        pfort,
        stcd5,
        cityc,
        ccc02,
        ric,
        land1,
        umjah,
        fee_schedule,
        dear4,
        erdat,
        teltx,
        ccc03,
        oipbl,
        rgdate,
        anred,
        ekont,
        vbund,
        psost,
        knrza,
        dear5,
        psofg,
        jmjah,
        tdt,
        bbbnr,
        regio,
        alc,
        aufsd,
        ccc04,
        lifsd,
        cassd,
        werks,
        katr6,
        psois,
        adrnr,
        civve,
        stkzu,
        fityp,
        bran1,
        psovn,
        comsize,
        j_1kfrepre,
        mcod1,
        katr1,
        hzuor,
        xicms,
        indtyp,
        xcpdk,
        lzone,
        sortl,
        katr7,
        gform,
        pson1,
        bran2,
        stceg,
        sperr,
        locco,
        uptim,
        cnae,
        mcod2,
        ernam,
        txjcd,
        katr2,
        confs,
        telf1,
        j_1kftbus,
        spras,
        bbsnr,
        xsubt,
        katr8,
        jmzah,
        nodel,
        decregpc,
        duefl,
        pson2,
        cfopc,
        pfach,
        icmstaxpay,
        bran3,
        suframa,
        exabl,
        pstlz,
        stkza,
        psoo1,
        ktocd,
        telf2,
        knazk,
        milve,
        katr3,
        mcod3,
        rpmkr,
        name3,
        name1,
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_sap_archived

    from fields
)

select *
from final
