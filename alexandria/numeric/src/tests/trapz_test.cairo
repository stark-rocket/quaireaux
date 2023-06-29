// Core library imports.
use array::ArrayTrait;

use alexandria_numeric::trapz::trapz;

#[test]
#[available_gas(2000000)]
fn trapz_test() {
    let mut xs = ArrayTrait::new();
    xs.append(3);
    xs.append(5);
    xs.append(7);
    let mut ys = ArrayTrait::new();
    ys.append(11);
    ys.append(13);
    ys.append(17);
    assert(trapz(xs, ys) == 54, 'invalid integral');
}

#[test]
#[should_panic]
#[available_gas(2000000)]
fn trapz_test_revert_len_mismatch() {
    let mut xs = ArrayTrait::new();
    xs.append(3);
    let mut ys = ArrayTrait::new();
    trapz(xs, ys);
}

#[test]
#[should_panic]
#[available_gas(2000000)]
fn trapz_test_revert_len_too_short() {
    let mut xs = ArrayTrait::new();
    xs.append(3);
    let mut ys = ArrayTrait::new();
    ys.append(11);
    trapz(xs, ys);
}

#[test]
#[should_panic]
#[available_gas(2000000)]
fn trapz_test_revert_not_sorted() {
    let mut xs = ArrayTrait::new();
    xs.append(5);
    xs.append(3);
    let mut ys = ArrayTrait::new();
    ys.append(11);
    ys.append(13);
    trapz(xs, ys);
}
