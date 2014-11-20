mysql-permute-indexes
=====================

**Summary**

Generate all valid index statements for EXPLAIN to optimize complex queries automatically.

**Example**

<pre>
$ permute_indexes.pl | tee permute_indexes.txt
   alter table t1 add index idx_jb_001 (c1,c3);
   alter table t1 add index idx_jb_002 (c1,c2,c3);
   alter table t1 add index idx_jb_003 (c1,c3,c2);
   [...]
   alter table t2 add index idx_jb_007 (c4,c5);
   [...]

$ mysql -h dev -u root -p test <permute_indexes.txt

$ mysql -h dev -u root -p test
  mysql> explain select * from t1, t2 where c1=c4 and c1=? and c2=? and c3=? and c5=?;
  Table | Key
  ------------------
  t1    | idx_jb_002
  t2    | idx_jb_007

(Now drop all the auto-generated indexes except idx_jb_002 and idx_jb_007.)
</pre>
