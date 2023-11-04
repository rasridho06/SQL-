select
  date(application_disbursed_time) as disburse_date,
  date(application_disbursed_time, "Asia/Jakarta") as disburse_date_timezione,
  time(application_disbursed_time) as disburse_time,--without 24 hour
  time(application_disbursed_time,"Asia/Jakarta") as disburse_time_timezone, --using indonesia time zone 24 Hour 
  cast(tenor_in_days AS INT64) as tenor, --cast is function to reform data type, tenor_in_day was string and reform to integer data/whole number/bilangan bulat
  date_add(date(application_disbursed_time), interval cast(tenor_in_days AS INT64) day) as maturity_date, --date_add digunakan untuk menambahkan tanggal, setelah interval harus bilangan bulat
  date_trunc(date(application_disbursed_time), month) as month1,--diambil tanggal pertama dari tiap bulan
  extract(month from date(application_disbursed_time)) as  month2, --mengambil bulan pada tiap tanggal format "mm"
  cast(date(application_disbursed_time) as string format "month") as month3,
  date_diff(date_add(date(application_disbursed_time), interval cast(tenor_in_days AS INT64) day), date(application_disbursed_time), Day) as tenor_in_day2, --date_diff to calculate aggregate from latest date to early date, dari tgl jatuh tempo ke tgl disburse selisih berapa hari?
  coalesce(concat(total_quantity," " ,order_unit),"Unidentified") as quantity_per_unit,
  length(id) as length_id,
  split(replace(app_initial_code, ".","-"),"-") as all_loan_id_split, --untuk menggunakan multiple split perlu direplace terlebih dahulu dengan delimitter yang sama lalu displit
  split(replace(app_initial_code, ".","-"),"-")[offset(0)] as EF_split,--[offset,(0)] digunakan untuk membuat kolom baru disebelahnya, 0 jika kolom berada pada urutan pertama setelah kolom yang displit
  split(replace(app_initial_code, ".","-"),"-")[offset(1)] as short_name_split, --[offset,(1)] digunakan untuk membuat kolom baru disebelahnya, 1 jika kolom berada pada urutan kedua setelah kolom yang displit, begitu seterusnya
  (select
    sum(disbursement_amount)
  from
    `alami-group-data.p2p_access.dim_application`
  where
    loan_product_type="EF-Indirect"
  and
    (company_id = "2c91808274029f1c017402f293560005" or company_id = "2c918082835230120183547eb56906dd")) as total_disburse_MTN_KBX --subqueries tidak bisa 1 single value, perlu aggregate function
from
  `alami-group-data.p2p_access.dim_ecofin_application`
where
  application_disbursed_time is not null
