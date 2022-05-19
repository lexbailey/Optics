section \<open> Scene Spaces \<close>

theory Scene_Spaces
  imports Scenes
begin

subsection \<open> Preliminaries \<close>

abbreviation foldr_scene :: "'a scene list \<Rightarrow> 'a scene" ("\<Squnion>\<^sub>S") where
"foldr_scene as \<equiv> foldr (\<squnion>\<^sub>S) as \<bottom>\<^sub>S"

lemma pairwise_compat_foldr: 
  "\<lbrakk> pairwise (##\<^sub>S) (set as); \<forall> b \<in> set as. a ##\<^sub>S b \<rbrakk> \<Longrightarrow> a ##\<^sub>S \<Squnion>\<^sub>S as"
  apply (induct as)
   apply (simp)
  apply (auto simp add: pairwise_insert scene_union_pres_compat)
  done

lemma foldr_scene_indep:
  "\<lbrakk> pairwise (##\<^sub>S) (set as); \<forall> b \<in> set as. a \<bowtie>\<^sub>S b \<rbrakk> \<Longrightarrow> a \<bowtie>\<^sub>S \<Squnion>\<^sub>S as"
  apply (induct as)
   apply (simp)
  apply (auto simp add: pairwise_insert)
  by (smt (verit, ccfv_threshold) scene_indep_bot scene_indep_override scene_override_union scene_union_incompat)

lemma foldr_compat_dist:
  "pairwise (##\<^sub>S) (set as) \<Longrightarrow> foldr (\<squnion>\<^sub>S) (map (\<lambda>a. a ;\<^sub>S x) as) \<bottom>\<^sub>S = \<Squnion>\<^sub>S as ;\<^sub>S x"
  apply (induct as)
   apply (simp)
  apply (auto simp add: pairwise_insert)
  apply (metis pairwise_compat_foldr scene_compat_refl scene_union_comp_distl)
  done  

lemma foldr_scene_union_add_tail:
  "\<lbrakk> pairwise (##\<^sub>S) (set xs); \<forall> x\<in>set xs. x ##\<^sub>S b \<rbrakk> \<Longrightarrow> \<Squnion>\<^sub>S xs \<squnion>\<^sub>S b = foldr (\<squnion>\<^sub>S) xs b"
  apply (induct xs)
   apply (simp)
  apply (simp)
  apply (subst scene_union_assoc[THEN sym])
  apply (auto simp add: pairwise_insert)
  using pairwise_compat_foldr scene_compat_refl apply blast
  apply (meson pairwise_compat_foldr scene_compat_sym)
  done

corollary foldr_scene_union_removeAll:
"\<lbrakk> pairwise (##\<^sub>S) (set xs); x \<in> set xs \<rbrakk> \<Longrightarrow> \<Squnion>\<^sub>S (removeAll x xs) \<squnion>\<^sub>S x = \<Squnion>\<^sub>S xs"
  apply (induct xs)
   apply simp
  apply (auto simp add: pairwise_insert scene_union_commute)
    apply (smt (verit, ccfv_threshold) member_remove pairwise_compat_foldr pairwise_def removeAll_id 
      remove_code(1) scene_compat_refl scene_union_assoc scene_union_idem)
   apply (metis Diff_subset pairwise_alt pairwise_compat_foldr pairwise_mono scene_compat_refl
      scene_union_assoc scene_union_idem set_removeAll)
  by (smt (z3) Diff_subset pairwise_alt pairwise_compat_foldr pairwise_mono scene_compat.rep_eq 
      scene_union_assoc scene_union_commute set_removeAll subset_code(1))

lemma foldr_scene_union_eq_sets:
  assumes "pairwise (##\<^sub>S) (set xs)" "set xs = set ys"
  shows "\<Squnion>\<^sub>S xs = \<Squnion>\<^sub>S ys"
using assms proof (induct xs arbitrary: ys)
  case Nil
  then show ?case
    by simp
next
  case (Cons a xs)
  hence ys: "set ys = insert a (set (removeAll a ys))"
    by (auto)
  then show ?case
    by (metis (no_types, lifting) Cons.hyps Cons.prems(1) Cons.prems(2) Diff_insert_absorb foldr_scene_union_removeAll insertCI insert_absorb list.simps(15) pairwise_insert set_removeAll)
qed

lemma pairwise_Diff: "pairwise R A \<Longrightarrow> pairwise R (A - B)"
  using pairwise_mono by fastforce

lemma foldr_scene_removeAll:
  assumes "pairwise (##\<^sub>S) (set xs)"
  shows "x \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x xs) = x \<squnion>\<^sub>S \<Squnion>\<^sub>S xs"
  by (smt (verit) assms foldr_scene_union_removeAll pairwise_Diff pairwise_alt pairwise_compat_foldr removeAll_id scene_compat_refl scene_union_assoc scene_union_commute scene_union_idem set_removeAll)

lemma pairwise_Collect: "pairwise R A \<Longrightarrow> pairwise R {x \<in> A. P x}"
  by (simp add: pairwise_def)

lemma removeAll_overshadow_filter: 
  "removeAll x (filter (\<lambda>xa. xa \<notin> A - {x}) xs) = removeAll x (filter (\<lambda> xa. xa \<notin> A) xs)"
  apply (simp add: removeAll_filter_not_eq)
  apply (rule filter_cong)
   apply (simp)
  apply auto
  done

corollary foldr_scene_union_filter:
  assumes "pairwise (##\<^sub>S) (set xs)" "set ys \<subseteq> set xs"
  shows "\<Squnion>\<^sub>S xs = \<Squnion>\<^sub>S (filter (\<lambda>x. x \<notin> set ys) xs) \<squnion>\<^sub>S \<Squnion>\<^sub>S ys"
using assms proof (induct xs arbitrary: ys)
  case Nil
  then show ?case by (simp)
next
  case (Cons x xs)
  show ?case
  proof (cases "x \<in> set ys")
    case True
    with Cons have 1: "set ys - {x} \<subseteq> set xs"
      by (auto)
    have "\<Squnion>\<^sub>S (x # xs) = x \<squnion>\<^sub>S \<Squnion>\<^sub>S xs"
      by simp
    also have "... = x \<squnion>\<^sub>S (\<Squnion>\<^sub>S (filter (\<lambda>xa. xa \<notin> set ys - {x}) xs) \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x ys))"
      using 1 Cons(1)[where ys="removeAll x ys"] Cons(2) by (simp add: pairwise_insert)    
    also have "... = (x \<squnion>\<^sub>S \<Squnion>\<^sub>S (filter (\<lambda>xa. xa \<notin> set ys - {x}) xs)) \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x ys)"
      apply (subst scene_union_assoc)
         apply (rule pairwise_compat_foldr)
      apply (simp add: pairwise_Collect Cons)
      apply (smt (verit, ccfv_threshold) Cons.prems(1) mem_Collect_eq pairwise_def pairwise_subset set_subset_Cons)
      apply (metis Cons.prems(1) filter_is_subset list.simps(15) pairwise_insert scene_compat_refl subsetD)
      apply (metis Cons.prems(1) Cons.prems(2) True foldr_scene_removeAll foldr_scene_union_removeAll pairwise_subset scene_compat_bot(2) scene_union_commute scene_union_incompat scene_union_unit(1))
      apply (smt (z3) Cons.prems(1) Cons.prems(2) Diff_subset filter_is_subset pairwise_compat_foldr pairwise_def scene_compat_refl scene_compat_sym set_removeAll set_subset_Cons subset_code(1))
      apply simp
      done
    also have "... = (x \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x (filter (\<lambda>xa. xa \<notin> set ys - {x}) xs))) \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x ys)"
      apply (subst foldr_scene_removeAll[THEN sym])
       apply (meson Cons.prems(1) filter_is_subset pairwise_subset set_subset_Cons)
      apply (simp)
      done
    also have "... = (x \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x (filter (\<lambda>xa. xa \<notin> set ys) xs))) \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x ys)"
      by (simp only: removeAll_overshadow_filter)
    also have "... = (x \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x (filter (\<lambda>xa. xa \<notin> set ys) (x # xs)))) \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x ys)"
      by simp
    also have "... = (x \<squnion>\<^sub>S \<Squnion>\<^sub>S (filter (\<lambda>xa. xa \<notin> set ys) (x # xs))) \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x ys)"
      by (simp add: True)
    also have "... = (\<Squnion>\<^sub>S (filter (\<lambda>xa. xa \<notin> set ys) (x # xs)) \<squnion>\<^sub>S x) \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x ys)"
      by (simp add: scene_union_commute)
    also have "... = \<Squnion>\<^sub>S (filter (\<lambda>xa. xa \<notin> set ys) (x # xs)) \<squnion>\<^sub>S (x \<squnion>\<^sub>S \<Squnion>\<^sub>S (removeAll x ys))"
      apply (subst scene_union_assoc)
      apply (simp_all add: True)
      apply (metis (no_types, lifting) Cons.prems(1) filter_is_subset list.simps(15) pairwise_compat_foldr pairwise_insert pairwise_subset scene_compat_refl scene_compat_sym subsetD)
      apply (smt (z3) Cons.prems(1) Cons.prems(2) DiffE filter_is_subset pairwise_compat_foldr pairwise_def scene_compat_refl scene_compat_sym set_removeAll set_subset_Cons subset_code(1))
      apply (metis Cons.prems(1) Cons.prems(2) True foldr_scene_removeAll foldr_scene_union_removeAll pairwise_subset scene_compat_bot(2) scene_union_commute scene_union_incompat scene_union_unit(1))
      done
    also have "... = \<Squnion>\<^sub>S (filter (\<lambda>xa. xa \<notin> set ys) (x # xs)) \<squnion>\<^sub>S \<Squnion>\<^sub>S ys"
      by (metis (no_types, lifting) Cons.prems(1) Cons.prems(2) True foldr_scene_union_removeAll pairwise_subset scene_union_commute)
    finally show ?thesis .
  next
  next
    case False
    with Cons(2-3) have "set ys \<subseteq> set xs"
      by auto
    with False Cons(1)[of ys] Cons(2-3) show ?thesis 
      apply (auto simp add: pairwise_insert)
      apply (subst scene_union_assoc)
      apply (simp_all)
      apply (metis (no_types, lifting) filter_is_subset filter_set member_filter pairwise_compat_foldr pairwise_subset scene_compat_refl)
      apply (metis pairwise_compat_foldr pairwise_subset subset_code(1))
      apply (metis (no_types, lifting) foldr_append foldr_scene_union_eq_sets scene_indep_bot scene_indep_compat scene_union_incompat set_append subset_Un_eq)
      done
  qed
qed

subsection \<open> Predicates \<close>

definition scene_indeps :: "'s scene set \<Rightarrow> bool" where
"scene_indeps = pairwise (\<bowtie>\<^sub>S)"

definition scene_span :: "'s scene list \<Rightarrow> bool" where
"scene_span S = (foldr (\<squnion>\<^sub>S) S \<bottom>\<^sub>S = \<top>\<^sub>S)"

text \<open> cf. @{term finite_dimensional_vector_space}, which scene spaces are based on. \<close>  

subsection \<open> Scene space class \<close>

class scene_space = 
  fixes Vars :: "'a scene list"
  assumes idem_scene_Vars: "\<And> x. x \<in> set Vars \<Longrightarrow> idem_scene x"
  and indep_Vars: "scene_indeps (set Vars)"
  and span_Vars: "scene_span Vars"
begin

lemma scene_space_compats [simp]: "pairwise (##\<^sub>S) (set Vars)"
  by (metis local.indep_Vars pairwise_alt scene_indep_compat scene_indeps_def)

inductive_set scene_space :: "'a scene set" where
bot_scene_space [intro]: "\<bottom>\<^sub>S \<in> scene_space" | 
Vars_scene_space [intro]: "x \<in> set Vars \<Longrightarrow> x \<in> scene_space" |
union_scene_space [intro]: "\<lbrakk> x \<in> scene_space; y \<in> scene_space \<rbrakk> \<Longrightarrow> x \<squnion>\<^sub>S y \<in> scene_space"

lemma idem_scene_space: "a \<in> scene_space \<Longrightarrow> idem_scene a"
  by (induct rule: scene_space.induct)
     (auto simp add: idem_scene_Vars)

lemma set_Vars_scene_space [simp]: "set Vars \<subseteq> scene_space"
  by blast

lemma scene_space_foldr: "set xs \<subseteq> scene_space \<Longrightarrow> foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S \<in> scene_space"
  by (induction xs, auto)

lemma top_scene_space: "\<top>\<^sub>S \<in> scene_space"
proof -
  have "\<top>\<^sub>S = foldr (\<squnion>\<^sub>S) Vars \<bottom>\<^sub>S"
    using span_Vars by (simp add: scene_span_def)
  also have "... \<in> scene_space"
    by (simp add: scene_space_foldr)
  finally show ?thesis .
qed

lemma Vars_compat_scene_space: "\<lbrakk> b \<in> scene_space; x \<in> set Vars \<rbrakk> \<Longrightarrow> x ##\<^sub>S b"
proof (induct b rule: scene_space.induct)
  case bot_scene_space
  then show ?case
    by (metis scene_compat_refl scene_union_incompat scene_union_unit(1)) 
next
  case (Vars_scene_space a)
  then show ?case
    by (metis local.indep_Vars pairwiseD scene_compat_refl scene_indep_compat scene_indeps_def)
next
  case (union_scene_space a b)
  then show ?case
    using scene_union_pres_compat by blast
qed

lemma scene_space_compat: "\<lbrakk> a \<in> scene_space; b \<in> scene_space \<rbrakk> \<Longrightarrow> a ##\<^sub>S b"
proof (induct rule: scene_space.induct)
  case bot_scene_space
  then show ?case
    by simp
next
  case (Vars_scene_space x)
  then show ?case
    by (simp add: Vars_compat_scene_space) 
next
  case (union_scene_space x y)
  then show ?case
    using scene_compat_sym scene_union_pres_compat by blast
qed

corollary scene_space_union_assoc:
  assumes "x \<in> scene_space" "y \<in> scene_space" "z \<in> scene_space"
  shows "x \<squnion>\<^sub>S (y \<squnion>\<^sub>S z) = (x \<squnion>\<^sub>S y) \<squnion>\<^sub>S z"
  by (simp add: assms scene_space_compat scene_union_assoc)

lemma scene_space_vars_decomp: "a \<in> scene_space \<Longrightarrow> \<exists>xs. set xs \<subseteq> set Vars \<and> foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S = a"
proof (induct rule: scene_space.induct)
  case bot_scene_space
  then show ?case
    by (simp add: exI[where x="[]"])
next
  case (Vars_scene_space x)
  show ?case
    apply (rule exI[where x="[x]"])
    using Vars_scene_space by simp
next
  case (union_scene_space x y)
  then obtain xs ys where xsys: "set xs \<subseteq> set Vars \<and> foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S = x"
                                "set ys \<subseteq> set Vars \<and> foldr (\<squnion>\<^sub>S) ys \<bottom>\<^sub>S = y"
    by blast+
  show ?case
    apply (rule exI[where x="xs @ ys"])
    apply (auto simp: xsys)
    by (metis (full_types) Vars_compat_scene_space foldr_scene_union_add_tail pairwise_subset 
        scene_space_compats subsetD union_scene_space.hyps(3) xsys(1))
 qed

lemma scene_space_vars_decomp_iff: "a \<in> scene_space \<longleftrightarrow> (\<exists>xs. set xs \<subseteq> set Vars \<and> a = foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S)"
  apply (auto simp add: scene_space_vars_decomp scene_space.Vars_scene_space scene_space_foldr)
  apply (simp add: scene_space.Vars_scene_space scene_space_foldr subset_eq)
  using scene_space_vars_decomp apply auto[1]
  by (meson dual_order.trans scene_space_foldr set_Vars_scene_space)

lemma "fold (\<squnion>\<^sub>S) (map (\<lambda>x. x ;\<^sub>S a) Vars) b = \<lbrakk>a\<rbrakk>\<^sub>\<sim> \<squnion>\<^sub>S b"
  oops

lemma Vars_indep_foldr: 
  assumes "x \<in> set Vars" "set xs \<subseteq> set Vars"
  shows "x \<bowtie>\<^sub>S foldr (\<squnion>\<^sub>S) (removeAll x xs) \<bottom>\<^sub>S"
proof (rule foldr_scene_indep)
  show "pairwise (##\<^sub>S) (set (removeAll x xs))"
    by (simp, metis Diff_subset assms(2) pairwise_mono scene_space_compats)
  from assms show "\<forall>b\<in>set (removeAll x xs). x \<bowtie>\<^sub>S b"
    by (simp)
       (metis DiffE insertI1 local.indep_Vars pairwiseD scene_indeps_def subset_iff)
qed

lemma Vars_indeps_foldr:
  assumes "set xs \<subseteq> set Vars"
  shows "foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S \<bowtie>\<^sub>S foldr (\<squnion>\<^sub>S) (filter (\<lambda>x. x \<notin> set xs) Vars) \<bottom>\<^sub>S"
  apply (rule foldr_scene_indep)
   apply (meson filter_is_subset pairwise_subset scene_space_compats)
  apply (simp)
  apply auto
  apply (rule scene_indep_sym)
  apply (metis (no_types, lifting) assms foldr_scene_indep local.indep_Vars pairwiseD pairwise_mono scene_indeps_def scene_space_compats subset_iff)
  done
  
lemma uminus_var_other_vars:
  assumes "x \<in> set Vars"
  shows "- x = foldr (\<squnion>\<^sub>S) (removeAll x Vars) \<bottom>\<^sub>S"
proof (rule scene_union_indep_uniq[where Z="x"])
    show "idem_scene (foldr (\<squnion>\<^sub>S) (removeAll x Vars) \<bottom>\<^sub>S)"
      by (metis Diff_subset idem_scene_space order_trans scene_space_foldr set_Vars_scene_space set_removeAll)
    show "idem_scene x" "idem_scene (-x)"
      by (simp_all add: assms local.idem_scene_Vars)
    show "foldr (\<squnion>\<^sub>S) (removeAll x Vars) \<bottom>\<^sub>S \<bowtie>\<^sub>S x"
      using Vars_indep_foldr assms scene_indep_sym by blast
    show "- x \<bowtie>\<^sub>S x"
      using scene_indep_self_compl scene_indep_sym by blast
    show "- x \<squnion>\<^sub>S x = foldr (\<squnion>\<^sub>S) (removeAll x Vars) \<bottom>\<^sub>S \<squnion>\<^sub>S x"
      by (metis \<open>idem_scene (- x)\<close> assms foldr_scene_union_removeAll local.span_Vars scene_space_compats scene_span_def scene_union_compl uminus_scene_twice)
qed

lemma uminus_vars_other_vars:
  assumes "set xs \<subseteq> set Vars"
  shows "- \<Squnion>\<^sub>S xs = \<Squnion>\<^sub>S (filter (\<lambda>x. x \<notin> set xs) Vars)"
proof (rule scene_union_indep_uniq[where Z="foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S"])
  show "idem_scene (- foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S)" "idem_scene (foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S)"
    using assms idem_scene_space idem_scene_uminus scene_space_vars_decomp_iff by blast+
  show "idem_scene (foldr (\<squnion>\<^sub>S) (filter (\<lambda>x. x \<notin> set xs) Vars) \<bottom>\<^sub>S)"
    by (meson filter_is_subset idem_scene_space scene_space_vars_decomp_iff)
  show "- foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S \<bowtie>\<^sub>S foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S"
    by (metis scene_indep_self_compl uminus_scene_twice)
  show "foldr (\<squnion>\<^sub>S) (filter (\<lambda>x. x \<notin> set xs) Vars) \<bottom>\<^sub>S \<bowtie>\<^sub>S foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S"
    using Vars_indeps_foldr assms scene_indep_sym by blast
  show "- \<Squnion>\<^sub>S xs \<squnion>\<^sub>S \<Squnion>\<^sub>S xs = \<Squnion>\<^sub>S (filter (\<lambda>x. x \<notin> set xs) Vars) \<squnion>\<^sub>S \<Squnion>\<^sub>S xs"
    using foldr_scene_union_filter[of Vars xs, THEN sym]
    by (simp add: assms)
       (metis \<open>idem_scene (- \<Squnion>\<^sub>S xs)\<close> local.span_Vars scene_span_def scene_union_compl uminus_scene_twice)
qed

lemma scene_space_uminus: "\<lbrakk> a \<in> scene_space \<rbrakk> \<Longrightarrow> - a \<in> scene_space"
  by (auto simp add: scene_space_vars_decomp_iff uminus_vars_other_vars)
     (metis filter_is_subset)

lemma scene_space_inter: "\<lbrakk> a \<in> scene_space; b \<in> scene_space \<rbrakk> \<Longrightarrow> a \<sqinter>\<^sub>S b \<in> scene_space"
  by (simp add: inf_scene_def scene_space.union_scene_space scene_space_uminus)

lemma scene_union_foldr_remove_element:
  assumes "set xs \<subseteq> set Vars"
  shows "a \<squnion>\<^sub>S foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S = a \<squnion>\<^sub>S foldr (\<squnion>\<^sub>S) (removeAll a xs) \<bottom>\<^sub>S"
using assms proof (induct xs)
  case Nil
  then show ?case by simp
next
  case (Cons a xs)
  then show ?case apply auto
    apply (metis order_trans scene_space.Vars_scene_space scene_space_foldr scene_space_union_assoc scene_union_idem set_Vars_scene_space)
    apply (smt (verit, best) Diff_subset dual_order.trans removeAll_id scene_space_foldr scene_space_union_assoc scene_union_commute set_Vars_scene_space set_removeAll subset_iff)
    done
qed

lemma scene_union_foldr_Cons_removeAll:
  assumes "set xs \<subseteq> set Vars" "a \<in> set xs"
  shows "foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S = foldr (\<squnion>\<^sub>S) (a # removeAll a xs) \<bottom>\<^sub>S"
  by (metis assms(1) assms(2) foldr_scene_union_eq_sets insert_Diff list.simps(15) pairwise_subset scene_space_compats set_removeAll)

lemma scene_union_foldr_Cons_removeAll':
  assumes "set xs \<subseteq> set Vars" "a \<in> set Vars"
  shows "foldr (\<squnion>\<^sub>S) (a # xs) \<bottom>\<^sub>S = foldr (\<squnion>\<^sub>S) (a # removeAll a xs) \<bottom>\<^sub>S"
  by (simp add: assms(1) scene_union_foldr_remove_element)

lemma scene_in_foldr: "\<lbrakk> a \<in> set xs; set xs \<subseteq> set Vars \<rbrakk> \<Longrightarrow> a \<subseteq>\<^sub>S foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S"
  apply (induct xs)
   apply (simp)
  apply (subst scene_union_foldr_Cons_removeAll')
    apply simp
   apply simp
  apply (auto)
  apply (rule scene_union_ub)
    apply (metis Diff_subset dual_order.trans idem_scene_space scene_space_vars_decomp_iff set_removeAll)
  using Vars_indep_foldr apply blast
  apply (metis Vars_indep_foldr foldr_scene_union_removeAll idem_scene_space local.idem_scene_Vars order.trans pairwise_mono removeAll_id scene_indep_sym scene_space_compats scene_space_foldr scene_union_commute scene_union_ub set_Vars_scene_space subscene_trans)
  done

lemma scene_union_foldr_subset:
  assumes "set xs \<subseteq> set ys" "set ys \<subseteq> set Vars"
  shows "foldr(\<squnion>\<^sub>S) xs \<bottom>\<^sub>S \<subseteq>\<^sub>S foldr (\<squnion>\<^sub>S) ys \<bottom>\<^sub>S"
using assms proof (induct xs arbitrary: ys)
  case Nil
  then show ?case 
    by (simp add: scene_bot_least)
next
  case (Cons a xs)
  { assume "a \<in> set xs"
    with Cons have "foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S = foldr (\<squnion>\<^sub>S) (a # removeAll a xs) \<bottom>\<^sub>S"
      apply (subst scene_union_foldr_Cons_removeAll)
        apply (auto)
      done
  } note a_in = this
  { assume "a \<notin> set xs"
    then have "a \<squnion>\<^sub>S foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S = foldr (\<squnion>\<^sub>S) (a # xs) \<bottom>\<^sub>S"
      by simp
  } note a_out = this
  show ?case apply (simp)
    apply (cases "a \<in> set xs")
    using a_in Cons apply auto
     apply (metis dual_order.trans scene_union_foldr_remove_element)
    using a_out Cons apply auto
    apply (rule scene_union_mono)
    using scene_in_foldr apply blast
    apply blast
    apply (meson Vars_compat_scene_space dual_order.trans scene_space_foldr set_Vars_scene_space subsetD)
    using local.idem_scene_Vars apply blast
    apply (meson idem_scene_space scene_space_foldr set_Vars_scene_space subset_trans)
    done
qed

lemma union_scene_space_foldrs:
  assumes "set xs \<subseteq> set Vars" "set ys \<subseteq> set Vars"
  shows "(foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S) \<squnion>\<^sub>S (foldr (\<squnion>\<^sub>S) ys \<bottom>\<^sub>S) = foldr (\<squnion>\<^sub>S) (xs @ ys) \<bottom>\<^sub>S"
  using assms
  apply (induct ys)
  apply (simp_all)
  apply (metis Vars_compat_scene_space foldr_scene_union_add_tail local.indep_Vars pairwise_mono scene_indep_compat scene_indeps_def scene_space.Vars_scene_space scene_space.union_scene_space scene_space_foldr subset_eq)
  done

lemma scene_space_ub:
  assumes "a \<in> scene_space" "b \<in> scene_space"
  shows "a \<subseteq>\<^sub>S a \<squnion>\<^sub>S b"
  using assms
  apply (auto simp add: scene_space_vars_decomp_iff union_scene_space_foldrs)
  by (smt (verit, ccfv_SIG) foldr_append scene_union_foldr_subset set_append sup.bounded_iff sup_commute sup_ge2)
  
end

subsection \<open> Frame type \<close>

typedef (overloaded) 'a::scene_space frame = "scene_space :: 'a scene set"
  by blast

setup_lifting type_definition_frame

instantiation frame :: (scene_space) order
begin

lift_definition less_eq_frame :: "'a frame \<Rightarrow> 'a frame \<Rightarrow> bool" is "(\<le>)" .
lift_definition less_frame :: "'a frame \<Rightarrow> 'a frame \<Rightarrow> bool" is "(<)" .

instance
  apply (intro_classes; transfer)
     apply (simp add: less_scene_def)
    apply (simp_all add: less_scene_def subscene_refl)
  using idem_scene_space subscene_trans apply auto[1]
  apply (simp add: idem_scene_space subscene_antisym)
  done

end

find_theorems "(\<squnion>\<^sub>S)" "(\<subseteq>\<^sub>S)"

instantiation frame :: (scene_space) semilattice_sup
begin

lift_definition sup_frame :: "'a frame \<Rightarrow> 'a frame \<Rightarrow> 'a frame" is "(\<squnion>\<^sub>S)"
  by (simp add: union_scene_space)

instance
  apply intro_classes
  apply transfer
  using scene_space_ub apply auto[1]
  apply transfer
   apply (simp add: scene_space_ub scene_union_commute)
  apply transfer
  apply (metis idem_scene_space scene_bot_least scene_union_incompat scene_union_mono)
  done

end

subsection \<open> Alphabet Scene Spaces \<close>

definition alpha_scene_space :: "'s scene list \<Rightarrow> ('a \<Longrightarrow> 's) \<Rightarrow> ('b::scene_space \<Longrightarrow> 's) \<Rightarrow> 's scene list" where
"alpha_scene_space xs b\<^sub>L m\<^sub>L = xs @ map (\<lambda> x. x ;\<^sub>S m\<^sub>L) Vars"

lemma scene_space_class_intro:
  assumes 
    "\<forall> x\<in>set xs. idem_scene x"
    "scene_indeps (set xs)"
    "vwb_lens b\<^sub>L" \<comment> \<open> The base lens \<close>
    "vwb_lens m\<^sub>L" \<comment> \<open> The more lens \<close>
    "b\<^sub>L \<bowtie> m\<^sub>L"
    "\<forall> x\<in>set xs. x \<bowtie>\<^sub>S \<lbrakk>m\<^sub>L\<rbrakk>\<^sub>\<sim>"  
    "foldr (\<squnion>\<^sub>S) xs \<bottom>\<^sub>S = \<lbrakk>b\<^sub>L\<rbrakk>\<^sub>\<sim>"
    "bij_lens (b\<^sub>L +\<^sub>L m\<^sub>L)"
  shows "class.scene_space (alpha_scene_space xs b\<^sub>L m\<^sub>L)"
proof (simp add: alpha_scene_space_def, unfold_locales)
  from assms(5-7) have 1: "(foldr (\<squnion>\<^sub>S) xs \<lbrakk>m\<^sub>L\<rbrakk>\<^sub>\<sim>) = \<top>\<^sub>S"
    by (metis assms(2) assms(3) assms(4) assms(8) foldr_scene_union_add_tail lens_plus_scene lens_scene_top_iff_bij_lens pairwise_alt plus_mwb_lens scene_indep_compat scene_indeps_def vwb_lens_mwb)

  show "\<And>x. x \<in> set (xs @ map (\<lambda>x. x ;\<^sub>S m\<^sub>L) Vars) \<Longrightarrow> idem_scene x"
    using assms(1) idem_scene_Vars by fastforce
  show "scene_indeps (set (xs @ map (\<lambda>x. x ;\<^sub>S m\<^sub>L) Vars))"
    apply (auto simp add: scene_indeps_def pairwise_def)
    apply (metis assms(2) pairwiseD scene_indeps_def)
    using assms(1) assms(6) idem_scene_Vars scene_comp_pres_indep apply blast
    using assms(1) assms(6) idem_scene_Vars scene_comp_pres_indep scene_indep_sym apply blast
    apply (metis indep_Vars pairwiseD scene_comp_indep scene_indeps_def)
    done
  show "scene_span (xs @ map (\<lambda>x. x ;\<^sub>S m\<^sub>L) Vars)"
    apply (simp add: scene_span_def)
    apply (subst foldr_compat_dist)
    apply (simp)
    apply (metis "1" assms(4) scene_comp_top_scene scene_span_def span_Vars)    
    done
qed

find_theorems lens_comp

method alpha_scene_space uses defs =
  (rule scene_space_class.intro
  ,(intro_classes)[1]
  ,unfold defs
  ,rule scene_space_class_intro
  ,simp_all add: scene_indeps_def pairwise_def lens_plus_scene[THEN sym] lens_equiv_scene[THEN sym] lens_equiv_sym)

alphabet test = 
  x :: int
  y :: int 
  z :: int

instantiation test_ext :: (scene_space) scene_space
begin

definition Vars_test_ext :: "'a test_scheme scene list" where
"Vars_test_ext = alpha_scene_space [\<lbrakk>x\<rbrakk>\<^sub>\<sim>, \<lbrakk>y\<rbrakk>\<^sub>\<sim>, \<lbrakk>z\<rbrakk>\<^sub>\<sim>] base\<^sub>L more\<^sub>L"
  
instance by (alpha_scene_space defs: Vars_test_ext_def)

end

end