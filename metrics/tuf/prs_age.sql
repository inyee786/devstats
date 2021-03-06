create temp table prs as
select pr.id, pr.created_at, pr.merged_at
from
  gha_pull_requests pr
where
  pr.created_at >= '{{from}}'
  and pr.created_at < '{{to}}'
  and pr.event_id = (
    select i.event_id from gha_pull_requests i where i.id = pr.id order by i.updated_at desc limit 1
  );

create temp table prs_groups as
select r.repo_group,
  pr.id,
  pr.created_at,
  pr.merged_at as merged_at
from
  gha_pull_requests pr,
  gha_repos r
where
  r.id = pr.dup_repo_id
  and r.repo_group is not null
  and pr.created_at >= '{{from}}'
  and pr.created_at < '{{to}}'
  and pr.event_id = (
    select i.event_id from gha_pull_requests i where i.id = pr.id order by i.updated_at desc limit 1
  );

create temp table tdiffs as
select id, extract(epoch from coalesce(merged_at - created_at, now() - created_at)) / 3600 as age
from prs;

create temp table tdiffs_groups as
select repo_group, id, extract(epoch from coalesce(merged_at - created_at, now() - created_at)) / 3600 as age
from prs_groups;

select
  'prs_age;All;number,median' as name,
  round(count(distinct id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  tdiffs
union select 'prs_age;' || repo_group || ';number,median' as name,
  round(count(distinct id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  tdiffs_groups
group by
  repo_group
order by
  num desc,
  name asc
;

drop table tdiffs_groups;
drop table prs_groups;
drop table tdiffs;
drop table prs;
