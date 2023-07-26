use core::traits::TryInto;
use array::{ArrayTrait, SpanTrait};
use clone::Clone;
use integer::{u32_wrapping_add, BoundedInt};
use option::OptionTrait;
use traits::Into;

use alexandria::math::math::BitShift;

fn ch(x: u32, y: u32, z: u32) -> u32 {
    (x & y) ^ ((x ^ BoundedInt::<u32>::max().into()) & z)
}

fn maj(x: u32, y: u32, z: u32) -> u32 {
    (x & y) ^ (x & z) ^ (y & z)
}

fn bsig0(x: u32) -> u32 {
    let x: u128 = x.into();
    // Last part is 32 - first shift, for the first line 32 - 2 = 30
    let x1 = (BitShift::shr(x, 2) | BitShift::shl(x, 30));
    let x2 = (BitShift::shr(x, 13) | BitShift::shl(x, 19));
    let x3 = (BitShift::shr(x, 22) | BitShift::shl(x, 10));
    let result = (x1 ^ x2 ^ x3) & BoundedInt::<u32>::max().into();
    result.try_into().unwrap()
}

fn bsig1(x: u32) -> u32 {
    let x: u128 = x.into();
    // Last part is 32 - first shift, for the first line 32 - 6 = 26
    let x1 = (BitShift::shr(x, 6) | BitShift::shl(x, 26));
    let x2 = (BitShift::shr(x, 11) | BitShift::shl(x, 21));
    let x3 = (BitShift::shr(x, 25) | BitShift::shl(x, 7));
    let result = (x1 ^ x2 ^ x3) & BoundedInt::<u32>::max().into();
    result.try_into().unwrap()
}

fn ssig0(x: u32) -> u32 {
    let x: u128 = x.into();
    // Last part is 32 - first shift, for the first line 32 - 7 = 25
    let x1 = (BitShift::shr(x, 7) | BitShift::shl(x, 25));
    let x2 = (BitShift::shr(x, 18) | BitShift::shl(x, 14));
    let x3 = (BitShift::shr(x, 3));
    let result = (x1 ^ x2 ^ x3) & BoundedInt::<u32>::max().into();
    result.try_into().unwrap()
}

fn ssig1(x: u32) -> u32 {
    let x: u128 = x.into();
    // Last part is 32 - first shift, for the first line 32 - 17 = 15
    let x1 = (BitShift::shr(x, 17) | BitShift::shl(x, 15));
    let x2 = (BitShift::shr(x, 19) | BitShift::shl(x, 13));
    let x3 = (BitShift::shr(x, 10));
    let result = (x1 ^ x2 ^ x3) & BoundedInt::<u32>::max().into();
    result.try_into().unwrap()
}

fn sha256(mut data: Array<u8>) -> Array<u8> {
    let u64_data_length: u128 = (data.len() * 8).into();
    let u64_data_length = u64_data_length & BoundedInt::<u64>::max().into();

    // add one
    data.append(0x80);
    // add padding
    loop {
        if (64 * ((data.len() - 1) / 64 + 1)) - 8 == data.len() {
            break;
        }
        data.append(0);
    };

    // add length to the end
    let mut res = BitShift::shr(u64_data_length, 56) & BoundedInt::<u8>::max().into();
    data.append(res.try_into().unwrap());
    res = BitShift::shr(u64_data_length, 48) & BoundedInt::<u8>::max().into();
    data.append(res.try_into().unwrap());
    res = BitShift::shr(u64_data_length, 40) & BoundedInt::<u8>::max().into();
    data.append(res.try_into().unwrap());
    res = BitShift::shr(u64_data_length, 32) & BoundedInt::<u8>::max().into();
    data.append(res.try_into().unwrap());
    res = BitShift::shr(u64_data_length, 24) & BoundedInt::<u8>::max().into();
    data.append(res.try_into().unwrap());
    res = BitShift::shr(u64_data_length, 16) & BoundedInt::<u8>::max().into();
    data.append(res.try_into().unwrap());
    res = BitShift::shr(u64_data_length, 8) & BoundedInt::<u8>::max().into();
    data.append(res.try_into().unwrap());
    res = u64_data_length.into() & BoundedInt::<u8>::max().into();
    data.append(res.try_into().unwrap());

    let data = from_u8Array_to_u32Array(data.span());
    let h = get_h();
    let k = get_k();
    let res = sha256_inner(data.span(), 0, k.span(), h.span());

    from_u32Array_to_u8Array(res)
}

fn from_u32Array_to_u8Array(mut data: Span<u32>) -> Array<u8> {
    let mut result = ArrayTrait::new();
    loop {
        match data.pop_front() {
            Option::Some(val) => {
                let mut res: u128 = BitShift::shr((*val).into(), 24);
                result.append(res.try_into().unwrap());
                res = BitShift::shr((*val).into(), 16) & BoundedInt::<u8>::max().into();
                result.append(res.try_into().unwrap());
                res = BitShift::shr((*val).into(), 8) & BoundedInt::<u8>::max().into();
                result.append(res.try_into().unwrap());
                res = (*val).into() & BoundedInt::<u8>::max().into();
                result.append(res.try_into().unwrap());
            },
            Option::None => {
                break;
            },
        };
    };
    result
}

fn sha256_inner(mut data: Span<u32>, i: usize, k: Span<u32>, mut h: Span<u32>) -> Span<u32> {
    if 16 * i >= data.len() {
        return h;
    }
    let w = create_message_schedule(data, i);
    let h2 = compression(w, 0, k, h);
    let mut t = ArrayTrait::new();
    t.append(u32_wrapping_add(*h[0], *h2[0]));
    t.append(u32_wrapping_add(*h[1], *h2[1]));
    t.append(u32_wrapping_add(*h[2], *h2[2]));
    t.append(u32_wrapping_add(*h[3], *h2[3]));
    t.append(u32_wrapping_add(*h[4], *h2[4]));
    t.append(u32_wrapping_add(*h[5], *h2[5]));
    t.append(u32_wrapping_add(*h[6], *h2[6]));
    t.append(u32_wrapping_add(*h[7], *h2[7]));
    h = t.span();
    sha256_inner(data, i + 1, k, h)
}

fn compression(w: Span<u32>, i: usize, k: Span<u32>, mut h: Span<u32>) -> Span<u32> {
    if i >= 64 {
        return h;
    }
    let s1 = bsig1(*h[4]);
    let ch = ch(*h[4], *h[5], *h[6]);
    let temp1 = u32_wrapping_add(
        u32_wrapping_add(u32_wrapping_add(u32_wrapping_add(*h[7], s1), ch), *k[i]), *w[i]
    );
    let s0 = bsig0(*h[0]);
    let maj = maj(*h[0], *h[1], *h[2]);
    let temp2 = u32_wrapping_add(s0, maj);
    let mut t = ArrayTrait::new();
    t.append(u32_wrapping_add(temp1, temp2));
    t.append(*h[0]);
    t.append(*h[1]);
    t.append(*h[2]);
    t.append(u32_wrapping_add(*h[3], temp1));
    t.append(*h[4]);
    t.append(*h[5]);
    t.append(*h[6]);
    h = t.span();
    compression(w, i + 1, k, h)
}

fn create_message_schedule(data: Span<u32>, i: usize) -> Span<u32> {
    let mut j = 0;
    let mut result = ArrayTrait::new();
    loop {
        if j >= 16 {
            break;
        }
        result.append(*data[i * 16 + j]);
        j += 1;
    };
    let mut i = 16;
    loop {
        if i >= 64 {
            break;
        }
        let s0 = ssig0(*result[i - 15]);
        let s1 = ssig1(*result[i - 2]);
        let res = u32_wrapping_add(
            u32_wrapping_add(u32_wrapping_add(*result[i - 16], s0), *result[i - 7]), s1
        );
        result.append(res);
        i += 1;
    };
    result.span()
}

fn from_u8Array_to_u32Array(mut data: Span<u8>) -> Array<u32> {
    let mut result = ArrayTrait::new();
    loop {
        match data.pop_front() {
            Option::Some(val1) => {
                let val2 = data.pop_front().unwrap();
                let val3 = data.pop_front().unwrap();
                let val4 = data.pop_front().unwrap();
                let mut value: u128 = (BitShift::shl((*val1).into(), 24));
                value = value + (BitShift::shl((*val2).into(), 16));
                value = value + (BitShift::shl((*val3).into(), 8));
                value = value + (*val4).into();
                result.append(value.try_into().unwrap());
            },
            Option::None => {
                break;
            },
        };
    };
    result
}

fn get_h() -> Array<u32> {
    array![
        0x6a09e667,
        0xbb67ae85,
        0x3c6ef372,
        0xa54ff53a,
        0x510e527f,
        0x9b05688c,
        0x1f83d9ab,
        0x5be0cd19
    ]
}

fn get_k() -> Array<u32> {
    array![
        0x428a2f98,
        0x71374491,
        0xb5c0fbcf,
        0xe9b5dba5,
        0x3956c25b,
        0x59f111f1,
        0x923f82a4,
        0xab1c5ed5,
        0xd807aa98,
        0x12835b01,
        0x243185be,
        0x550c7dc3,
        0x72be5d74,
        0x80deb1fe,
        0x9bdc06a7,
        0xc19bf174,
        0xe49b69c1,
        0xefbe4786,
        0x0fc19dc6,
        0x240ca1cc,
        0x2de92c6f,
        0x4a7484aa,
        0x5cb0a9dc,
        0x76f988da,
        0x983e5152,
        0xa831c66d,
        0xb00327c8,
        0xbf597fc7,
        0xc6e00bf3,
        0xd5a79147,
        0x06ca6351,
        0x14292967,
        0x27b70a85,
        0x2e1b2138,
        0x4d2c6dfc,
        0x53380d13,
        0x650a7354,
        0x766a0abb,
        0x81c2c92e,
        0x92722c85,
        0xa2bfe8a1,
        0xa81a664b,
        0xc24b8b70,
        0xc76c51a3,
        0xd192e819,
        0xd6990624,
        0xf40e3585,
        0x106aa070,
        0x19a4c116,
        0x1e376c08,
        0x2748774c,
        0x34b0bcb5,
        0x391c0cb3,
        0x4ed8aa4a,
        0x5b9cca4f,
        0x682e6ff3,
        0x748f82ee,
        0x78a5636f,
        0x84c87814,
        0x8cc70208,
        0x90befffa,
        0xa4506ceb,
        0xbef9a3f7,
        0xc67178f2
    ]
}
