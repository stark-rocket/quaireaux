//! MerkleTree implementation.
//!
//! # Example
//! ```
//! use alexandria::data_structures::merkle_tree::{MerkleTree, HasherTrait, PedersenHasher, PoseidonHasher, MerkleTreeTrait};
//!
//! // Create a new merkle tree legacy instance, this version uses the pedersen hash method.
//! let hasher: PedersenHasher = HasherTrait::new();
//! let mut merkle_tree: MerkleTree<PedersenHasher> = MerkleTreeTrait::new();
//! let mut proof = array![];
//! proof.append(element_1);
//! proof.append(element_2);
//! // Compute the merkle root.
//! let root = merkle_tree.compute_root(leaf, proof);
//!
//! // Create a new merkle tree instance, this version uses the poseidon hash method.
//! let hasher: PoseidonHasher = HasherTrait::new();
//! let mut merkle_tree: MerkleTree<PoseidonHasher> = MerkleTreeTrait::new();
//! let mut proof = array![];
//! proof.append(element_1);
//! proof.append(element_2);
//! // Compute the merkle root.
//! let root = merkle_tree.compute_root(leaf, proof);

// Core lib imports
use array::{ArrayTrait, SpanTrait};
use pedersen::PedersenTrait;
use poseidon::PoseidonTrait;
use hash::HashStateTrait;
use traits::{Into, Copy, Drop};

/// Hasher trait.

trait HasherTrait<T> {
    fn new() -> T;
    fn hash(ref self: T, data1: felt252, data2: felt252) -> felt252;
}


// Hasher representations.

#[derive(Drop, Copy)]
struct PedersenHasher {}

#[derive(Drop, Copy)]
struct PoseidonHasher {}

/// Hasher impls.

impl PedersenHasherImpl of HasherTrait<PedersenHasher> {
    fn new() -> PedersenHasher {
        PedersenHasher {}
    }
    fn hash(ref self: PedersenHasher, data1: felt252, data2: felt252) -> felt252 {
        let mut state = PedersenTrait::new(data1);
        state = state.update(data2);
        state.finalize()
    }
}

impl PoseidonHasherImpl of HasherTrait<PoseidonHasher> {
    fn new() -> PoseidonHasher {
        PoseidonHasher {}
    }
    fn hash(ref self: PoseidonHasher, data1: felt252, data2: felt252) -> felt252 {
        let mut state = PoseidonTrait::new();
        state = state.update(data1);
        state = state.update(data2);
        state.finalize()
    }
}

/// MerkleTree representation.

#[derive(Drop)]
struct MerkleTree<T> {
    hasher: T
}

/// MerkleTree trait.
trait MerkleTreeTrait<T> {
    /// Create a new merkle tree instance.
    fn new() -> MerkleTree<T>;
    /// Compute the merkle root of a given proof.
    fn compute_root(
        ref self: MerkleTree<T>, current_node: felt252, proof: Span<felt252>
    ) -> felt252;
    /// Verify a merkle proof.
    fn verify(ref self: MerkleTree<T>, root: felt252, leaf: felt252, proof: Span<felt252>) -> bool;
    /// Compute a merkle proof of given leaves and at a given index.
    fn compute_proof(ref self: MerkleTree<T>, leaves: Array<felt252>, index: u32) -> Span<felt252>;
}

/// MerkleTree Legacy implementation.
impl MerkleTreeImpl<
    T, impl THasher: HasherTrait<T>, impl TCopy: Copy<T>, impl TDrop: Drop<T>
> of MerkleTreeTrait<T> {
    /// Create a new merkle tree instance.
    fn new() -> MerkleTree<T> {
        MerkleTree { hasher: HasherTrait::new() }
    }

    /// Compute the merkle root of a given proof using the pedersen hash method.
    /// # Arguments
    /// * `current_node` - The current node of the proof.
    /// * `proof` - The proof.
    /// # Returns
    /// The merkle root.
    fn compute_root(
        ref self: MerkleTree<T>, mut current_node: felt252, mut proof: Span<felt252>
    ) -> felt252 {
        loop {
            match proof.pop_front() {
                Option::Some(proof_element) => {
                    // Compute the hash of the current node and the current element of the proof.
                    // We need to check if the current node is smaller than the current element of the proof.
                    // If it is, we need to swap the order of the hash.
                    current_node =
                        if Into::<felt252, u256>::into(current_node) < (*proof_element).into() {
                            self.hasher.hash(current_node, *proof_element)
                        } else {
                            self.hasher.hash(*proof_element, current_node)
                        };
                },
                Option::None => {
                    break current_node;
                },
            };
        }
    }

    /// Verify a merkle proof.
    /// # Arguments
    /// * `root` - The merkle root.
    /// * `leaf` - The leaf to verify.
    /// * `proof` - The proof.
    /// # Returns
    /// True if the proof is valid, false otherwise.
    fn verify(
        ref self: MerkleTree<T>, root: felt252, mut leaf: felt252, mut proof: Span<felt252>
    ) -> bool {
        let computed_root = loop {
            match proof.pop_front() {
                Option::Some(proof_element) => {
                    // Compute the hash of the current node and the current element of the proof.
                    // We need to check if the current node is smaller than the current element of the proof.
                    // If it is, we need to swap the order of the hash.
                    leaf =
                        if Into::<felt252, u256>::into(leaf) < (*proof_element).into() {
                            self.hasher.hash(leaf, *proof_element)
                        } else {
                            self.hasher.hash(*proof_element, leaf)
                        };
                },
                Option::None => {
                    break leaf;
                },
            };
        };
        computed_root == root
    }

    /// Compute a merkle proof of given leaves and at a given index using the pedersen hash method.
    /// # Arguments
    /// * `leaves` - The sorted leaves.
    /// * `index` - The index of the given.
    /// # Returns
    /// The merkle proof.
    fn compute_proof(
        ref self: MerkleTree<T>, mut leaves: Array<felt252>, index: u32
    ) -> Span<felt252> {
        let mut proof: Array<felt252> = array![];
        _compute_proof(leaves, self.hasher, index, ref proof);
        proof.span()
    }
}

/// Helper function to compute a merkle proof of given leaves and at a given index.
/// # Arguments
/// * `nodes` - The sorted nodes.
/// * `index` - The index of the given.
/// * `method` - The hash method to use.
/// * `proof` - The proof array to fill.
fn _compute_proof<T, impl THasher: HasherTrait<T>, impl TDrop: Drop<T>>(
    mut nodes: Array<felt252>, mut hasher: T, index: u32, ref proof: Array<felt252>
) {
    // Break if we have reached the top of the tree
    if nodes.len() == 1 {
        return;
    }

    // If odd number of nodes, add a null virtual leaf
    if nodes.len() % 2 != 0 {
        nodes.append(0);
    }

    // Compute next level
    let mut next_level: Array<felt252> = _get_next_level(nodes.span(), ref hasher);

    // Find neighbor node
    let mut index_parent = 0;
    let mut i = 0;
    loop {
        if i == index {
            index_parent = i / 2;
            if i % 2 == 0 {
                proof.append(*nodes.at(i + 1));
            } else {
                proof.append(*nodes.at(i - 1));
            }
            break;
        }
        i += 1;
    };

    _compute_proof(next_level, hasher, index_parent, ref proof)
}

/// Helper function to compute the next layer of a merkle tree providing a layer of nodes.
/// # Arguments
/// * `nodes` - The sorted nodes.
/// * `method` - The hash method to use.
/// # Returns
/// The next layer of nodes.
fn _get_next_level<T, impl THasher: HasherTrait<T>, impl TDrop: Drop<T>>(
    mut nodes: Span<felt252>, ref hasher: T
) -> Array<felt252> {
    let mut next_level: Array<felt252> = array![];
    loop {
        if nodes.is_empty() {
            break;
        }
        let left = *nodes.pop_front().expect('Index out of bounds');
        let right = *nodes.pop_front().expect('Index out of bounds');
        let node = if Into::<felt252, u256>::into(left) < right.into() {
            hasher.hash(left, right)
        } else {
            hasher.hash(right, left)
        };
        next_level.append(node);
    };
    next_level
}
