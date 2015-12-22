defmodule Woot do
  @type client_id :: integer
  @type wchar_id_clock :: integer
  @type wchar_id :: {client_id, wchar_id_clock}
  @type visible :: boolean
  @type char_alpha :: String.t()
  @type wchar :: {wchar_id, visible, char_alpha, wchar_id, wchar_id}
  @type wstring :: [wchar]
  @type operation :: {atom, wchar}

  @spec wchar_beginning :: wchar
  def wchar_beginning() do
    {wchar_id_beginning(), false, ' ', wchar_id_beginning(), wchar_id_ending()}
  end

  @spec wchar_ending :: wchar
  def wchar_ending() do
    {wchar_id_ending(), false, ' ', wchar_id_beginning(), wchar_id_ending()}
  end

  # make wchar invisible
  @spec hide(wchar) :: wchar
  def hide(wc) do
    {a, _, c, d, e} = wc
    {a, false, c, d, e}
  end

  def wchar_id_beginning() do
    {-1, 0}
  end

  def wchar_id_ending() do
    {-1, 1}
  end

  @spec wstring_pos(wstring, wchar) :: integer
  def wstring_pos(ws, wc) do
    {{id, id_clock},_,_,_,_} = wc
    Enum.find_index(ws, fn({{i, clock},_,_,_,_}) -> i == id && clock == id_clock end)
  end

  #hacked together
  @spec insert_wc(wstring, integer, char_alpha, wchar_id) :: wstring
  def insert_wc(ws, pos, alpha, id) do
    wc_p = wstring_ith_visible(ws, pos-1)
    wc_n = wstring_ith_visible(ws, pos+1)
    wc = {id, true, alpha, wc_p, wc_n}

    wc_p_pos = wstring_pos(ws, wc_p)
    wc_n_pos = wstring_pos(ws, wc_n)

    start_s = Enum.slice(ws, 0..(wc_p_pos-1))
    end_s = Enum.slice(ws, wc_n_pos..(length(ws)))
    middle_s = Enum.slice(ws, (wc_p_pos+1)..(wc_n_pos-1))

    insert_wc!(middle_s, wc)
    start_s ++ middle_s ++ end_s
  end

  @spec insert_wc!(wstring, wchar) :: wstring
  def insert_wc!([x|xs], wc) do
    if compare_wc_id(wc, x) do
      [wc|[x|xs]]
    end

    [x|insert_wc!(xs, wc)]
  end

  def insert_wc!([], wc) do
    wc
  end

  #if wc1 is before wc2 then true, else false
  @spec compare_wc_id(wchar, wchar) :: boolean
  def compare_wc_id(wc1, wc2) do
    {{id1, clock1},_,_,_,_} = wc1
    {{id2, clock2},_,_,_,_} = wc2

    if id1 < id2 || (id1 == id2 && clock1 < clock2) do
      true
    end

    false
  end

  @spec delete_wc(wstring, wchar) :: wstring
  def delete_wc(ws, wc) do
    pos = wstring_pos(ws, wc)
    slice1 = Enum.slice(ws, 0..(pos-1))
    slice2 = Enum.slice(ws, (pos+1)..(length(ws)))
    new_wc = hide(wc)
    slice1 ++ new_wc ++ slice2
  end

  # exclusive subsequence of a wstring
  @spec wstring_subseq(wstring, integer, integer) :: wstring
  def wstring_subseq(ws, c, d) do
    s = c + 1 # start position
    e = d - 1 # end position
    Enum.slice(ws, s..e)
  end

  @spec wstring_contains(wstring, wchar) :: boolean
  def wstring_contains(ws, wc) do
    List.keymember?(ws, wc, 0)
  end

  #return a wstring with all the visible wchars
  @spec wstring_value(wstring) :: wstring
  def wstring_value(ws) do
    {wstr,_} = Enum.partition(ws, fn({_,v,_,_,_}) -> v == true end)
    wstr
  end

  #return the ith visible wchar from the wstring
  @spec wstring_ith_visible(wstring, integer) :: wstring
  def wstring_ith_visible(ws, i) do
    ws_ = wstring_value(ws)
    Enum.at(ws_, i)
  end
end
