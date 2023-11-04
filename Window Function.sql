--window function
--bisa digunakan sebagai alternatif group by
with window_product as
(
select
  distinct product_type_description as product_type,
sum(disbursement_amount) over (partition by product_type_description) as total_disburse_per_product,
  sum(disbursement_amount*alami_margin_pct/100) over (partition by product_type_description) as total_mpf_per_product,
from
  `group-data.p2p_access.dim_application`
where
  portfolio_status_id="14"
order by 2 desc
)

,contribution as
(
select
  wp.product_type as product_type,
  wp.total_disburse_per_product as disburse_per_product,
  round(wp.total_disburse_per_product/sum(da.disbursement_amount),2)*100 as contribution
from
  `group-data.p2p_access.dim_application` as da
cross join window_product as wp
where
  portfolio_status_id="14"
group by 1,2
)

, application as
(
select
  date_trunc(date(disburse_time,"Asia/Jakarta"),month) as disburse_date,
  product_type_description as product,
  sum(disbursement_amount) as disbursement,
  sum(disbursement_amount*alami_margin_pct/100) as mpf
from
  `group-data.p2p_access.dim_application`
where
  portfolio_status_id="14"
and
  disburse_time is not null
group by 1,2
order by 1
)

select
  ap.disburse_date,
  ap.product,
  ap.disbursement,
  sum(ap.disbursement) over (partition by ap.product order by ap.disburse_date) as running_total,
  sum(ap.disbursement) over (partition by ap.disburse_date) as month_total,
  sum(ap.mpf) over (partition by ap.disburse_date) as mpf_month_total,
  round((sum(ap.disbursement) / sum(ap.disbursement) over (partition by ap.disburse_date))*100,2) as contribution,
  ap.mpf,
  round((sum(ap.mpf) / sum(ap.mpf) over (partition by ap.disburse_date))*100,2) as mpf_contribution,
  --menghitung total disbursemen pada masing2 product pada bulan berjalan dibagi total disbursement pada bulan berjalan
  --round((wp.total_disburse_per_product/ sum (wp.total_disburse_per_product) over (partition by ap.disburse_date))*100,2) contribution
from
  application as ap
left join
  window_product as wp on ap.product = wp.product_type
inner join
  contribution as cb on wp.product_type = cb.product_type
group by 1,2,3,8
order by 1
