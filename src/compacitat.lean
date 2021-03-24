import topologia
import .separacio

open topological_space
open set

variables (X : Type) [topological_space X]

/-- A topological space is (quasi)compact if every open covering admits a finite subcovering -/
def is_compact :=
  ∀ 𝒰 : set (set X), (∀ U ∈ 𝒰, is_open U) → 
  (⋃₀ 𝒰 = univ) → (∃ ℱ ⊆ 𝒰, finite ℱ ∧ ⋃₀ℱ = univ)

def is_compact_subset {X : Type} [topological_space X] (S : set X):=
  ∀ 𝒰 : set (set X), (∀ U ∈ 𝒰, is_open U) →
  (S ⊆ ⋃₀ 𝒰) → (∃ ℱ ⊆ 𝒰, finite ℱ ∧ S ⊆ ⋃₀ℱ )

lemma finite_set_is_compact (h : fintype X) : is_compact X :=
begin
  intros I hI huniv,
  exact ⟨I, rfl.subset, finite.of_fintype I, huniv⟩,
end

lemma union_of_compacts_is_compact {A B : set X} (hA : is_compact_subset A) (hB : is_compact_subset B) : is_compact_subset (A ∪ B) :=
begin
  intros I hI huI,
  have hinclAB := union_subset_iff.1 huI,
  obtain ⟨FA, hFA, hhFA⟩ := hA I hI hinclAB.1,
  obtain ⟨FB, hFB, hhFB⟩ := hB I hI hinclAB.2,
  have hunion : A ∪ B ⊆ ⋃₀(FA ∪ FB),
  {
    rw  (sUnion_union FA FB),
    exact union_subset_union hhFA.right hhFB.right,
  },
  exact ⟨FA ∪ FB, union_subset hFA hFB, hhFA.left.union hhFB.left, hunion⟩,
end

lemma empty_is_compact : is_compact_subset (∅ : set X) :=
begin
  intros I hI hhI,
  use ∅,
  exact ⟨ empty_subset I, finite_empty, by tauto⟩,
end

lemma finite_union_of_compacts_is_compact {I : set(set X)} (h : ∀ s ∈ I, is_compact_subset s) (hI : finite I) : is_compact_subset (⋃₀I):=
begin
  revert h,
  apply finite.induction_on hI,
  {
    intros I,
    rw sUnion_empty,
    apply empty_is_compact,
  },
  {
    intros V T hVT hT hUT hs,
    have t : (⋃₀insert V T) = ⋃₀ T ∪ V, by finish,
    have hsT: (∀ (s : set X), s ∈ T → is_compact_subset s),
    {
      intros s hhs,
      exact hs s (mem_insert_of_mem V hhs),
    },
    rw t,
    exact union_of_compacts_is_compact _ (hUT hsT) (hs V (mem_insert V T)),
  }
end

lemma singleton_is_compact (x : X) : is_compact_subset ({x} : set X) :=
begin
  intros I hI hIincl,
  cases (bex_def.mp (hIincl  rfl)) with U hU,
  have hsingUI : {x} ⊆ ⋃₀{U},
  {
    rw (sUnion_singleton U),
    exact singleton_subset_iff.mpr hU.right,
  },
  exact ⟨{U}, singleton_subset_iff.mpr hU.1, finite_singleton U, hsingUI⟩,  
end

lemma finite_subset_is_compact (A : set X): finite A → is_compact_subset A :=
begin
  intro h,
  apply finite.induction_on h,
  apply empty_is_compact,
  intros a s has hsfin hscpt,
  apply union_of_compacts_is_compact,
  apply singleton_is_compact,
  assumption,
end

/-
lemma finite_subset_is_compact_using_choice (A : set X) (h : finite A) : is_compact_subset A :=
begin
  intros I hI huniv,
  have H : ∀ a ∈ A, ∃ ia ∈ I, a ∈ ia, by assumption,
  let f : A → set X := λ ⟨x, hxA⟩, classical.some (H x hxA),
  have hf1 : ∀ (x : X) (hx : x ∈ A), x ∈ (f ⟨x, hx⟩),
  {
    intros x hx,
    have hh := classical.some_spec (H x hx),
    tauto,
  },
  have hf2 : ∀ (x : X) (hx : x ∈ A), (f ⟨x, hx⟩) ∈ I,
  {
    intros x hx,
    have hh := classical.some_spec (H x hx),
    tauto,
  },
  use f '' univ,
  simp,
  split,
  {
    intros i hi,
    simp at hi,
    obtain ⟨x, ⟨hx,h'⟩⟩ := hi,
    subst h',
    tauto,
  },
  split,
  {
    haveI : fintype {x : X // x ∈ A} := finite.fintype h,
    apply finite_range f,
  },
  {
    unfold Union,
    intros x hx,
    unfold supr,
    rw Sup_eq_supr,
    simp,
    use f ⟨x,hx⟩,
    use x,
    use hx,
    tauto,
  }
end
 -/
lemma for_compact_exist_open_disjont {A : set X} [hausdorff_space X] (h : is_compact_subset A) : ∀ (y : X), y ∈ Aᶜ  → 
  (∃ (V : set X), is_open V ∧ V ∩ A = ∅ ∧ y ∈ V) :=
begin
  intros y hy,
  unfold is_compact_subset at h,
  let ter := {T : (set X) × (set X) | is_open T.1 ∧ is_open T.2 ∧ T.1 ∩ T.2 = ∅ ∧ A ∩ T.1 ≠ ∅ ∧ y ∈ T.2},
  let ter1 := {U : set X | ∃(T : (set X) × (set X)), T ∈ ter ∧ T.1 = U},
  have hh : A ⊆ ⋃₀ter1,
  {
    sorry
  },
  have hter1open : ∀ (U : set X), U ∈ ter1 → is_open U,
  {
    intros U hU,
    cases hU with T hT,
    rw← hT.2,
    exact hT.1.1,
  },
  obtain t := h ter1 hter1open hh,
  rcases t with ⟨F, hF, hhF⟩,
  let exter := {V : set X | ∃(T : (set X) × (set X)), T ∈ ter ∧ T.1 ∈ F ∧ T.2 = V},
  have hexter : finite exter,
  {
    sorry
  },
  have hhexter : ∀ (s : set X), s ∈ exter → is_open s,
  {
    intros s hs,
    cases hs with T hT,
    rw ← hT.2.2,
    exact hT.1.2.1,
  },
  have hexterF : ⋂₀exter ∩ ⋃₀ F = ∅,
  {
    apply subset.antisymm,
    {
      intros x hx,
      rcases hx with ⟨hx1,⟨B ,⟨hB1, hB2⟩⟩⟩,
      cases (hF hB1) with T hT,
      rw [← hT.1.2.2.1, hT.2],
      have hT1F : T.1 ∈ F, by rwa hT.2,
      exact ⟨hB2, hx1 T.snd ⟨T, hT.1, hT1F, refl T.2⟩⟩,
    },
      exact (⋂₀exter ∩ ⋃₀ F).empty_subset,
  },
  have hAexter : ⋂₀exter ∩ A =∅,
  {
    apply subset.antisymm,
    {
      rw ← hexterF,
      exact (⋂₀ exter).inter_subset_inter_right hhF.right,
    },
    exact (⋂₀exter ∩ A).empty_subset,
  },
  have hyexter : y ∈ ⋂₀exter,
  {
    intros B hB,
    cases hB with T hT,
    rw ← hT.2.2,
    exact hT.1.2.2.2.2,
  },
  exact ⟨⋂₀exter, open_of_finite_set_opens hexter hhexter, hAexter, hyexter⟩,  
end

lemma compact_in_T2_is_closed {A : set X} [hausdorff_space X] (h : is_compact_subset A) : is_closed A :=
begin
  have hAc : interior Aᶜ = Aᶜ,
  {
    apply subset.antisymm,
      exact interior_is_subset Aᶜ,
    {
      intros x hxA,
      cases (for_compact_exist_open_disjont X h) x hxA with V hV,
      have hVAc : V ⊆ Aᶜ,
      {
        intros y hy,
        have hynA : y ∉ A,
        {
          intro hyA,
          have hyVA : y ∈ V ∩ A, by exact ⟨hy, hyA⟩,
          have hIe : V ∩ A ≠ ∅, by finish,
          exact hIe hV.2.1,
        },
        exact mem_compl hynA,
      },
      exact ⟨V, hV.1, hV.2.2, hVAc⟩,
    },
  },
  rw [is_closed, ← hAc],
  exact (interior_is_open Aᶜ),
end

/- Exemples de compacitat: topologica cofinita (definir-la) i demostrar compacitat -/

