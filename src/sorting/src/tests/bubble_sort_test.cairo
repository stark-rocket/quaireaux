use alexandria_sorting::{is_equal, bubble_sort};

#[test]
#[available_gas(20000000000000)]
fn bubblesort_test() {
    let data = array![4_u32, 2_u32, 1_u32, 3_u32, 5_u32, 0_u32];
    let correct = array![0_u32, 1_u32, 2_u32, 3_u32, 4_u32, 5_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, true);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}


#[test]
#[available_gas(2000000)]
fn bubblesort_test_empty() {
    let data = array![];
    let correct = array![];

    let sorted = bubble_sort::bubble_sort_elements(data, true);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_one_element() {
    let data = array![2_u32];
    let correct = array![2_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, true);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_pre_sorted() {
    let data = array![1_u32, 2_u32, 3_u32, 4_u32];
    let correct = array![1_u32, 2_u32, 3_u32, 4_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, true);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_pre_sorted_decreasing() {
    let data = array![4_u32, 3_u32, 2_u32, 1_u32];
    let correct = array![1_u32, 2_u32, 3_u32, 4_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, true);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_pre_sorted_2_same_values() {
    let data = array![1_u32, 2_u32, 2_u32, 4_u32];
    let correct = array![1_u32, 2_u32, 2_u32, 4_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, true);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_2_same_values() {
    let data = array![1_u32, 2_u32, 4_u32, 2_u32];
    let correct = array![1_u32, 2_u32, 2_u32, 4_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, true);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(20000000000000)]
fn bubblesort_test_dsc() {
    let data = array![4_u32, 2_u32, 1_u32, 3_u32, 5_u32, 0_u32];
    let correct = array![5_u32, 4_u32, 3_u32, 2_u32, 1_u32, 0_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, false);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}


#[test]
#[available_gas(2000000)]
fn bubblesort_test_empty_dsc() {
    let data = array![];
    let correct = array![];

    let sorted = bubble_sort::bubble_sort_elements(data, false);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_one_element_dsc() {
    let data = array![2_u32];
    let correct = array![2_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, false);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_pre_sorted_dsc() {
    let data = array![1_u32, 2_u32, 3_u32, 4_u32];
    let correct = array![4_u32, 3_u32, 2_u32, 1_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, false);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_pre_sorted_decreasing_dsc() {
    let data = array![4_u32, 3_u32, 2_u32, 1_u32];
    let correct = array![4_u32, 3_u32, 2_u32, 1_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, false);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_pre_sorted_2_same_values_dsc() {
    let data = array![1_u32, 2_u32, 2_u32, 4_u32];
    let correct = array![4_u32, 2_u32, 2_u32, 1_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, false);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}

#[test]
#[available_gas(2000000)]
fn bubblesort_test_2_same_values_dsc() {
    let data = array![1_u32, 2_u32, 4_u32, 2_u32];
    let correct = array![4_u32, 2_u32, 2_u32, 1_u32];

    let sorted = bubble_sort::bubble_sort_elements(data, false);

    assert(is_equal(sorted.span(), correct.span()), 'invalid result');
}
