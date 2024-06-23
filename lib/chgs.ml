module type HE_Scheme = sig
  type plaintext
  type ciphertext
  type rotated_ciphertext
  
  val encrypt : plaintext -> ciphertext
  val rotate : ciphertext -> int -> rotated_ciphertext
  val add : ciphertext -> ciphertext -> ciphertext
  val multiply : rotated_ciphertext -> plaintext -> ciphertext
end

module EncryptedHEMatrixMult (HE : HE_Scheme) = struct
  open HE

  let pack_and_encrypt x n d_oh m =
    let c = ref 0 in
    let s = ref 0 in
    let p = Array.make m [||] in
    let cipher = Array.make m (encrypt [||]) in
    
    for j = 0 to d_oh - 1 do
      for h = 0 to n - 1 do
        if !s = 0 then p.(!c) <- Array.make n (Array.get x.(j) h)
        else p.(!c).(!s) <- Array.get x.(j) h;
        incr s;
        if h = 0 && (!s + n <= m) then begin
          s := 0;
          cipher.(!c) <- encrypt p.(!c);
          incr c
        end
      done
    done;
    (!c, cipher)

  let matrix_multiply_encrypted cipher w n d_oh d_emb m =
    let result = Array.make_matrix d_oh d_emb (encrypt [||]) in
    for j = 0 to d_oh - 1 do
      for i = 0 to m - 1 step n do
        let tmp_c = rotate cipher.(j) i in
        for g = 0 to d_emb - 1 do
          let prod = multiply tmp_c w.(i/n).(g) in
          result.(j).(g) <- add result.(j).(g) prod
        done
      done
    done;
    result

  let encrypted_he_matrix_mult x w n d_oh d_emb m =
    let c, packed_cipher = pack_and_encrypt x n d_oh m in
    let result = matrix_multiply_encrypted packed_cipher w n d_oh d_emb m in
    merge_and_add_ciphers result
end